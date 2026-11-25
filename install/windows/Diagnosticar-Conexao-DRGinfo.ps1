#Requires -Version 5.1
<#
.SYNOPSIS
  Diagnostico somente leitura: cliente DRGinfo Windows x64 sem conexao.
.DESCRIPTION
  Registra processos, servicos, hashes, DNS, conexoes TCP e eventos filtrados.
  Nao altera registros, perfis, servicos ou configuracoes do cliente.
  Nao coleta senhas, chaves ou texto de arquivos TOML.
.PARAMETER ClientPath
  Caminho do EXE da nova build em teste. Opcional: descoberta de processo.
#>
[CmdletBinding()]
param([string]$ClientPath = '')
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'
$Root = Join-Path $env:USERPROFILE 'Documents\DRGinfo-Auditorias'
$Time = Get-Date -Format 'yyyyMMdd-HHmmss'
New-Item -ItemType Directory -Path $Root -Force | Out-Null
$Report = Join-Path $Root "DIAGNOSTICO-CONEXAO-DRGINFO-$Time.md"

function Add([string]$Value) {
  Add-Content -LiteralPath $Report -Encoding UTF8 -Value $Value
}
function Safe([object]$Value) {
  if ($null -eq $Value) { return '(indisponivel)' }
  return ([string]$Value).Replace('|','/').Replace('`','')
}
function Row([string]$K,[object]$V) { Add ('| ' + (Safe $K) + ' | ' + (Safe $V) + ' |') }
Add '# DRGinfo Acesso Remoto - Diagnostico somente leitura'
Add ('Gerado: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'))
Add ('Estacao: ' + $env:COMPUTERNAME)
Add ('Usuario: ' + $env:USERNAME)
Add ' '
Add '## Cliente testado'
Add '| Campo | Valor |'
Add '|---|---|'
$possible = @()
if ($ClientPath) { $possible += $ClientPath }
try {
  $processes = @(Get-CimInstance Win32_Process -ErrorAction Stop | Where-Object {
    $_.Name -match '^(rustdesk|DRGinfo Acesso Remoto)\.exe$'
  })
} catch { $processes = @() }
foreach($p in $processes) { if($p.ExecutablePath) { $possible += $p.ExecutablePath } }
$installedExe = Join-Path $env:ProgramFiles 'DRGinfo Acesso Remoto\DRGinfo Acesso Remoto.exe'
if(Test-Path -LiteralPath $installedExe) { $possible += $installedExe }
$possible = @($possible | Where-Object { $_ } | Select-Object -Unique)
if($possible.Count -eq 0) { Row 'Executaveis' 'Nenhum EXE identificado; informe ClientPath.' }
foreach($exe in $possible){
  if(Test-Path -LiteralPath $exe -PathType Leaf) {
    try {
      $item = Get-Item -LiteralPath $exe
      Row 'EXE' $item.FullName
      Row 'EXE SHA256' (Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash
      Row 'Versao' $item.VersionInfo.FileVersion
      $dll = Join-Path $item.DirectoryName 'librustdesk.dll'
      if(Test-Path -LiteralPath $dll) { Row 'DLL SHA256' (Get-FileHash -LiteralPath $dll -Algorithm SHA256).Hash }
    } catch { Row 'Erro ao ler EXE' $_.Exception.Message }
  } else { Row 'EXE nao encontrado' $exe }
}
Add ' '
Add '## Processos do aplicativo'
Add '| PID | Nome | Executavel | Argumentos sanitizados |'
Add '|---|---|---|---|'
foreach($p in $processes) {
  $args = ''
  # Somente os modos operacionais aprovados, nunca CommandLine completa
  foreach($a in @('--service','--server','--tray','--cm','--install')) {
    if($p.CommandLine -and $p.CommandLine.Contains($a)) { $args += ($a+' ') }
  }
  Add ('| '+$p.ProcessId+' | '+(Safe $p.Name)+' | '+(Safe $p.ExecutablePath)+' | '+(Safe $args)+' |')
}
Add ' '
Add '## Servicos de acesso remoto'
Add '| Servico | Estado | Inicializacao | Executavel |'
Add '|---|---|---|---|'
try {
  $services = @(Get-CimInstance Win32_Service -ErrorAction Stop | Where-Object { $_.Name -in @('DRGinfo Acesso Remoto','RustDesk') -or $_.DisplayName -in @('DRGinfo Acesso Remoto','RustDesk') })
  foreach($s in $services) { Add ('| '+(Safe $s.Name)+' | '+(Safe $s.State)+' | '+(Safe $s.StartMode)+' | '+(Safe $s.PathName)+' |') }
  if(-not $services.Count) { Add '| Nenhum identificado | - | - | - |' }
} catch { Add ('Erro de leitura do SCM: '+$_.Exception.Message) }
Add ' '
Add '## Rede - DNS e TCP'
Add '| Verificacao | Resultado |'
Add '|---|---|'
$HostName = 'drgvps.drginfo.com.br'
try {
  $dns = @(Resolve-DnsName -Name $HostName -Type A -ErrorAction Stop | Where-Object { $_.IPAddress } | Select-Object -ExpandProperty IPAddress)
  Row 'DNS A' ($dns -join ', ')
} catch { Row 'DNS A' ('ERRO: '+$_.Exception.Message) }
foreach($port in @(21115,21116,21117)) {
  try {
    $client = New-Object System.Net.Sockets.TcpClient
    try {
      $ar = $client.BeginConnect($HostName,$port,$null,$null)
      $ok = $ar.AsyncWaitHandle.WaitOne(3500)
      if($ok) { $client.EndConnect($ar) | Out-Null; Row "TCP $port" 'Conectou' }
      else { Row "TCP $port" 'Sem resposta em 3,5 s' }
      $ar.AsyncWaitHandle.Close()
    } finally { $client.Close() }
  } catch { Row "TCP $port" ('ERRO: '+$_.Exception.Message) }
}
Add ' '
Add '## Arquivos de diagnostico local (metadados somente)'
Add '| Caminho | Modificado | Tamanho |'
Add '|---|---|---|'
$folders = @(
  (Join-Path $env:APPDATA 'RustDesk'),
  (Join-Path $env:APPDATA 'DRGinfo Acesso Remoto'),
  (Join-Path $env:LOCALAPPDATA 'RustDesk'),
  (Join-Path $env:LOCALAPPDATA 'DRGinfo Acesso Remoto')
)
foreach($folder in $folders) {
  if(Test-Path -LiteralPath $folder){
    $files = @(Get-ChildItem -LiteralPath $folder -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in @('.log','.toml','.conf') } | Sort-Object LastWriteTime -Descending | Select-Object -First 25)
    foreach($f in $files){ Add ('| '+(Safe $f.FullName)+' | '+(Safe $f.LastWriteTime)+' | '+$f.Length+' |') }
  }
}
Add ' '
Add '## Eventos relevantes do log do programa (trechos sem segredos)'
Add 'Somente linhas com marcadores de estado conhecidos; nenhum arquivo TOML ou chave e copiado.'
Add '```text'
$keywords = 'DRGINFO_EMBEDDED_CONFIG_APPLIED|connection refused|connection timed out|dns|rendezvous|socket error|key mismatch|failed to connect|hbbs|hbbr'
foreach($folder in $folders) {
  if(Test-Path -LiteralPath $folder) {
    $logFiles = @(Get-ChildItem -LiteralPath $folder -File -Recurse -Filter '*.log' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 5)
    foreach($log in $logFiles) {
      try {
        # Nunca colar linha bruta: registrar apenas qual categoria ocorreu
        $lines = @(Get-Content -LiteralPath $log.FullName -Tail 400 -ErrorAction SilentlyContinue)
        foreach($term in @('DRGINFO_EMBEDDED_CONFIG_APPLIED','connection refused','connection timed out','rendezvous','key mismatch','failed to connect')) {
          $n = @($lines | Where-Object { $_ -like ('*'+$term+'*') }).Count
          if($n -gt 0) { Add ("$($log.Name): categoria=$term ocorrencias=$n") }
        }
      } catch { }
    }
  }
}
Add '```'
Add ''
Add '## Interpretacao'
Add '- Executavel recem-gerado vs servico anterior: comparar caminhos de processos e servicos.'
Add '- TCP conecta: nao comprova funcionamento da autenticacao nem da sessao UDP.'
Add '- Porta UDP 21116 nao validada por este script; TCP e DNS isoladamente nao garantem conexao.'
Add '- Nao compartilhar logs brutos, configuracoes TOML, senha de acesso ou chave privada.'
Write-Host "RELATORIO: $Report"
