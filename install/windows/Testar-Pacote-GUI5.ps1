#Requires -Version 5.1
<#
.SYNOPSIS
  Auditoria read-only do pacote gui5 antes de instalar.
.DESCRIPTION
  Valida manifesto, origem HTTPS, sintaxe PowerShell e ZIP publicado (SHA256).
  Nao altera aplicativos, servicos, registro ou perfis. Gera log na pasta local.
#>
[CmdletBinding()]
param(
  [string]$InstallerDir = '.'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$base=(Resolve-Path -LiteralPath $InstallerDir -ErrorAction Stop).Path
$manifest=Join-Path $base 'release-config.psd1'
if(-not(Test-Path -LiteralPath $manifest -PathType Leaf)){throw 'Manifesto release-config.psd1 ausente'}
$m=Import-PowerShellDataFile -LiteralPath $manifest
$version=[string]$m.SoftwareVersion
$url=[string]$m.SoftwareUrl
$sha=[string]$m.SoftwareSha256
if($sha -notmatch '^[A-Fa-f0-9]{64}$'){throw 'SHA256 invalido'}
if($version -notmatch '^[0-9A-Za-z][0-9A-Za-z._-]{0,63}$'){throw 'Versao invalida'}
$expected="https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/$version/DRGinfo-AcessoRemoto-windows-x64.zip"
if($url -cne $expected){throw "URL diverge da versao esperada: $url"}
if($version -eq '1.5.3-drginfo.1'){throw 'O gui5 aponta para binario antigo'}
foreach($file in @('instalador-drginfo.cmd','Interface-DRGinfo-AcessoRemoto.ps1','Instalar-DRGinfo-AcessoRemoto.ps1','Desinstalar-DRGinfo-AcessoRemoto.ps1','logo-drginfo.png')){
 if(-not(Test-Path -LiteralPath (Join-Path $base $file) -PathType Leaf)){throw "Falta componente gui5: $file"}
}
foreach($file in @('Interface-DRGinfo-AcessoRemoto.ps1','Instalar-DRGinfo-AcessoRemoto.ps1','Desinstalar-DRGinfo-AcessoRemoto.ps1')){
 $tokens=$null;$errors=$null
 [void][Management.Automation.Language.Parser]::ParseFile((Join-Path $base $file),[ref]$tokens,[ref]$errors)
 if(@($errors).Count){throw "Erro PowerShell em $file : $($errors[0].Message)"}
}
$zip=Join-Path $env:TEMP ("DRGinfo-gui5-verify-"+[Guid]::NewGuid().ToString('N')+".zip")
try{
 Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing -MaximumRedirection 0 -TimeoutSec 240 -ErrorAction Stop
 $actual=(Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
 if($actual -ne $sha.ToUpperInvariant()){throw "SHA256 PUBLICO DIVERGENTE: $actual"}
 Write-Host "GUI5 VALIDADO: $version"
 Write-Host "ZIP=$url"
 Write-Host "SHA256=$actual"
 Write-Host 'Nenhuma instalacao foi alterada.'
}finally{
 Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
}
