#Requires -Version 5.1
<#
.SYNOPSIS
  Gera pacotes separados: instalador offline com servico e edicao portatil.
.DESCRIPTION
  Utiliza exclusivamente ZIP comercial previamente validado, sem recompilar.
  Preparacao executada numa estacao com Internet. Uso posterior sem download.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$SoftwareZip,
  [Parameter(Mandatory=$true)][string]$OutputRoot
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$Version = '1.5.3-drginfo.2'
$InstallerVersion = '1.0.0-gui6-offline'
$ExpectedHash = '7770F8D6B61217568124BBB2FB96D482621BA52FBF1C8CEFF2CD31A2EF776525'
$SourceCommit = '716b7de3985bdc8a2738129eaadc56b21b07e99f'
$BaseUrl = "https://raw.githubusercontent.com/drginfo/drginfo-acesso-remoto/$SourceCommit/"
$SoftwareUrl = "https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/$Version/DRGinfo-AcessoRemoto-windows-x64.zip"
Add-Type -AssemblyName System.IO.Compression.FileSystem
$src = (Resolve-Path -LiteralPath $SoftwareZip -ErrorAction Stop).Path
if ((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash -ne $ExpectedHash) {
  throw 'O ZIP indicado nao corresponde ao software DRGinfo homologado (SHA256).'
}
$root = (Resolve-Path -LiteralPath $OutputRoot -ErrorAction Stop).Path
$out = Join-Path $root "DRGinfo-Pacotes-$InstallerVersion"
if (Test-Path -LiteralPath $out) { throw "Release ja existe: $out" }
$offline = Join-Path $out 'stage-offline'
$portable = Join-Path $out 'stage-portatil'
$offlineZip = Join-Path $out 'DRGinfo-Instalador-Offline-Windows-x64.zip'
$portableZip = Join-Path $out 'DRGinfo-Portatil-Windows-x64.zip'
function Assert-SafeZip([string]$Path) {
  $arc = [IO.Compression.ZipFile]::OpenRead($Path)
  try {
    if ($arc.Entries.Count -gt 10000) { throw 'Entradas ZIP em excesso.' }
    $size = [long]0
    foreach ($e in $arc.Entries) {
      $n = $e.FullName.Replace('\','/')
      if ($n.StartsWith('/') -or $n -match '^[a-zA-Z]:' -or
          $n.Split('/') -contains '..' -or $n.Contains(':')) {
        throw "Entrada ZIP insegura: $n"
      }
      if ((($e.ExternalAttributes -shr 16) -band 61440) -eq 40960) {
        throw 'ZIP contem link simbolico.'
      }
      $size += $e.Length
      if ($size -gt 1073741824) { throw 'ZIP excede 1 GiB.' }
    }
  } finally { $arc.Dispose() }
}
try {
  Assert-SafeZip $src
  New-Item -ItemType Directory -Path $offline,$portable -Force | Out-Null

  # Front-end/engine vindo de commit fixo: mesmos scripts gui6 e rollback.
  $files = [ordered]@{
    'instalador-drginfo.cmd' = 'install/windows/instalador-drginfo.cmd'
    'Interface-DRGinfo-AcessoRemoto.ps1' = 'install/windows/Interface-DRGinfo-AcessoRemoto.ps1'
    'Instalar-DRGinfo-AcessoRemoto.ps1' = 'install/windows/Instalar-DRGinfo-AcessoRemoto.ps1'
    'Desinstalar-DRGinfo-AcessoRemoto.ps1' = 'install/windows/Desinstalar-DRGinfo-AcessoRemoto.ps1'
    'logo-drginfo.png' = 'flutter/assets/drginfo-logo.png'
  }
  foreach ($entry in $files.GetEnumerator()) {
    $target = Join-Path $offline $entry.Key
    Invoke-WebRequest -Uri ($BaseUrl + $entry.Value) -OutFile $target -UseBasicParsing -MaximumRedirection 0 -TimeoutSec 60
    if ((Get-Item -LiteralPath $target).Length -le 20) { throw "Codigo incompleto: $($entry.Key)" }
  }
  foreach ($file in @('Interface-DRGinfo-AcessoRemoto.ps1','Instalar-DRGinfo-AcessoRemoto.ps1','Desinstalar-DRGinfo-AcessoRemoto.ps1')) {
    $tokens=$null; $errors=$null
    [void][Management.Automation.Language.Parser]::ParseFile((Join-Path $offline $file),[ref]$tokens,[ref]$errors)
    if (@($errors).Count -gt 0) { throw "Erro de sintaxe em $file : $($errors[0].Message)" }
  }
  @(
    '@{'
    '  Offline = $true'
    "  SoftwareUrl = '$SoftwareUrl'"
    "  SoftwareSha256 = '$ExpectedHash'"
    "  SoftwareVersion = '$Version'"
    '}'
  ) | Set-Content -LiteralPath (Join-Path $offline 'release-config.psd1') -Encoding ASCII
  Copy-Item -LiteralPath $src -Destination (Join-Path $offline 'DRGinfo-AcessoRemoto-windows-x64.zip')
  @(
    'DRGinfo Acesso Remoto - Instalador OFFLINE Windows x64'
    'Extraia o pacote e execute instalador-drginfo.cmd.'
    'Instala sem baixar o cliente da Internet. Acesso remoto exige rede.'
    'Solicita UAC para registrar servico Automatic e atalhos Windows.'
    'Desinstale pelo aplicativo em Configuracoes > Aplicativos instalados.'
    'Software nao assinado digitalmente; nao desabilite UAC, SmartScreen ou antivirus.'
    'Distribuicao baseada no RustDesk OSS AGPL-3.0; consulte LICENCE no ZIP de software.'
    "Versao: $Version; SHA256 software: $ExpectedHash"
  ) | Set-Content -LiteralPath (Join-Path $offline 'LEIA-ME-OFFLINE.txt') -Encoding UTF8

  # Portatil: preservar EXE, DLLs, assets e licença; apenas executar.
  [IO.Compression.ZipFile]::ExtractToDirectory($src,$portable)
  foreach ($rel in @('DRGinfo Acesso Remoto.exe','librustdesk.dll','flutter_windows.dll','LICENCE','manifesto-sha256.csv','data\app.so','data\icudtl.dat','data\flutter_assets')) {
    if (-not (Test-Path -LiteralPath (Join-Path $portable $rel))) { throw "Portatil incompleto: $rel" }
  }
  if (Test-Path -LiteralPath (Join-Path $portable 'rustdesk.exe')) {
    throw 'Executavel legado no portatil.'
  }
  @(
    '@echo off'
    'setlocal'
    'set "BASE=%~dp0"'
    'if not exist "%BASE%DRGinfo Acesso Remoto.exe" exit /b 1'
    'start "" /D "%BASE%" "%BASE%DRGinfo Acesso Remoto.exe"'
    'exit /b 0'
  ) | Set-Content -LiteralPath (Join-Path $portable 'Abrir-DRGinfo-Portatil.cmd') -Encoding ASCII
  @(
    'DRGinfo Acesso Remoto - Portatil Windows 10/11 x64'
    'Extraia todo o ZIP e execute Abrir-DRGinfo-Portatil.cmd.'
    'Launcher nao instala, nao registra servico e nao exige UAC.'
    'Nao usar simultaneamente ao servico DRGinfo ja instalado.'
    'Portatil descreve a distribuicao sem instalador; NAO garante ausencia de'
    'dados no perfil Windows: o proprio aplicativo pode gerar logs/configuracoes.'
    'ID/Relay exige conectividade; recursos de elevacao podem pedir UAC.'
    'Licenca AGPL-3.0 em LICENCE, codigo-fonte em github.com/drginfo/drginfo-acesso-remoto.'
  ) | Set-Content -LiteralPath (Join-Path $portable 'LEIA-ME-PORTATIL.txt') -Encoding UTF8

  foreach ($folder in @($offline,$portable)) {
    $manifest = Join-Path $folder 'manifesto-distribuicao-sha256.csv'
    Get-ChildItem -LiteralPath $folder -File -Recurse |
      Where-Object { $_.FullName -ne $manifest } |
      ForEach-Object {
        [PSCustomObject]@{
          Arquivo=$_.FullName.Substring($folder.Length).TrimStart('\')
          SHA256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
        }
      } | Export-Csv -LiteralPath $manifest -NoTypeInformation -Encoding UTF8
  }
  [IO.Compression.ZipFile]::CreateFromDirectory($offline,$offlineZip,[IO.Compression.CompressionLevel]::Optimal,$false)
  [IO.Compression.ZipFile]::CreateFromDirectory($portable,$portableZip,[IO.Compression.CompressionLevel]::Optimal,$false)
  Assert-SafeZip $offlineZip
  Assert-SafeZip $portableZip
  @(
    "Version=$Version"
    "SourceCommit=$SourceCommit"
    "SoftwareSHA256=$ExpectedHash"
    "OfflineZIP_SHA256=$((Get-FileHash -LiteralPath $offlineZip -Algorithm SHA256).Hash)"
    "PortableZIP_SHA256=$((Get-FileHash -LiteralPath $portableZip -Algorithm SHA256).Hash)"
    'Estado=PREPARADO_NAO_HOMOLOGADO'
  ) | Set-Content -LiteralPath (Join-Path $out 'release.txt') -Encoding UTF8

  Write-Host "OFFLINE=$offlineZip"
  Write-Host ("SHA256_OFFLINE="+(Get-FileHash -LiteralPath $offlineZip -Algorithm SHA256).Hash)
  Write-Host "PORTATIL=$portableZip"
  Write-Host ("SHA256_PORTATIL="+(Get-FileHash -LiteralPath $portableZip -Algorithm SHA256).Hash)
  Write-Host "MANIFESTO=$out\release.txt"
  Write-Host 'GERACAO CONCLUIDA. TESTES DE INSTALACAO E MODO PORTATIL AINDA PENDENTES.'
} catch {
  if (Test-Path -LiteralPath $out) {
    Remove-Item -LiteralPath $out -Recurse -Force -ErrorAction SilentlyContinue
  }
  throw
}
