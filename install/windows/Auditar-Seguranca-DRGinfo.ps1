#Requires -Version 5.1
# DRGinfo - auditoria somente leitura (ACLs, servico, assinatura e ARP).
# Executar com -Saida apontando para pasta existente. Revisar dados antes de compartilhar.
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Saida)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $Saida -PathType Container)) { throw 'Pasta de saida nao existe.' }
$Saida = (Resolve-Path -LiteralPath $Saida).Path
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$Relatorio = Join-Path $Saida "DRGinfo-Auditoria-Windows-$Stamp.md"
$App = 'DRGinfo Acesso Remoto'
$Dir = Join-Path $env:ProgramFiles $App
$Exe = Join-Path $Dir "$App.exe"
$Svc = Get-CimInstance Win32_Service -Filter "Name='DRGinfo Acesso Remoto'" -ErrorAction SilentlyContinue
$Arp = Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DRGinfoAcessoRemoto' -ErrorAction SilentlyContinue
$Desktop = Join-Path ([Environment]::GetFolderPath('CommonDesktopDirectory')) "$App.lnk"
$Menu = Join-Path (Join-Path ([Environment]::GetFolderPath('CommonPrograms')) 'DRGinfo') "$App.lnk"
$Hash = if (Test-Path -LiteralPath $Exe -PathType Leaf) { (Get-FileHash -LiteralPath $Exe -Algorithm SHA256).Hash } else { 'AUSENTE' }
$Sig = if (Test-Path -LiteralPath $Exe -PathType Leaf) { [string](Get-AuthenticodeSignature -LiteralPath $Exe).Status } else { 'AUSENTE' }
$AclExe = if (Test-Path -LiteralPath $Dir -PathType Container) { (icacls.exe $Dir 2>&1 | Out-String).Trim() } else { 'AUSENTE' }
$DataDir = Join-Path $env:ProgramData 'DRGinfo\AcessoRemoto'
$AclData = if (Test-Path -LiteralPath $DataDir -PathType Container) { (icacls.exe $DataDir 2>&1 | Out-String).Trim() } else { 'AUSENTE' }
@(
  '# Auditoria Windows DRGinfo - somente leitura'
  "Data: $(Get-Date -Format o)"
  "Host: $env:COMPUTERNAME"
  "EXE: $Exe"
  "SHA256: $Hash"
  "Authenticode: $Sig"
  "ServiceState: $(if($Svc){$Svc.State}else{'AUSENTE'})"
  "ServiceStartMode: $(if($Svc){$Svc.StartMode}else{'AUSENTE'})"
  "ServiceStartName: $(if($Svc){$Svc.StartName}else{'AUSENTE'})"
  "ServicePath: $(if($Svc){$Svc.PathName}else{'AUSENTE'})"
  "ARPVersion: $(if($Arp){$Arp.DisplayVersion}else{'AUSENTE'})"
  "DesktopShortcut: $(Test-Path -LiteralPath $Desktop -PathType Leaf)"
  "StartMenuShortcut: $(Test-Path -LiteralPath $Menu -PathType Leaf)"
  '## ACL do programa'
  $AclExe
  '## ACL de ProgramData'
  $AclData
  '## Aviso: verificar permissao de escrita para Users, Authenticated Users, Everyone, SIDs e herancas; redigir nomes de contas pessoais.'
) | Set-Content -LiteralPath $Relatorio -Encoding UTF8
Write-Host "RELATORIO=$Relatorio"
Write-Host 'SOMENTE_LEITURA=SIM'
