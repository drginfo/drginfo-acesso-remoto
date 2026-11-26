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
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$AppName = 'DRGinfo Acesso Remoto'
$Base = Join-Path $env:ProgramData 'DRGinfo\AcessoRemoto'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# Pacote independente: usar o motor distribuido ao lado da interface.
# Fallback apenas para preservar o laboratorio instalado anteriormente.
$Core = Join-Path $ScriptDir 'Instalar-DRGinfo-AcessoRemoto.ps1'
if (-not (Test-Path -LiteralPath $Core -PathType Leaf)) {
  $Core = Join-Path $Base 'Instalar-DRGinfo-AcessoRemoto.ps1'
}
$LogFile = Join-Path $Base 'instalacao.log'
# gui5: release manifest created only after ZIP is published and hashed.
$ConfigPath = Join-Path $ScriptDir 'release-config.psd1'
if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) { throw 'release-config.psd1 ausente; instalacao bloqueada.' }
$ReleaseConfig = Import-PowerShellDataFile -LiteralPath $ConfigPath
$ReleaseUrl = [string]$ReleaseConfig.SoftwareUrl
$Sha256 = [string]$ReleaseConfig.SoftwareSha256
$SoftwareVersion = [string]$ReleaseConfig.SoftwareVersion
$Offline = $false
if ($ReleaseConfig.ContainsKey('Offline')) { $Offline = [bool]$ReleaseConfig['Offline'] }
# Assinatura obrigatoria por padrao. Apenas piloto tecnicamente identificado
# pode executar a release legada nao assinada enquanto aguarda certificado OV.
$UnsignedPilot = $false
if ($ReleaseConfig.ContainsKey('UnsignedPilot')) {
  $UnsignedPilot = [bool]$ReleaseConfig['UnsignedPilot']
}
if ($UnsignedPilot -and ($SoftwareVersion -ne '1.5.3-drginfo.2' -or
  $Sha256 -ne '7770F8D6B61217568124BBB2FB96D482621BA52FBF1C8CEFF2CD31A2EF776525')) {
  throw 'UnsignedPilot permitido somente para a release legada explicitamente fixada.'
}
$PublisherThumbprint = ''
if ($ReleaseConfig.ContainsKey('PublisherThumbprint')) {
  $PublisherThumbprint = [string]$ReleaseConfig['PublisherThumbprint']
}
if (-not $UnsignedPilot -and $PublisherThumbprint -notmatch '^[A-Fa-f0-9]{40,64}$') {
  throw 'Certificado Authenticode exigido para distribuicao regular. PublisherThumbprint ausente.'
}
$OfflinePackage = Join-Path $ScriptDir 'DRGinfo-AcessoRemoto-windows-x64.zip'
if ($Offline) {
  if (-not (Test-Path -LiteralPath $OfflinePackage -PathType Leaf)) {
    throw 'Pacote offline nao encontrado na pasta do instalador.'
  }
  if ((Get-FileHash -LiteralPath $OfflinePackage -Algorithm SHA256).Hash -ne $Sha256.ToUpperInvariant()) {
    throw 'Pacote offline alterado ou corrompido: SHA256 divergente.'
  }
}
$uri = $null
if (-not [uri]::TryCreate($ReleaseUrl,[UriKind]::Absolute,[ref]$uri) -or
    $uri.Scheme -ne 'https' -or $uri.Host -ne 'downloads.drginfo.com.br' -or
    $uri.UserInfo -ne '' -or $uri.Query -ne '' -or $uri.Fragment -ne '' -or
    $uri.AbsolutePath -notmatch '^/rustdesk/drginfo-acesso-remoto/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+[.]zip$') {
  throw 'URL da release invalida.'
}
if ($Sha256 -notmatch '^[A-Fa-f0-9]{64}$') { throw 'Hash SHA256 invalido.' }
if ($SoftwareVersion -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$') { throw 'Versao da release invalida.' }
# Resolver identidade visual pelo pacote da GUI e, se necessario, pela
# pasta corporativa persistente (usada na homologacao anterior).
$Logo = Join-Path $ScriptDir 'logo-drginfo.png'
if (-not (Test-Path -LiteralPath $Logo -PathType Leaf)) {
  $Logo = Join-Path $Base 'logo-drginfo.png'
}

# A GUI pode ser aberta por usuario comum. UAC sera solicitado somente
# no momento de iniciar a instalacao (processo separado e elevado).
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
$header.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($header)

$brand = New-Object System.Windows.Forms.Label
$brand.Text = 'DRGinfo | ACESSO REMOTO'
$brand.ForeColor = [System.Drawing.Color]::FromArgb(0,85,166)
$brand.Font = New-Object System.Drawing.Font('Segoe UI',18,[System.Drawing.FontStyle]::Bold)
$brand.SetBounds(22,22,580,40)
$header.Controls.Add($brand)
if (Test-Path -LiteralPath $Logo -PathType Leaf) {
  try {
    $picture = New-Object System.Windows.Forms.PictureBox
    # Criar uma copia com alpha para pixels brancos, sem modificar o PNG oficial.
    # Mantem logo e fundo integrados ao painel branco do instalador.
    $original = [System.Drawing.Image]::FromFile($Logo)
    try {
      $bitmap = New-Object System.Drawing.Bitmap($original)
    } finally { $original.Dispose() }
    $bitmap.MakeTransparent([System.Drawing.Color]::White)
    $picture.Image = $bitmap
    $picture.SizeMode = 'Zoom'
    $picture.BackColor = [System.Drawing.Color]::Transparent
    $picture.SetBounds(22,12,185,76)
    $header.Controls.Add($picture)
    $brand.Text = 'ACESSO REMOTO'
    $brand.SetBounds(225,27,375,40)
  } catch { $brand.Text = 'DRGinfo | ACESSO REMOTO' }
}
$headerLine = New-Object System.Windows.Forms.Panel
$headerLine.BackColor = [System.Drawing.Color]::FromArgb(0,85,166)
$headerLine.SetBounds(22,95,584,3)
$header.Controls.Add($headerLine)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = 'Instalador corporativo | Windows 10/11 x64 | v' + $SoftwareVersion
$subtitle.SetBounds(22,118,590,23)
$subtitle.ForeColor = [System.Drawing.Color]::FromArgb(55,65,81)
$form.Controls.Add($subtitle)

$warning = New-Object System.Windows.Forms.Label
if ($Offline) {
  $warning.Text = 'Instalacao offline: pacote local DRGinfo | Integridade verificada por SHA-256.'
} else {
  $warning.Text = 'Download seguro pela infraestrutura DRGinfo | Integridade verificada por SHA-256.'
}
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
$logs.BackColor = [System.Drawing.Color]::FromArgb(248,250,252)
$form.Controls.Add($logs)

$install = New-Object System.Windows.Forms.Button
$install.Text = 'Instalar DRGinfo'
$install.SetBounds(22,392,160,32)
$install.BackColor = [System.Drawing.Color]::FromArgb(0,85,166)
$install.ForeColor = [System.Drawing.Color]::White
$install.FlatStyle = 'Flat'
$form.Controls.Add($install)

$openApp = New-Object System.Windows.Forms.Button
$openApp.Text = 'Abrir aplicativo'
$openApp.SetBounds(194,392,138,32)
$openApp.Enabled = $false
$form.Controls.Add($openApp)

$openLog = New-Object System.Windows.Forms.Button
$openLog.Text = 'Abrir log'
$openLog.SetBounds(344,392,112,32)
$form.Controls.Add($openLog)

$close = New-Object System.Windows.Forms.Button
$close.Text = 'Fechar'
$close.SetBounds(486,392,120,32)
$form.Controls.Add($close)

function Refresh-InstallState {
  $targetDir = Join-Path $env:ProgramFiles $AppName
  $targetExe = Join-Path $targetDir "$AppName.exe"
  $existing = Get-CimInstance Win32_Service -Filter "Name='DRGinfo Acesso Remoto'" -ErrorAction SilentlyContinue
  if ($existing -or (Test-Path -LiteralPath $targetDir)) {
    $install.Enabled = $false
    $install.Text = 'Ja instalado'
    $openApp.Enabled = Test-Path -LiteralPath $targetExe -PathType Leaf
    if ($existing -and $existing.State -eq 'Running') {
      $status.Text = 'Instalacao detectada | Servico DRGinfo: em execucao.'
    } elseif ($existing) {
      $status.Text = 'Instalacao detectada | Servico DRGinfo: ' + $existing.State
    } else {
      $status.Text = 'Arquivos encontrados. Verificar/reparar antes de instalar.'
    }
    return $true
  }
  $install.Enabled = $true
  $install.Text = 'Instalar DRGinfo'
  $openApp.Enabled = $false
  $status.Text = 'Pronto para instalar a partir da VPS DRGinfo.'
  return $false
}

$script:worker = $null
$script:startLineCount = 0
$script:completed = $false
$script:exitCode = $null
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 500

$openApp.Add_Click({
  $exe = Join-Path (Join-Path $env:ProgramFiles $AppName) "$AppName.exe"
  if (Test-Path -LiteralPath $exe -PathType Leaf) { Start-Process -FilePath $exe -WorkingDirectory (Split-Path -Parent $exe) }
})
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
  if (-not (Test-Path -LiteralPath $Core -PathType Leaf)) {
    [System.Windows.Forms.MessageBox]::Show(
      "Motor de instalacao nao encontrado: $Core",
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
    '" -PackageSha256 "' + $Sha256 + '" -PackageVersion "' + $SoftwareVersion + '"'
  if ($UnsignedPilot) {
    $arguments += ' -AllowUnsigned'
  } else {
    $arguments += ' -PublisherThumbprint "' + $PublisherThumbprint + '"'
  }
  if ($Offline) {
    $arguments += ' -PackageFile "' + $OfflinePackage + '"'
  } else {
    $arguments += ' -PackageUrl "' + $ReleaseUrl + '"'
  }
  try {
    # Usuario padrao recebe UAC aqui. O Windows solicita credenciais
    # administrativas quando necessario; nao armazenamos credenciais.
    $script:worker = Start-Process -FilePath "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden -PassThru -ErrorAction Stop
    $timer.Start()
  } catch {
    $status.Text = 'Instalacao nao iniciada. Elevacao cancelada ou indisponivel.'
    [System.Windows.Forms.MessageBox]::Show(
      "A instalacao exige autorizacao administrativa do Windows. Nenhuma alteracao realizada. Detalhes: $($_.Exception.Message)",
      'DRGinfo Acesso Remoto') | Out-Null
    $progress.Style = 'Blocks'
    $progress.Value = 0
    $install.Enabled = $true
    $close.Enabled = $true
    [void](Refresh-InstallState)
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
    $script:exitCode = $script:worker.ExitCode
    $progress.Value = if ($script:exitCode -eq 0) { 100 } else { 0 }
    $install.Enabled = $true
    $close.Enabled = $true
    if ($script:exitCode -eq 0) {
      $status.Text = 'Instalacao concluida. Servico registrado e iniciado.'
      [void](Refresh-InstallState)
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
$form.Add_Shown({ [void](Refresh-InstallState) })
[void]$form.ShowDialog()
$timer.Dispose()
$form.Dispose()
