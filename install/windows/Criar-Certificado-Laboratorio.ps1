#Requires -Version 5.1
<#
.SYNOPSIS
  Cria certificado autoassinado de Code Signing para laboratorio DRGinfo.
.DESCRIPTION
  Certificado gratuito apenas para ambientes controlados. Nao instala confianca,
  nao exporta chave privada e nao assina a release homologada.
#>
[CmdletBinding()]
param([switch]$ConfirmCreate)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not $ConfirmCreate) { throw 'Use -ConfirmCreate somente apos revisar politica de chaves.' }
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Requer Administrador.' }
$root = Join-Path $env:ProgramData 'DRGinfo\AcessoRemoto\certificados'
New-Item -ItemType Directory -Path $root -Force | Out-Null
$cert = New-SelfSignedCertificate -Type CodeSigningCert -Subject 'CN=DRGinfo Consultoria e Suporte' -CertStoreLocation 'Cert:\LocalMachine\My' -HashAlgorithm SHA256 -KeyAlgorithm RSA -KeyLength 3072 -KeyExportPolicy NonExportable -NotAfter (Get-Date).AddYears(2)
if (-not $cert) { throw 'Falha ao criar certificado.' }
$public = Join-Path $root 'DRGinfo-CodeSigning-laboratorio.cer'
Export-Certificate -Cert $cert -FilePath $public -Force | Out-Null
Write-Host "THUMBPRINT: $($cert.Thumbprint)"
Write-Host "CERTIFICADO PUBLICO: $public"
Write-Warning 'Certificado nao confiavel por padrao. Nao instalar raiz em computadores clientes automaticamente.'
Write-Warning 'Nao elimina automaticamente alertas do Windows SmartScreen.'
