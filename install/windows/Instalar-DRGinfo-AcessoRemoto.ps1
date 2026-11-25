#Requires -Version 5.1
<#
.SYNOPSIS
  Instalador DRGinfo Acesso Remoto - Windows x64, distribuicao pela VPS.
.DESCRIPTION
  Pacote HTTPS + SHA256 fixado por release + assinatura Authenticode valida.
  Arquivos de origem ficam em C:\ProgramData\DRGinfo\AcessoRemoto\packages\<sha256>
  e o aplicativo fica em C:\Program Files\DRGinfo Acesso Remoto.
  Falha fechada: nao instala binario sem assinatura ou hash nao correspondente.
  Nao sobrescreve instalacao anterior. Requer elevacao.
.EXAMPLE
  .\Instalar-DRGinfo-AcessoRemoto.ps1 -PackageSha256 "<64 caracteres hex>" -PublisherThumbprint "<thumbprint certificado de code signing>"
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$PackageUrl,
  [Parameter(Mandatory=$true)][ValidatePattern('^[0-9a-fA-F]{64}$')][string]$PackageSha256,
  [ValidatePattern('^[0-9a-fA-F]{40,64}$')][string]$PublisherThumbprint,
  [switch]$AllowUnsigned,
  [switch]$ValidateOnly
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$AppName = 'DRGinfo Acesso Remoto'
$ServiceName = $AppName
$InstallDir = Join-Path $env:ProgramFiles $AppName
$InstalledExe = Join-Path $InstallDir "$AppName.exe"
$Root = Join-Path $env:ProgramData 'DRGinfo\AcessoRemoto'
$ReleaseDir = Join-Path (Join-Path $Root 'packages') $PackageSha256.ToLowerInvariant()
$Archive = Join-Path $ReleaseDir 'package.zip'
$Extracted = Join-Path $ReleaseDir 'extracted'
$LogFile = Join-Path $Root 'instalacao.log'
$CreatedDir = $false
$CreatedService = $false

function Write-Log([string]$Message, [string]$Level='INFO') {
  $line = '{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
  Add-Content -LiteralPath $LogFile -Encoding UTF8 -Value $line
  Write-Host $line
}
function Assert-Authenticode([string]$Path, [string]$ExpectedThumbprint) {
  $signature = Get-AuthenticodeSignature -LiteralPath $Path
  if ($signature.Status -ne 'Valid' -or -not $signature.SignerCertificate) {
    throw "Assinatura digital invalida ou ausente: $Path ($($signature.Status))"
  }
  $thumbprint = ($signature.SignerCertificate.Thumbprint -replace '\s', '').ToUpperInvariant()
  if ($thumbprint -ne $ExpectedThumbprint.ToUpperInvariant()) {
    throw "Certificado de assinatura nao corresponde ao emissor autorizado: $Path"
  }
  Write-Log ("Assinatura Authenticode valida: {0}" -f (Split-Path $Path -Leaf))
}
function Assert-ZipEntries([string]$Path) {
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $zip = [IO.Compression.ZipFile]::OpenRead($Path)
  try {
    if ($zip.Entries.Count -gt 10000) { throw 'Pacote excede o limite de entradas.' }
    $total = [int64]0
    foreach ($entry in $zip.Entries) {
      $name = $entry.FullName.Replace('\','/')
      if ($name.StartsWith('/') -or $name -match '^[A-Za-z]:' -or
          ($name.Split('/') -contains '..') -or $name.Contains(':')) {
        throw "Caminho inseguro no ZIP: $name"
      }
      $mode = ($entry.ExternalAttributes -shr 16) -band 61440
      if ($mode -eq 40960) { throw 'Pacote ZIP contem link simbolico.' }
      $total += $entry.Length
      if ($total -gt 1073741824) { throw 'Pacote excede 1 GiB descompactado.' }
    }
  } finally { $zip.Dispose() }
}
try {
  New-Item -ItemType Directory -Path $Root, $ReleaseDir -Force | Out-Null
  Write-Log 'Iniciando validacao da distribuicao Windows x64 da DRGinfo.'
  $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Executar o Windows PowerShell x64 como Administrador.'
  }
  if (-not [Environment]::Is64BitOperatingSystem -or -not [Environment]::Is64BitProcess) {
    throw 'Windows x64 e PowerShell x64 obrigatorios.'
  }
  $uri = [Uri]$PackageUrl
  if ($uri.Scheme -ne 'https' -or $uri.Host -ne 'downloads.drginfo.com.br' -or
      $uri.Port -ne 443 -or $uri.UserInfo -or $uri.Query -or $uri.Fragment) {
    throw 'URL nao corresponde ao endereco HTTPS oficial esperado da DRGinfo.'
  }
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
  if (-not (Test-Path -LiteralPath $Archive -PathType Leaf)) {
    $partial = Join-Path $ReleaseDir 'package.zip.partial'
    Remove-Item -LiteralPath $partial -Force -ErrorAction SilentlyContinue
    Write-Log "Baixando release da VPS: $($uri.AbsolutePath)"
    Invoke-WebRequest -Uri $uri.AbsoluteUri -OutFile $partial -UseBasicParsing -MaximumRedirection 0 -TimeoutSec 180
    $downloadHash = (Get-FileHash -LiteralPath $partial -Algorithm SHA256).Hash
    if ($downloadHash -ne $PackageSha256.ToUpperInvariant()) {
      Remove-Item -LiteralPath $partial -Force -ErrorAction SilentlyContinue
      throw 'SHA256 do download nao corresponde ao hash oficial da release.'
    }
    Move-Item -LiteralPath $partial -Destination $Archive
  }
  if ((Get-FileHash -LiteralPath $Archive -Algorithm SHA256).Hash -ne $PackageSha256.ToUpperInvariant()) {
    throw 'SHA256 invalido no arquivo persistente. Instalacao interrompida.'
  }
  Write-Log "Pacote SHA256 validado: $PackageSha256"
  Assert-ZipEntries $Archive
  if (-not (Test-Path -LiteralPath $Extracted -PathType Container)) {
    $work = Join-Path $ReleaseDir 'extracting'
    if (Test-Path -LiteralPath $work) { Remove-Item -LiteralPath $work -Recurse -Force }
    New-Item -ItemType Directory -Path $work | Out-Null
    Expand-Archive -LiteralPath $Archive -DestinationPath $work -Force
    Rename-Item -LiteralPath $work -NewName 'extracted'
  }
  $executables = @(Get-ChildItem -LiteralPath $Extracted -Recurse -File | Where-Object { $_.Name -in @('rustdesk.exe','DRGinfo Acesso Remoto.exe') })
  if ($executables.Count -ne 1) { throw 'Pacote deve conter exatamente um executavel aprovado.' }
  $source = $executables[0].DirectoryName
  foreach ($relative in @('librustdesk.dll','flutter_windows.dll','data\app.so','data\icudtl.dat','data\flutter_assets')) {
    if (-not (Test-Path -LiteralPath (Join-Path $source $relative))) {
      throw "Componente obrigatorio ausente: $relative"
    }
  }
  if (Test-Path -LiteralPath (Join-Path $source 'custom.txt')) {
    throw 'custom.txt proibido nesta edicao com configuracao incorporada.'
  }
  if ($AllowUnsigned) {
    Write-Log 'AVISO: executavel nao assinado. HTTPS protege o transporte; SHA256 fixado verifica integridade.' 'AVISO'
  } else {
    if (-not $PublisherThumbprint) { throw 'PublisherThumbprint obrigatorio salvo quando -AllowUnsigned.' }
    foreach ($binary in @('rustdesk.exe','librustdesk.dll')) {
      Assert-Authenticode (Join-Path $source $binary) $PublisherThumbprint
    }
  }
  Write-Log 'Release validada e armazenada no diretorio permanente.'
  if ($ValidateOnly) {
    Write-Log 'VALIDACAO APROVADA. Modo ValidateOnly: sem instalacao nem alteracao de servico.'
    exit 0
  }
  if ((Test-Path -LiteralPath $InstallDir) -or (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)) {
    throw 'Instalacao DRGinfo existente: nao sobrescrever. Atualizacao deve usar fluxo dedicado.'
  }
  New-Item -ItemType Directory -Path $InstallDir | Out-Null
  $CreatedDir = $true
  foreach ($item in Get-ChildItem -LiteralPath $source -Force) {
    if ($item.Name -match '\.(ps1|cmd|bat)$') { continue }
    Copy-Item -LiteralPath $item.FullName -Destination $InstallDir -Recurse -Force
  }
  if ($executables[0].Name -eq 'rustdesk.exe') {
    Rename-Item -LiteralPath (Join-Path $InstallDir 'rustdesk.exe') -NewName "$AppName.exe"
  }
  if (-not (Test-Path -LiteralPath $InstalledExe -PathType Leaf)) { throw 'Executavel DRGinfo ausente apos copia.' }
  if (-not $AllowUnsigned) { Assert-Authenticode $InstalledExe $PublisherThumbprint }
  $manifest = Join-Path $Root 'manifesto-sha256.csv'
  Get-ChildItem -LiteralPath $InstallDir -Recurse -File | ForEach-Object {
    [PSCustomObject]@{
      Path = $_.FullName.Substring($InstallDir.Length).TrimStart('\')
      SHA256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }
  } | Export-Csv -LiteralPath $manifest -Encoding UTF8 -NoTypeInformation
  # Win32_Service.Create evita problemas de citacao do sc.exe em PS 5.1.
  $binPath = '"' + $InstalledExe + '" --service'
  $createArgs = @{
    Name = $ServiceName
    DisplayName = $AppName
    PathName = $binPath
    ServiceType = [byte]16
    ErrorControl = [byte]1
    StartMode = 'Automatic'
    DesktopInteract = $false
    StartName = 'LocalSystem'
  }
  Write-Log 'Criando servico via Win32_Service.Create.'
  $result = Invoke-CimMethod -ClassName Win32_Service -MethodName Create -Arguments $createArgs -ErrorAction Stop
  if ($result.ReturnValue -ne 0) {
    throw "Win32_Service.Create falhou: codigo $($result.ReturnValue)."
  }
  $CreatedService = $true
  Write-Log 'Servico registrado. Iniciando.'
  Start-Service -Name $ServiceName -ErrorAction Stop
  $status = 'Unknown'
  for ($i=0;$i -lt 12;$i++) {
    $status = (Get-Service -Name $ServiceName).Status
    if ($status -eq 'Running') { break }
    Start-Sleep -Seconds 1
  }
  if ($status -ne 'Running') { throw "Servico nao atingiu Running: $status" }
  # Registro em Aplicativos instalados (ARP) e desinstalador separado
  # do diretorio do aplicativo para possibilitar exclusao dos binarios.
  $uninstallSource = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'Desinstalar-DRGinfo-AcessoRemoto.ps1'
  if (-not (Test-Path -LiteralPath $uninstallSource -PathType Leaf)) {
    throw 'Desinstalador nao acompanha o pacote de instalacao.'
  }
  $toolsDir = Join-Path $Root 'tools'
  New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null
  $uninstallTarget = Join-Path $toolsDir 'Desinstalar-DRGinfo-AcessoRemoto.ps1'
  Copy-Item -LiteralPath $uninstallSource -Destination $uninstallTarget -Force
  $arp = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DRGinfoAcessoRemoto'
  New-Item -Path $arp -Force | Out-Null
  $uninstallCommand = '"' + "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" + '" -NoProfile -ExecutionPolicy Bypass -File "' + $uninstallTarget + '" -ConfirmRemoval'
  $fields = @{
    DisplayName = $AppName
    DisplayVersion = '1.5.3-drginfo.1'
    Publisher = 'DRGinfo'
    InstallLocation = $InstallDir
    DisplayIcon = $InstalledExe
    UninstallString = $uninstallCommand
    QuietUninstallString = $uninstallCommand
  }
  foreach ($field in $fields.Keys) { New-ItemProperty -Path $arp -Name $field -PropertyType String -Value $fields[$field] -Force | Out-Null }
  New-ItemProperty -Path $arp -Name 'NoModify' -PropertyType DWord -Value 1 -Force | Out-Null
  New-ItemProperty -Path $arp -Name 'NoRepair' -PropertyType DWord -Value 1 -Force | Out-Null
  Write-Log 'Aplicativo registrado em Aplicativos instalados do Windows.'
  Write-Log 'INSTALACAO CONCLUIDA. Servico automatico em execucao.'
  exit 0
} catch {
  Write-Log $_.Exception.Message 'ERRO'
  if ($CreatedDir) {
    $arp = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DRGinfoAcessoRemoto'
    if (Test-Path -LiteralPath $arp) {
      try { Remove-Item -LiteralPath $arp -Force -ErrorAction Stop } catch { Write-Log $_.Exception.Message 'AVISO' }
    }
  }
  if ($CreatedService) {
    try {
      $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
      if ($svc -and $svc.Status -ne 'Stopped') {
        Stop-Service -Name $ServiceName -Force -ErrorAction Stop
      }
      $delete = Invoke-CimMethod -InputObject (Get-CimInstance Win32_Service -Filter "Name='DRGinfo Acesso Remoto'") -MethodName Delete -ErrorAction Stop
      if ($delete.ReturnValue -ne 0) { throw "Remocao do servico retornou $($delete.ReturnValue)" }
      Write-Log 'Rollback do servico concluido.' 'ROLLBACK'
    } catch {
      Write-Log ("Rollback do servico falhou: {0}" -f $_.Exception.Message) 'AVISO'
    }
  }
  if ($CreatedDir -and (Test-Path -LiteralPath $InstallDir)) {
    try {
      Remove-Item -LiteralPath $InstallDir -Recurse -Force
      Write-Log 'Rollback dos arquivos instalados concluido.' 'ROLLBACK'
    } catch { Write-Log $_.Exception.Message 'AVISO' }
  }
  # Preservar arquivo ZIP validado e logs para auditoria/retentativa.
  exit 1
}
