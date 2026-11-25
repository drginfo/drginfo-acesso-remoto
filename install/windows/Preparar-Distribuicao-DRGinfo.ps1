#Requires -Version 5.1
# DRGinfo - distribuição Windows x64, sem alterar DLLs internas.
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Source,[Parameter(Mandatory=$true)][string]$Destination)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$src=(Resolve-Path -LiteralPath $Source -ErrorAction Stop).Path
$dst=[IO.Path]::GetFullPath($Destination)
if(Test-Path -LiteralPath $dst){throw "Diretorio existente: $dst"}
foreach($rel in @('rustdesk.exe','librustdesk.dll','flutter_windows.dll','data\app.so','data\icudtl.dat','data\flutter_assets')){
  if(-not(Test-Path -LiteralPath (Join-Path $src $rel))){throw "Componente obrigatorio ausente: $rel"}
}
try{
  Copy-Item -LiteralPath $src -Destination $dst -Recurse -ErrorAction Stop
  Rename-Item -LiteralPath (Join-Path $dst 'rustdesk.exe') -NewName 'DRGinfo Acesso Remoto.exe' -ErrorAction Stop
  @('DRGinfo Acesso Remoto - Windows x64','Pacote de homologacao: extrair todo conteudo antes de executar.','Execute DRGinfo Acesso Remoto.exe.','Projeto derivado do RustDesk OSS AGPL-3.0. Consulte LICENCE e codigo-fonte correspondente.','Nomes de bibliotecas internas preservados por compatibilidade.','Build ainda sem assinatura Authenticode.') | Set-Content -LiteralPath (Join-Path $dst 'LEIA-ME-DRGinfo.txt') -Encoding UTF8
  Get-ChildItem -LiteralPath $dst -Recurse -File | ForEach-Object {
    [PSCustomObject]@{Arquivo=$_.FullName.Substring($dst.Length).TrimStart('\');SHA256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}
  } | Export-Csv -LiteralPath (Join-Path $dst 'manifesto-sha256.csv') -NoTypeInformation -Encoding UTF8
  Write-Host "PACOTE: $dst"
  Write-Host ('SHA256 EXE: '+(Get-FileHash -LiteralPath (Join-Path $dst 'DRGinfo Acesso Remoto.exe') -Algorithm SHA256).Hash)
}catch{
  if(Test-Path -LiteralPath $dst){Remove-Item -LiteralPath $dst -Recurse -Force -ErrorAction SilentlyContinue}
  throw
}
