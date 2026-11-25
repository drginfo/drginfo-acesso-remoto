# DRGinfo Acesso Remoto — Instalacao e Desinstalacao (gui4)
Data: 2026-11-25
Status: IMPLEMENTADO NO CODIGO; aguardando homologacao Windows.

## Identidade
Produto e executavel: DRGinfo Acesso Remoto / DRGinfo Acesso Remoto.exe
Scripts e pacotes: drg-remoto. Manter bibliotecas internas upstream necessarias.
Documentar autoria e licenca AGPL-3.0; distribuir LICENCE e codigo-fonte correspondente.

## Instalador
Entrada: instalador-drginfo.cmd (WinForms, sem UAC inicial).
Instalar: UAC no clique, download HTTPS da VPS, verificacao SHA-256, servico automatico.
Chave Windows: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DRGinfoAcessoRemoto.
Campos: DisplayName, DisplayVersion, Publisher, InstallLocation, DisplayIcon,
UninstallString, URLInfoAbout, InstallDate, EstimatedSize, NoModify e NoRepair.
Desinstalador persistente: C:\ProgramData\DRGinfo\AcessoRemoto\tools\Desinstalar-DRGinfo-AcessoRemoto.ps1
Remocao: confirmacao, UAC, stop/delete servico, delete arquivos e registro. Logs preservados.
Se arquivos bloqueados ou servico pendente, reiniciar e repetir. Sem exclusao agressiva de perfil.

## Modos
gui2: homologado, instalado, publicado na VPS. Nao sobrescrever.
gui4: codigo preparado, pacote no GitHub ainda nao gerado/publicado/homologado.
Versao portatil: homologada; sem servico permanente e sem registro ARP.

## Dependencia nova compilacao
Workflow: .github/workflows/drginfo-build-windows.yml
Script: install/windows/Preparar-Distribuicao-DRGinfo.ps1
Artefato: DRGinfo-Acesso-Remoto-Windows-x64
Motor de instalacao aceita rustdesk.exe (legado) ou DRGinfo Acesso Remoto.exe.
Os URLs/SHA-256 fixados na interface ainda apontam para 1.5.3-drginfo.1.
Antes de anunciar identidade nova como instalavel, publicar binario novo em release
imutavel na VPS e atualizar os hashes fixados do pacote. Nao promover sem homologacao.

## Testes de aceitacao
1. VM limpa: .cmd abre com usuario comum, sem UAC na abertura.
2. Clique Instalar: UAC e instalacao com credenciais autorizadas.
3. Verificar Aplicativos instalados: DRGinfo Acesso Remoto, versao e fabricante.
4. Reiniciar VM: conexao remota sem abrir o programa manualmente.
5. Desinstalar pelo Windows: UAC/confirmacao, remocao de servico, arquivos e ARP.
6. Verificar preservacao de logs e nenhum processo ou servico residual.
7. Testar nova build isoladamente do servico antigo, sem renomear DLL interna.
