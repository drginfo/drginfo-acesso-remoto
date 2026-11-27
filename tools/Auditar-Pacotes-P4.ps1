#Requires -Version 5.1
<#
.SYNOPSIS
  Auditoria somente leitura dos pacotes DRGinfo P4 offline e portatil.
.DESCRIPTION
  Confere hashes do ZIP externo, estrutura interna, integridade da fonte
  do instalador offline e manifesto de distribuicao de cada modalidade.
  Nenhum executavel ou script contido nos pacotes e executado.
  Cria somente um relatorio TXT na pasta escolhida.
#>
[CmdletBinding()]
param(
  [string]$PacotesDir = 'C:\DRGinfo-P4-Teste\DRGinfo-Pacotes-1.0.0-p4-lab1',
  [string]$SoftwareSha256 = '926FAA9759236E18D4F5791A4A3BE76F0C96973676904F6F5FE08D8AA50B533A',
  [string]$OfflineSha256 = 'A64327D732CA7C81736242CB995BD26626DBF23A8B059D5DFDF8ED910F35E49B',
  [string]$PortatilSha256 = '46DEDF2D9497E940D2A35FFB81A142EAA6CAACFC57361500AB5505BBD1CFFC2D'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root = (Resolve-Path -LiteralPath $PacotesDir -ErrorAction Stop).Path
$report = Join-Path $root 'AUDITORIA-PACOTES-DRGinfo-P4.txt'
$lines = New-Object System.Collections.Generic.List[string]
$issues = New-Object System.Collections.Generic.List[string]
function Log([string]$Text) {
  Write-Host $Text
  $lines.Add($Text)
}
function Assert-HashFile([string]$Path,[string]$Expected) {
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Ausente: $Path" }
  $actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
  if ($actual -ne $Expected.ToUpperInvariant()) { throw "SHA256 incorreto: $Path : $actual" }
  Log "[OK] SHA256: $(Split-Path $Path -Leaf) = $actual"
}
function Normalize-ZipPath([string]$Name) {
  $canonical = $Name.Replace('\','/')
  if (-not $canonical -or
      $canonical.StartsWith('/') -or
      $canonical -match '^[A-Za-z]:' -or
      $canonical.Contains(':') -or
      @($canonical.Split('/') | Where-Object { $_ -eq '..' -or $_ -eq '.' -or $_ -eq '' }).Count -gt 0) {
    throw "Entrada ZIP insegura: $Name"
  }
  return $canonical
}
function Get-Entry([System.IO.Compression.ZipArchive]$Archive,[string]$Name) {
  $expected = Normalize-ZipPath $Name
  $matches = @($Archive.Entries | Where-Object {
    (($_.FullName).Replace('\','/')) -ceq $expected
  })
  if ($matches.Count -ne 1) { throw "Entrada ausente ou duplicada: $Name" }
  return $matches[0]
}
function Get-HashStream([System.IO.Stream]$Stream) {
  $sha = [Security.Cryptography.SHA256]::Create()
  try {
    return ([BitConverter]::ToString($sha.ComputeHash($Stream))).Replace('-','')
  } finally {
    $sha.Dispose()
  }
}
function Assert-Manifest([System.IO.Compression.ZipArchive]$Archive) {
  $manifest = Get-Entry $Archive 'manifesto-distribuicao-sha256.csv'
  $stream = $manifest.Open()
  $reader = New-Object System.IO.StreamReader($stream,[Text.Encoding]::UTF8)
  try { $text = $reader.ReadToEnd() } finally { $reader.Dispose() }
  $items = @($text | ConvertFrom-Csv)
  if ($items.Count -eq 0) { throw 'Manifesto sem entradas' }
  $seen = @{}
  foreach ($item in $items) {
    $name = Normalize-ZipPath ([string]$item.Arquivo)
    if ($seen.ContainsKey($name)) {
      throw "Caminho repetido: $name"
    }
    $seen[$name] = $true
    $expected = [string]$item.SHA256
    if ($expected -notmatch '^[0-9a-fA-F]{64}$') { throw "SHA invalido no manifesto: $name" }
    $entry = Get-Entry $Archive $name
    $s = $entry.Open()
    try { $actual = Get-HashStream $s } finally { $s.Dispose() }
    if ($actual -ne $expected.ToUpperInvariant()) { throw "SHA divergente: $name" }
  }
  $files = @($Archive.Entries | Where-Object { -not $_.FullName.EndsWith('/') -and $_.FullName -ne 'manifesto-distribuicao-sha256.csv' })
  foreach ($file in $files) {
    if (-not $seen.ContainsKey((Normalize-ZipPath $file.FullName))) { throw "Fora do manifesto: $($file.FullName)" }
  }
  Log "[OK] Manifesto completo: $($items.Count)/$($files.Count) arquivos"
}
try {
  Log "DRGinfo P4 | Auditoria em $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  Log "Diretorio: $root"
  $offline = Join-Path $root 'DRGinfo-Instalador-Offline-Windows-x64.zip'
  $portatil = Join-Path $root 'DRGinfo-Portatil-Windows-x64.zip'
  Assert-HashFile $offline $OfflineSha256
  Assert-HashFile $portatil $PortatilSha256
  foreach ($entry in @(@($offline,'OFFLINE'),@($portatil,'PORTATIL'))) {
    $zipPath = [string]$entry[0]
    $label = [string]$entry[1]
    $archive = [IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
      $names = @($archive.Entries | ForEach-Object {
        $name = $_.FullName
        if ($name.EndsWith('/') -or $name.EndsWith('\')) {
          $name = $name.TrimEnd('/','\')
        }
        Normalize-ZipPath $name
      })
      if (@($names | Select-Object -Unique -CaseSensitive).Count -ne $names.Count) {
        throw "Entradas duplicadas apos normalizacao: $label"
      }
      Assert-Manifest $archive
      if ($label -eq 'OFFLINE') {
        foreach ($name in @('instalador-drginfo.cmd','Interface-DRGinfo-AcessoRemoto.ps1','Instalar-DRGinfo-AcessoRemoto.ps1','Desinstalar-DRGinfo-AcessoRemoto.ps1','release-config.psd1','logo-drginfo.png')) {
          [void](Get-Entry $archive $name)
        }
        $nested = Get-Entry $archive 'DRGinfo-AcessoRemoto-windows-x64.zip'
        $stream = $nested.Open()
        try { $actual = Get-HashStream $stream } finally { $stream.Dispose() }
        if ($actual -ne $SoftwareSha256.ToUpperInvariant()) { throw 'Software embutido no offline diverge do ZIP P4 homologado' }
        Log "[OK] OFFLINE: GUI, motor, logo e ZIP original P4 confirmados"
      } else {
        foreach ($name in @('DRGinfo Acesso Remoto.exe','librustdesk.dll','flutter_windows.dll','LICENCE','data/app.so','data/icudtl.dat')) {
          [void](Get-Entry $archive $name)
        }
        Log "[OK] PORTATIL: executavel, bibliotecas, dados e LICENCE confirmados"
      }
    } finally { $archive.Dispose() }
  }
  Log 'RESULTADO=APROVADO_ESTRUTURALMENTE; HOMOLOGACAO_GUI_PENDENTE'
} catch {
  $issues.Add($_.Exception.Message)
  Log "[FALHA] $($_.Exception.Message)"
  Log 'RESULTADO=REPROVADO'
} finally {
  $lines | Set-Content -LiteralPath $report -Encoding UTF8
  Write-Host "RELATORIO=$report"
}
if ($issues.Count -gt 0) { exit 1 }
