#Requires -Version 5.1
<#
  DRGinfo Acesso Remoto - Preparacao de release NAO ASSINADA.
  Para uso provisório e controlado, sem sobrescrever artefato homologado.
  Executar Windows PowerShell 5.1 x64.
#>
[CmdletBinding()]
param(
  [string]$SourceDirectory = 'C:\DRGinfo-Teste',
  [Parameter(Mandatory=$true)][ValidatePattern('^[A-Za-z0-9._-]{1,60}$')][string]$Version
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Join-Path $env:ProgramData 'DRGinfo\AcessoRemoto\releases\windows-x64'
$release = Join-Path $root $Version
$payload = Join-Path $release 'payload'
$zip = Join-Path $release 'DRGinfo-AcessoRemoto-windows-x64.zip'
$manifest = Join-Path $release 'release-sha256.txt'
$source = (Resolve-Path -LiteralPath $SourceDirectory).ProviderPath
foreach ($rel in @('rustdesk.exe','librustdesk.dll','flutter_windows.dll','data\app.so','data\icudtl.dat','data\flutter_assets')) {
  if (-not (Test-Path -LiteralPath (Join-Path $source $rel))) { throw "Componente ausente: $rel" }
}
if (Test-Path -LiteralPath (Join-Path $source 'custom.txt')) { throw 'custom.txt nao permitido.' }
if (Test-Path -LiteralPath $release) { throw "A release ja existe, nao sobrescrever: $release" }
New-Item -ItemType Directory -Force -Path $payload | Out-Null
foreach ($item in Get-ChildItem -LiteralPath $source -Force) {
  if ($item.Name -ieq 'custom.txt' -or $item.Extension -in @('.ps1','.cmd','.bat')) { continue }
  Copy-Item -LiteralPath $item.FullName -Destination $payload -Recurse
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory($payload, $zip, [IO.Compression.CompressionLevel]::Optimal, $false)
$hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
@(
  "Version=$Version"
  "SHA256=$hash"
  "Package=$(Split-Path $zip -Leaf)"
  "CodeSigning=UNSIGNED"
  "SourceBuild=45468695045"
  "SourceCommit=2dfc3bdd05452700475cc958d1b2ff7e3fb718ad"
  "CreatedUTC=$([DateTime]::UtcNow.ToString('o'))"
) | Set-Content -LiteralPath $manifest -Encoding ASCII
Write-Host "RELEASE: $zip"
Write-Host "MANIFEST: $manifest"
Write-Host "SHA256: $hash"
Write-Warning 'Sem assinatura Authenticode. Usar somente distribuicao controlada e hash confiavel.'
