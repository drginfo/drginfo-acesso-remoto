@echo off
setlocal
rem DRGinfo Acesso Remoto - abre interface grafica pela pasta do pacote.
rem O PowerShell solicita UAC, se necessario. Nao altera politicas permanentes.
set "BASE=%~dp0"
if not exist "%BASE%Interface-DRGinfo-AcessoRemoto.ps1" (
  echo ERRO: Interface-DRGinfo-AcessoRemoto.ps1 nao encontrada na pasta.
  exit /b 1
)
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -STA -ExecutionPolicy Bypass -File "%BASE%Interface-DRGinfo-AcessoRemoto.ps1"
exit /b %errorlevel%
