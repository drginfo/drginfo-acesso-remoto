#Requires -Version 5.1
<#
.SYNOPSIS
  Gera ZIP imutavel de distribuicao DRGinfo a partir do artifact x64 do GitHub.
.DESCRIPTION
  Le arquivos locais; valida identidade e estrutura; nunca publica na VPS.
.EXAMPLE
  .\Gerar-Release-DRGinfo-Windows.ps1 -ArtifactDir 'C:\Temp\DRGinfo-Acesso-Remoto-Windows-x64' -Version '1.5.3-drginfo.2'
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$ArtifactDir,
  [Parameter(Mandatory=$true)][ValidatePattern('^[0-9A-Za-z][0-9A-Za-z._-]{0,63}$')][string]$Version,
  [string]$OutputRoot = (Join-Path $env:USERPROFILE 'Downloads')
)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$source=(Resolve-Path -LiteralPath $ArtifactDir -ErrorAction Stop).Path
$exe=Join-Path $source 'DRGinfo Acesso Remoto.exe'
if(-not(Test-Path -LiteralPath $exe -PathType Leaf)){throw 'Artifact DRGinfo invalido: exe corporativo ausente.'}
if(Test-Path -LiteralPath (Join-Path $source 'rustdesk.exe')){throw 'EXE legado detectado no artifact comercial.'}
foreach($f in @('librustdesk.dll','flutter_windows.dll','LICENCE','manifesto-sha256.csv','data\flutter_assets')){
  if(-not(Test-Path -LiteralPath (Join-Path $source $f))){throw "Artifact incompleto: $f"}
}
if(-not(Test-Path -LiteralPath $OutputRoot -PathType Container)){throw 'Diretorio de saida ausente.'}
$releaseDir=Join-Path $OutputRoot ("DRGinfo-Software-"+$Version)
if(Test-Path -LiteralPath $releaseDir){throw "Release ja existente: $releaseDir"}
New-Item -ItemType Directory -Path $releaseDir -ErrorAction Stop | Out-Null
try{
  $zip=Join-Path $releaseDir 'DRGinfo-AcessoRemoto-windows-x64.zip'
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [IO.Compression.ZipFile]::CreateFromDirectory($source,$zip,[IO.Compression.CompressionLevel]::Optimal,$false)
  $sha=(Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
  $exeSha=(Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash
  $uri="https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/$Version/DRGinfo-AcessoRemoto-windows-x64.zip"
  @("SoftwareVersion=$Version","SoftwareURL=$uri","SoftwareSHA256=$sha","ExecutableSHA256=$exeSha","SourceArtifact=$source","Status=PREPARED_NOT_PUBLISHED") |
    Set-Content -LiteralPath (Join-Path $releaseDir 'release.txt') -Encoding UTF8
  Write-Host "PACOTE: $zip"
  Write-Host "SOFTWARE_URL_PREVISTA: $uri"
  Write-Host "SHA256 ZIP: $sha"
  Write-Host 'STATUS: somente preparado, ainda nao publicado; nao gerar gui5 antes de confirmar HTTPS e hash.'
}catch{
  if(Test-Path -LiteralPath $releaseDir){Remove-Item -LiteralPath $releaseDir -Force -Recurse -ErrorAction SilentlyContinue}
  throw
}
