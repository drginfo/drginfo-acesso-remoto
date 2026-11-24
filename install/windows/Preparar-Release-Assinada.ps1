#Requires -Version 5.1
<#
.SYNOPSIS
  Prepara release assinada da DRGinfo a partir do pacote portatil homologado.
.DESCRIPTION
  Nao faz upload; nunca exporta chave privada; preserva release no ProgramData.
  Requer certificado de Code Signing confiavel acessivel ao usuario e SignTool do Windows SDK.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$SourceDirectory,
  [Parameter(Mandatory=$true)][ValidatePattern('^[0-9a-fA-F]{40}$')][string]$CertificateThumbprint,
  [Parameter(Mandatory=$true)][ValidatePattern('^[a-zA-Z0-9][a-zA-Z0-9._-]{0,60}$')][string]$Version,
  [string]$TimestampUrl = 'http://timestamp.digicert.com'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Join-Path $env:ProgramData 'DRGinfo\AcessoRemoto\releases\windows-x64'
$release = Join-Path $root $Version
$payload = Join-Path $release 'payload'
$zipPath = Join-Path $release 'DRGinfo-AcessoRemoto-windows-x64.zip'
$manifest = Join-Path $release 'release-sha256.txt'
$thumb = $CertificateThumbprint.ToUpperInvariant()
$cert = Get-Item -LiteralPath ("Cert:\LocalMachine\My\" + $thumb) -ErrorAction SilentlyContinue
if (-not $cert) {
  $cert = Get-Item -LiteralPath ("Cert:\CurrentUser\My\" + $thumb) -ErrorAction SilentlyContinue
}
if (-not $cert -or -not $cert.HasPrivateKey) { throw 'Certificado de Code Signing com chave privada nao localizado.' }
if ($cert.NotAfter -le (Get-Date) -or $cert.NotBefore -gt (Get-Date)) { throw 'Certificado de Code Signing expirado ou ainda nao valido.' }
$eku = @($cert.EnhancedKeyUsageList | ForEach-Object { $_.ObjectId.Value })
if ($eku -notcontains '1.3.6.1.5.5.7.3.3') { throw 'Certificado nao possui EKU Code Signing.' }
$signToolCommand = Get-Command signtool.exe -ErrorAction SilentlyContinue
if (-not $signToolCommand) { throw 'signtool.exe nao encontrado. Instalar Windows SDK.' }
$signTool = $signToolCommand.Source
$source = (Resolve-Path -LiteralPath $SourceDirectory).ProviderPath
foreach ($rel in @('rustdesk.exe','librustdesk.dll','flutter_windows.dll','data\app.so','data\icudtl.dat','data\flutter_assets')) {
  if (-not (Test-Path -LiteralPath (Join-Path $source $rel))) { throw "Componente ausente: $rel" }
}
if (Test-Path -LiteralPath (Join-Path $source 'custom.txt')) { throw 'Pacote personalizado nao pode conter custom.txt.' }
if (Test-Path -LiteralPath $release) { throw "Release existente: $release. Nao sobrescrever." }
New-Item -ItemType Directory -Path $payload -Force | Out-Null
try {
  foreach ($item in Get-ChildItem -LiteralPath $source -Force) {
    if ($item.Name -ieq 'custom.txt' -or $item.Extension -in @('.ps1','.cmd','.bat')) { continue }
    Copy-Item -LiteralPath $item.FullName -Destination $payload -Recurse -Force
  }
  foreach ($filename in @('rustdesk.exe','librustdesk.dll')) {
    $bin = Join-Path $payload $filename
    & $signTool sign /sha1 $thumb /fd SHA256 /tr $TimestampUrl /td SHA256 $bin | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "SignTool falhou: $filename" }
    $signature = Get-AuthenticodeSignature -LiteralPath $bin
    if ($signature.Status -ne 'Valid' -or -not $signature.SignerCertificate -or
        $signature.SignerCertificate.Thumbprint.ToUpperInvariant() -ne $thumb) {
      throw "Assinatura Authenticode invalida: $filename"
    }
  }
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::CreateFromDirectory($payload, $zipPath, [IO.Compression.CompressionLevel]::Optimal, $false)
  $hash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash
  @(
    "Version=$Version"
    "SHA256=$hash"
    "CertificateThumbprint=$thumb"
    "Package=$(Split-Path $zipPath -Leaf)"
    "CreatedUTC=$([DateTime]::UtcNow.ToString('o'))"
  ) | Set-Content -LiteralPath $manifest -Encoding ASCII
  Write-Host "RELEASE CRIADA: $zipPath"
  Write-Host "MANIFESTO: $manifest"
  Write-Host "SHA256: $hash"
  Write-Host 'Ainda nao publicada na VPS. Nao distribuir ate verificar HTTPS e assinatura.'
} catch {
  $failure = $_.Exception.Message
  # Deixar a pasta de release para analise, mas remover ZIP incompleto.
  if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
  throw $failure
}
