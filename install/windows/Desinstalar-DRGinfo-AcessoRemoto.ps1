#Requires -Version 5.1
<#
.SYNOPSIS
  Remove somente a instalacao de homologacao DRGinfo Acesso Remoto.
.NOTES
  Executar com -ConfirmRemoval como Administrador.
  Preserva logs, manifesto e configuracoes do usuario.
#>
[CmdletBinding()]
param([Parameter(Mandatory = $true)][switch]$ConfirmRemoval)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$serviceName = 'DRGinfo Acesso Remoto'
$installDir = Join-Path $env:ProgramFiles $serviceName
$exe = Join-Path $installDir "$serviceName.exe"
$logDir = Join-Path $env:ProgramData 'DRGinfo\AcessoRemoto'
$logFile = Join-Path $logDir 'desinstalacao.log'

function Log([string]$s) {
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    $line = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $s
    Add-Content -LiteralPath $logFile -Value $line -Encoding UTF8
    Write-Host $line
}

try {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Abrir Windows PowerShell como Administrador.'
    }
    $service = Get-CimInstance Win32_Service -Filter "Name='DRGinfo Acesso Remoto'" -ErrorAction Stop
    if ($service) {
        # Fail closed if the registered service belongs to another executable.
        $bin = $service.PathName.Trim()
        if (-not $bin.StartsWith(('"' + $exe + '"'), [StringComparison]::OrdinalIgnoreCase)) {
            throw "Servico aponta para outro executavel. Remocao cancelada: $bin"
        }
        Log 'Parando servico DRGinfo Acesso Remoto.'
        if ($service.State -ne 'Stopped') {
            & "$env:SystemRoot\System32\sc.exe" stop $serviceName | Out-Null
            for ($i = 0; $i -lt 15; $i++) {
                Start-Sleep -Seconds 1
                $state = (Get-Service -Name $serviceName).Status
                if ($state -eq 'Stopped') { break }
            }
            if ((Get-Service -Name $serviceName).Status -ne 'Stopped') {
                throw 'Servico nao parou. Remocao cancelada.'
            }
        }
        & "$env:SystemRoot\System32\sc.exe" delete $serviceName | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Falha na remocao do servico: $LASTEXITCODE" }
        Log 'Registro do servico removido.'
    }
    if (Test-Path -LiteralPath $installDir) {
        if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
            throw 'Diretorio nao contem o executavel esperado. Remocao cancelada.'
        }
        Remove-Item -LiteralPath $installDir -Force -Recurse
        Log "Arquivos removidos: $installDir"
    }
    Log 'Concluido. Logs e dados de usuarios preservados.'
    exit 0
}
catch {
    Log ("ERRO: {0}" -f $_.Exception.Message)
    exit 1
}
