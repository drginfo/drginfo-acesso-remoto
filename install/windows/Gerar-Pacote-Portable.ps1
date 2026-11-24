#Requires -Version 5.1
<#
.SYNOPSIS
  Gera pacote portatil DRGinfo Acesso Remoto, sem instalar servico.
.DESCRIPTION
  Usa a release homologada da VPS, validada por SHA-256, e empacota
  os binarios existentes, sem recompilar ou modificar codigo RustDesk.
  Esta modalidade precisa de homologacao de conexao e persistencia separada.
#>
[CmdletBinding()]
param([string]$Version = '1.5.3-drginfo.1-portable1')
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
if ($Version -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,59}$') { throw 'Versao invalida.' }
$Url = 'https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/1.5.3-drginfo.1/DRGinfo-AcessoRemoto-windows-x64.zip'
$Expected = '3AC5BAC4B6AD211395C8C98FC9BA0E220517105C70F30003A818E36E588E8BA9'
$Root = Join-Path $env:ProgramData 'DRGinfo\AcessoRemoto'
$Cache = Join-Path (Join-Path $Root 'packages') ($Expected.ToLowerInvariant())
$SourceZip = Join-Path $Cache 'package.zip'
$Output = Join-Path (Join-Path $Root 'releases\portable') $Version
$Work = Join-Path $Output 'payload'
$Archive = Join-Path $Output 'DRGinfo-AcessoRemoto-Portable-Windows-x64.zip'
if (Test-Path -LiteralPath $Output) { throw "Release existente, recusando sobrescrever: $Output" }
try {
  New-Item -ItemType Directory -Path $Cache,$Work -Force | Out-Null
  if (-not (Test-Path -LiteralPath $SourceZip -PathType Leaf)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $Url -OutFile $SourceZip -MaximumRedirection 0 -TimeoutSec 180 -UseBasicParsing -ErrorAction Stop
  }
  if ((Get-FileHash -LiteralPath $SourceZip -Algorithm SHA256).Hash -ne $Expected) {
    throw 'Pacote de origem nao corresponde ao SHA256 homologado.'
  }
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $sourceArchive = [System.IO.Compression.ZipFile]::OpenRead($SourceZip)
  try {
    if ($sourceArchive.Entries.Count -gt 10000) { throw 'Excesso de entradas no ZIP.' }
    $total = [int64]0
    foreach ($entry in $sourceArchive.Entries) {
      $name = $entry.FullName.Replace('\','/')
      if ($name.StartsWith('/') -or $name -match '^[a-zA-Z]:' -or $name.Contains(':') -or $name.Split('/').Contains('..')) {
        throw "Entrada insegura no ZIP: $name"
      }
      $mode = ($entry.ExternalAttributes -shr 16) -band 61440
      if ($mode -eq 40960) { throw 'Link simbolico proibido.' }
      $total += $entry.Length
      if ($total -gt 1073741824) { throw 'Pacote descompactado excede 1GiB.' }
    }
  } finally { $sourceArchive.Dispose() }
  Expand-Archive -LiteralPath $SourceZip -DestinationPath $Work -ErrorAction Stop
  $executables = @(Get-ChildItem -LiteralPath $Work -Recurse -File -Filter 'rustdesk.exe')
  if ($executables.Count -ne 1) { throw 'Nao encontrado executavel RustDesk unico.' }
  $binDir = $executables[0].DirectoryName
  foreach ($item in @('librustdesk.dll','flutter_windows.dll','data\app.so','data\icudtl.dat','data\flutter_assets')) {
    if (-not (Test-Path -LiteralPath (Join-Path $binDir $item))) { throw "Dependencia ausente: $item" }
  }
  if (Test-Path -LiteralPath (Join-Path $binDir 'custom.txt')) { throw 'custom.txt nao permitido.' }
  Rename-Item -LiteralPath $executables[0].FullName -NewName 'DRGinfo Acesso Remoto.exe'
  @(
    'DRGinfo Acesso Remoto - modo portatil'
    ''
    'Execute DRGinfo Acesso Remoto.exe na pasta extraida.'
    'Nao registra automaticamente servico Windows nem aparece em Aplicativos instalados.'
    'Para uso remoto desassistido apos reinicio, use a versao instalavel.'
    'Configuracoes e logs de usuario podem permanecer no perfil Windows mesmo apos remover esta pasta.'
    'Versao ainda sem assinatura Authenticode; valide a procedencia e SHA256 do ZIP.'
    'Nao executar o arquivo dentro do ZIP. Extraia todos os componentes.'
  ) | Set-Content -LiteralPath (Join-Path $binDir 'LEIA-ME-PORTATIL.txt') -Encoding UTF8
  [System.IO.Compression.ZipFile]::CreateFromDirectory(
    $Work, $Archive, [System.IO.Compression.CompressionLevel]::Optimal, $false)
  $hash = (Get-FileHash -LiteralPath $Archive -Algorithm SHA256).Hash
  @(
    "Version=$Version"
    "SourceSHA256=$Expected"
    "PortableSHA256=$hash"
    'WindowsService=NOT_INSTALLED'
    'Authenticode=UNSIGNED'
    'Status=REQUIRES_TESTING'
  ) | Set-Content -LiteralPath (Join-Path $Output 'release.txt') -Encoding ASCII
  Write-Host "PACOTE PORTATIL: $Archive"
  Write-Host "SHA256: $hash"
  Write-Host 'Sem alteracao de servicos ou programas instalados.'
} catch {
  $reason = $_.Exception.Message
  if (Test-Path -LiteralPath $Output) { Remove-Item -LiteralPath $Output -Recurse -Force }
  throw $reason
}
