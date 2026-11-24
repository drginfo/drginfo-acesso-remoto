#Requires -Version 5.1
<#
.SYNOPSIS
  DRGinfo Acesso Remoto - instalador Windows x64 de homologacao.
.DESCRIPTION
  Instala os binarios PORTATEIS ja aprovados, sem recompilar e sem custom.txt.
  Nao substitui uma instalacao existente. Executar como Administrador.
  Registro do servico: Windows SCM, executavel --service.
  Log: C:\ProgramData\DRGinfo\AcessoRemoto\instalacao.log
  Rollback automatico apenas dos itens criados por esta execucao.
.EXAMPLE
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\DRGinfo-Teste\Instalar-DRGinfo-AcessoRemoto.ps1" -SourceDirectory "C:\DRGinfo-Teste"
#>
[CmdletBinding()]
param(
    [Parameter()][string]$SourceDirectory = 'C:\DRGinfo-Teste'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$AppName = 'DRGinfo Acesso Remoto'
$ServiceName = 'DRGinfo Acesso Remoto'
$InstallDir = Join-Path $env:ProgramFiles $AppName
$ExeName = "$AppName.exe"
$ExeDest = Join-Path $InstallDir $ExeName
$LogDir = Join-Path $env:ProgramData 'DRGinfo\AcessoRemoto'
$LogFile = Join-Path $LogDir 'instalacao.log'
$CreatedDir = $false
$CreatedService = $false

function Log([string]$Message, [string]$Level = 'INFO') {
    $line = '{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    Add-Content -LiteralPath $LogFile -Value $line -Encoding UTF8
    Write-Host $line
}

function Run-SC([string[]]$Arguments) {
    $output = & "$env:SystemRoot\System32\sc.exe" @Arguments 2>&1
    $code = $LASTEXITCODE
    if ($code -ne 0) {
        throw ("sc.exe {0} falhou (codigo {1}): {2}" -f $Arguments[0], $code, ($output | Out-String).Trim())
    }
    return $output
}

try {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    Log "Inicio da instalacao | Produto=$AppName | maquina=$env:COMPUTERNAME"
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Abrir Windows PowerShell como Administrador.'
    }
    if (-not [Environment]::Is64BitOperatingSystem -or -not [Environment]::Is64BitProcess) {
        throw 'Execute pelo Windows PowerShell x64 em Windows x64.'
    }

    $source = (Resolve-Path -LiteralPath $SourceDirectory).ProviderPath.TrimEnd('\')
    $exeSource = Join-Path $source 'rustdesk.exe'
    $mandatory = @(
        'rustdesk.exe', 'librustdesk.dll', 'flutter_windows.dll',
        'data\app.so', 'data\icudtl.dat', 'data\flutter_assets'
    )
    foreach ($item in $mandatory) {
        if (-not (Test-Path -LiteralPath (Join-Path $source $item))) {
            throw "Arquivo/recurso obrigatorio ausente: $item"
        }
    }
    if (Test-Path -LiteralPath (Join-Path $source 'custom.txt')) {
        throw 'Pacote invalido: custom.txt detectado. Esta edicao utiliza configuracao embarcada.'
    }
    if (Test-Path -LiteralPath $InstallDir) {
        throw "Ja existe uma pasta de instalacao DRGinfo: $InstallDir. Nao sobrescrever."
    }
    if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
        throw "Ja existe o servico $ServiceName. Nao sobrescrever."
    }
    # Compatibilidade: impedir conflito na instalacao homologada e preservar dados.
    $sourceNorm = [IO.Path]::GetFullPath($source).TrimEnd('\')
    $destNorm = [IO.Path]::GetFullPath($InstallDir).TrimEnd('\')
    if ($sourceNorm.Equals($destNorm, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'A origem nao pode ser a pasta de destino.'
    }

    Log ("Origem={0} | Destino={1}" -f $source, $InstallDir)
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
    $CreatedDir = $true

    # Copia as DLLs, data/, plugins/ e outros recursos completos da distribuicao.
    foreach ($item in Get-ChildItem -LiteralPath $source -Force) {
        if ($item.Name -ieq 'custom.txt') { continue }
        if ($item.Name -match '\.(ps1|cmd|bat)$') { continue }
        Copy-Item -LiteralPath $item.FullName -Destination $InstallDir -Recurse -Force
    }
    Rename-Item -LiteralPath (Join-Path $InstallDir 'rustdesk.exe') -NewName $ExeName
    if (-not (Test-Path -LiteralPath $ExeDest -PathType Leaf)) {
        throw 'Copia do executavel nao concluida.'
    }

    # Manifesto para auditoria de integridade do pacote instalado.
    $manifest = Join-Path $LogDir 'manifesto-sha256.csv'
    $files = Get-ChildItem -LiteralPath $InstallDir -Recurse -File
    $files | ForEach-Object {
        $relative = $_.FullName.Substring($InstallDir.Length).TrimStart('\')
        [PSCustomObject]@{ Path = $relative; SHA256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash }
    } | Export-Csv -LiteralPath $manifest -NoTypeInformation -Encoding UTF8
    Log ("Copiados {0} arquivos. Manifesto: {1}" -f @($files).Count, $manifest)

    # Nao executar --install-service: ele usa rotinas de instalacao internas
    # que podem modificar mais itens. Registrar somente o servico dedicado.
    $binPath = '"' + $ExeDest + '" --service'
    Run-SC @('create', $ServiceName, 'binPath=', $binPath, 'start=', 'auto', 'DisplayName=', $AppName) | Out-Null
    $CreatedService = $true
    Run-SC @('description', $ServiceName, 'DRGinfo Acesso Remoto - servico de acesso remoto baseado em RustDesk OSS') | Out-Null
    Run-SC @('start', $ServiceName) | Out-Null

    $status = $null
    for ($i = 0; $i -lt 10; $i++) {
        $status = (Get-Service -Name $ServiceName -ErrorAction Stop).Status
        if ($status -eq 'Running') { break }
        Start-Sleep -Seconds 1
    }
    if ($status -ne 'Running') {
        throw "Servico instalado, mas nao iniciado (estado=$status)."
    }
    Log "Instalacao concluida: servico automatico em execucao."
    Log "Executavel: $ExeDest"
    Log 'Nao instalar o MSI antigo nem importar parametros via --config.'
    Write-Host "SUCESSO | Log: $LogFile"
    exit 0
}
catch {
    $message = $_.Exception.Message
    try { Log $message 'ERRO' } catch { Write-Error $message }
    if ($CreatedService) {
        try {
            & "$env:SystemRoot\System32\sc.exe" stop $ServiceName 2>&1 | Out-Null
            Start-Sleep -Seconds 2
            & "$env:SystemRoot\System32\sc.exe" delete $ServiceName 2>&1 | Out-Null
            Log 'Rollback: servico criado removido.' 'ROLLBACK'
        } catch { Log ("Rollback do servico falhou: {0}" -f $_.Exception.Message) 'AVISO' }
    }
    if ($CreatedDir) {
        try {
            Remove-Item -LiteralPath $InstallDir -Recurse -Force
            Log 'Rollback: pasta instalada removida.' 'ROLLBACK'
        } catch { Log ("Rollback dos arquivos falhou: {0}" -f $_.Exception.Message) 'AVISO' }
    }
    exit 1
}
