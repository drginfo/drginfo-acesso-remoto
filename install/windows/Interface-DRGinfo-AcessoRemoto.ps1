#Requires -Version 5.1
<#
.SYNOPSIS
  Interface grafica DRGinfo Acesso Remoto — instalador Windows x64.
.DESCRIPTION
  Front-end para Instalar-DRGinfo-AcessoRemoto.ps1, sem alterar binarios homologados.
  Usa UAC padrao, WinForms, progresso e leitura do log de cada instalacao.
  Utiliza SHA256 da release homologada e HTTPS da VPS.
#>
[CmdletBinding()]
param([switch]$Elevated)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$AppName = 'DRGinfo Acesso Remoto'
$Base = Join-Path $env:ProgramData 'DRGinfo\AcessoRemoto'
$Core = Join-Path $Base 'Instalar-DRGinfo-AcessoRemoto.ps1'
$LogFile = Join-Path $Base 'instalacao.log'
$ReleaseUrl = 'https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/1.5.3-drginfo.1/DRGinfo-AcessoRemoto-windows-x64.zip'
$Sha256 = '3AC5BAC4B6AD211395C8C98FC9BA0E220517105C70F30003A818E36E588E8BA9'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Logo = Join-Path $ScriptDir 'logo-drginfo.png'

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  $arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $MyInvocation.MyCommand.Path + '" -Elevated'
  try {
    Start-Process -FilePath "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList $arguments -Verb RunAs -ErrorAction Stop
  } catch {
    Write-Warning ('Elevacao cancelada ou falhou: ' + $_.Exception.Message)
    exit 1
  }
  exit 0
}
if (-not (Test-Path -LiteralPath $Core -PathType Leaf)) {
  throw "Motor de instalacao nao encontrado: $Core"
}
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = "$AppName | Instalacao"
$form.ClientSize = New-Object System.Drawing.Size(630,440)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font('Segoe UI',9)

$header = New-Object System.Windows.Forms.Panel
$header.Dock = 'Top'
$header.Height = 105
$header.BackColor = [System.Drawing.Color]::FromArgb(0,85,166)
$form.Controls.Add($header)

$brand = New-Object System.Windows.Forms.Label
$brand.Text = 'DRGinfo | ACESSO REMOTO'
$brand.ForeColor = [System.Drawing.Color]::White
$brand.Font = New-Object System.Drawing.Font('Segoe UI',18,[System.Drawing.FontStyle]::Bold)
$brand.SetBounds(22,22,580,40)
$header.Controls.Add($brand)
if (Test-Path -LiteralPath $Logo -PathType Leaf) {
  try {
    $picture = New-Object System.Windows.Forms.PictureBox
    $picture.Image = [System.Drawing.Image]::FromFile($Logo)
    $picture.SizeMode = 'Zoom'
    $picture.BackColor = [System.Drawing.Color]::White
    $picture.SetBounds(22,12,175,80)
    $header.Controls.Add($picture)
    $brand.Text = 'ACESSO REMOTO'
    $brand.SetBounds(215,27,390,40)
  } catch { $brand.Text = 'DRGinfo | ACESSO REMOTO' }
}
$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = 'Instalador corporativo | Windows 10/11 x64 | v1.5.3-drginfo.1'
$subtitle.SetBounds(22,118,590,23)
$subtitle.ForeColor = [System.Drawing.Color]::FromArgb(55,65,81)
$form.Controls.Add($subtitle)

$warning = New-Object System.Windows.Forms.Label
$warning.Text = 'Release provisoria sem assinatura Authenticode. Download HTTPS e SHA-256 fixado.'
$warning.SetBounds(22,146,595,39)
$warning.ForeColor = [System.Drawing.Color]::FromArgb(130,75,0)
$form.Controls.Add($warning)

$status = New-Object System.Windows.Forms.Label
$status.Text = 'Pronto para instalar. A instalacao existente nao sera sobrescrita.'
$status.SetBounds(22,188,590,26)
$form.Controls.Add($status)

$progress = New-Object System.Windows.Forms.ProgressBar
$progress.SetBounds(22,220,584,19)
$progress.Style = 'Blocks'
$form.Controls.Add($progress)

$logs = New-Object System.Windows.Forms.TextBox
$logs.SetBounds(22,256,584,122)
$logs.Multiline = $true
$logs.ScrollBars = 'Vertical'
$logs.ReadOnly = $true
$logs.Font = New-Object System.Drawing.Font('Consolas',8)
$form.Controls.Add($logs)

$install = New-Object System.Windows.Forms.Button
$install.Text = 'Instalar DRGinfo'
$install.SetBounds(22,392,160,32)
$install.BackColor = [System.Drawing.Color]::FromArgb(0,85,166)
$install.ForeColor = [System.Drawing.Color]::White
$install.FlatStyle = 'Flat'
$form.Controls.Add($install)

$openLog = New-Object System.Windows.Forms.Button
$openLog.Text = 'Abrir log'
$openLog.SetBounds(194,392,120,32)
$form.Controls.Add($openLog)

$close = New-Object System.Windows.Forms.Button
$close.Text = 'Fechar'
$close.SetBounds(486,392,120,32)
$form.Controls.Add($close)

$script:worker = $null
$script:startLineCount = 0
$script:completed = $false
$script:exitCode = $null
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500

$openLog.Add_Click({
  if (Test-Path -LiteralPath $LogFile) {
    Start-Process -FilePath notepad.exe -ArgumentList ('"' + $LogFile + '"')
  } else {
    [System.Windows.Forms.MessageBox]::Show('Nenhum log foi criado ate o momento.','DRGinfo') | Out-Null
  }
})
$close.Add_Click({ if (-not $script:worker -or $script:worker.HasExited) { $form.Close() } })
$install.Add_Click({
  if ($script:worker -and -not $script:worker.HasExited) { return }
  $existing = Get-CimInstance Win32_Service -Filter "Name='DRGinfo Acesso Remoto'" -ErrorAction SilentlyContinue
  $targetDir = Join-Path $env:ProgramFiles $AppName
  if ($existing -or (Test-Path -LiteralPath $targetDir)) {
    $status.Text = 'DRGinfo ja instalado. Nenhuma alteracao realizada.'
    [System.Windows.Forms.MessageBox]::Show(
      'A instalacao existente sera preservada. Use o procedimento de atualizacao/reparo, nao o instalador inicial.',
      'DRGinfo Acesso Remoto') | Out-Null
    return
  }
  $answer = [System.Windows.Forms.MessageBox]::Show(
    'Instalar a release DRGinfo aprovada a partir da VPS? Esta versao ainda nao possui assinatura Authenticode.',
    'Confirmar instalacao',
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    [System.Windows.Forms.MessageBoxIcon]::Warning)
  if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) { return }

  $script:startLineCount = 0
  if (Test-Path -LiteralPath $LogFile) { $script:startLineCount = @(Get-Content -LiteralPath $LogFile -ErrorAction SilentlyContinue).Count }
  $script:completed = $false
  $logs.Clear()
  $install.Enabled = $false
  $close.Enabled = $false
  $status.Text = 'Validando pacote e instalando o servico...'
  $progress.Style = 'Marquee'
  $progress.MarqueeAnimationSpeed = 25

  $arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $Core +
    '" -PackageUrl "' + $ReleaseUrl + '" -PackageSha256 "' + $Sha256 + '" -AllowUnsigned'
  try {
    $script:worker = Start-Process -FilePath "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList $arguments -WindowStyle Hidden -PassThru -ErrorAction Stop
    $timer.Start()
  } catch {
    $status.Text = ('Falha ao iniciar: ' + $_.Exception.Message)
    $progress.Style = 'Blocks'
    $progress.Value = 0
    $install.Enabled = $true
    $close.Enabled = $true
  }
})
$timer.Add_Tick({
  if (Test-Path -LiteralPath $LogFile) {
    try {
      $allLines = @(Get-Content -LiteralPath $LogFile -ErrorAction Stop)
      $newLines = @($allLines | Select-Object -Skip $script:startLineCount)
      $logs.Lines = [string[]]($newLines | Select-Object -Last 30)
      $logs.SelectionStart = $logs.TextLength
      $logs.ScrollToCaret()
    } catch { }
  }
  if ($script:worker -and $script:worker.HasExited -and -not $script:completed) {
    $script:completed = $true
    $timer.Stop()
    $progress.Style = 'Blocks'
    $progress.Value = 100
    $script:exitCode = $script:worker.ExitCode
    $install.Enabled = $true
    $close.Enabled = $true
    if ($script:exitCode -eq 0) {
      $status.Text = 'Instalacao concluida. Servico registrado e iniciado.'
      [System.Windows.Forms.MessageBox]::Show('Instalacao concluida. Verifique o acesso remoto no cliente DRGinfo.','DRGinfo') | Out-Null
    } else {
      $progress.Value = 0
      $status.Text = "Instalacao nao concluida (codigo $script:exitCode). Consultar log."
      [System.Windows.Forms.MessageBox]::Show('A instalacao nao foi concluida. Verifique o log e o rollback antes de tentar novamente.','DRGinfo') | Out-Null
    }
  }
})
$form.Add_FormClosing({
  param($sender,$e)
  if ($script:worker -and -not $script:worker.HasExited) {
    $e.Cancel = $true
    [System.Windows.Forms.MessageBox]::Show('A instalacao esta em andamento. Aguarde a conclusao.','DRGinfo') | Out-Null
  }
})
[void]$form.ShowDialog()
$timer.Dispose()
$form.Dispose()
