#Requires -Version 5.1
<#
.SYNOPSIS
  Monta release ZIP autonoma do instalador grafico DRGinfo para a VPS.
.DESCRIPTION
  Baixa SOMENTE codigo-fonte/scripts/logo de commit fixo no repositorio DRGinfo.
  O cliente aplicativo continua sendo baixado SOMENTE da VPS no ato da instalacao.
  Nao altera o cliente ja instalado nem os servicos existentes.
  Gera ZIP + SHA-256 + inventario em ProgramData com versao imutavel.
#>
[CmdletBinding()]
param(
  [string]$Version = '1.0.0-gui1'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
if ($Version -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,59}$') { throw 'Versao invalida.' }
$SourceCommit = '0049673ef12bf7973c0c15b74b0919705ee6c260'
$RawBase = "https://raw.githubusercontent.com/drginfo/drginfo-acesso-remoto/$SourceCommit/"
$ReleaseRoot = Join-Path $env:ProgramData "DRGinfo\AcessoRemoto\releases\installer-gui\$Version"
$Payload = Join-Path $ReleaseRoot 'payload'
$Zip = Join-Path $ReleaseRoot 'DRGinfo-Instalador-Windows-x64.zip'
$Manifest = Join-Path $ReleaseRoot 'manifesto-sha256.csv'
$Info = Join-Path $ReleaseRoot 'release.txt'
if (Test-Path -LiteralPath $ReleaseRoot) {
  throw "Release ja existe. Recusando sobrescrever: $ReleaseRoot"
}
$items = [ordered]@{
  'instalador-drginfo.cmd' = 'install/windows/instalador-drginfo.cmd'
  'Interface-DRGinfo-AcessoRemoto.ps1' = 'install/windows/Interface-DRGinfo-AcessoRemoto.ps1'
  'Instalar-DRGinfo-AcessoRemoto.ps1' = 'install/windows/Instalar-DRGinfo-AcessoRemoto.ps1'
  'logo-drginfo.png' = 'flutter/assets/drginfo-logo.png'
}
try {
  New-Item -ItemType Directory -Path $Payload -Force | Out-Null
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
  foreach ($entry in $items.GetEnumerator()) {
    $localPath = Join-Path $Payload $entry.Key
    $url = $RawBase + $entry.Value
    Write-Host "Recebendo recurso de release fixada: $($entry.Key)"
    Invoke-WebRequest -Uri $url -OutFile $localPath -UseBasicParsing -MaximumRedirection 0 -TimeoutSec 60 -ErrorAction Stop
    if ((Get-Item -LiteralPath $localPath).Length -le 20) { throw "Arquivo invalido: $($entry.Key)" }
  }
  $png = [System.IO.File]::ReadAllBytes((Join-Path $Payload 'logo-drginfo.png'))
  if ($png.Length -lt 8 -or [Convert]::ToBase64String($png,0,8) -ne 'iVBORw0KGgo=') {
    throw 'Logotipo nao e PNG valido.'
  }
  foreach ($file in @('Interface-DRGinfo-AcessoRemoto.ps1','Instalar-DRGinfo-AcessoRemoto.ps1')) {
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile(
      (Join-Path $Payload $file),
      [ref]$tokens,
      [ref]$errors
    ) | Out-Null
    if (@($errors).Count -ne 0) {
      throw "Erro de sintaxe no pacote: $file - $($errors[0].Message)"
    }
  }
  @(
    'DRGinfo Acesso Remoto - Instalador Windows x64 v1.0.0-gui1'
    '1. Extraia todo este ZIP em uma pasta local.'
    '2. Execute instalador-drginfo.cmd com duplo clique, inclusive com usuario comum.'
    '3. A janela exibe logo, estado de instalacao e acesso ao log.'
    '4. Para instalar, clique Instalar DRGinfo; o Windows pedira UAC/credenciais.'
    '5. O cliente de 68 MB sera baixado exclusivamente da VPS DRGinfo.'
    '6. A release de software e provisoria, sem Authenticode; integridade fixada por SHA256.'
    '7. O instalador nao substitui instalacao existente.'
    '8. Para integridade do ZIP, compare o hash fornecido pela DRGinfo por canal confiavel.'
    '9. Nao desabilitar UAC, SmartScreen ou antivirus para continuar.'
    '10. Homologacao GUI com usuario comum/UAC em VM limpa ainda pendente.'
  ) | Set-Content -LiteralPath (Join-Path $Payload 'LEIA-ME.txt') -Encoding UTF8
  Get-ChildItem -LiteralPath $Payload -File | ForEach-Object {
    [PSCustomObject]@{
      File = $_.Name
      SHA256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }
  } | Export-Csv -LiteralPath $Manifest -NoTypeInformation -Encoding UTF8
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::CreateFromDirectory(
    $Payload, $Zip, [System.IO.Compression.CompressionLevel]::Optimal, $false
  )
  $sha = (Get-FileHash -LiteralPath $Zip -Algorithm SHA256).Hash
  @(
    "Version=$Version"
    "SourceCommit=$SourceCommit"
    "Package=$(Split-Path -Path $Zip -Leaf)"
    "PackageSHA256=$sha"
    "SoftwareSHA256=3AC5BAC4B6AD211395C8C98FC9BA0E220517105C70F30003A818E36E588E8BA9"
    "SoftwareURL=https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/1.5.3-drginfo.1/DRGinfo-AcessoRemoto-windows-x64.zip"
    "Authenticode=UNSIGNED_PROVISIONAL"
  ) | Set-Content -LiteralPath $Info -Encoding ASCII
  Write-Host "PACOTE: $Zip"
  Write-Host "SHA256: $sha"
  Write-Host "MANIFESTO: $Manifest"
  Write-Host 'Instalador grafico consolidado; teste de UAC em VM limpa permanece pendente.'
} catch {
  $details = $_.Exception.Message
  # Nao conservar releases incompletas, mas preservar releases anteriores.
  if (Test-Path -LiteralPath $ReleaseRoot) {
    Remove-Item -LiteralPath $ReleaseRoot -Recurse -Force
  }
  throw $details
}
