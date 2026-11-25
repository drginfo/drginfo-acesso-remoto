# DRGinfo Acesso Remoto — Instalacao e Desinstalacao (gui4)
Data: 2026-11-25
Status: GUI4 homologado em instalacao, registro ARP e remocao (25/11/2026). GUI5 em integracao.

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
gui4: gerado e homologado em VM: instalação, serviço, entrada ARP, conexão Pronto, desinstalação via Windows e remoção da entrada. Pacote instalado ainda era versão antiga 1.5.3-drginfo.1.
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

## Evidência final 25/11/2026
Capturas fornecidas pelo operador: Aplicativos instalados exibe DRGinfo Acesso Remoto, fabricante DRGinfo, versao 1.5.3-drginfo.1, tamanho 114 MB; segunda captura apos desinstalacao ja nao apresenta o item. Nao foi apresentado inventario pos-desinstalacao do servico/pasta; esse critério deve ser novamente auditado no gui5.

## Preparação gui5
O gerador gui5 requer SoftwareUrl, SoftwareSha256 e SoftwareVersion do NOVO ZIP publicado em URL imutavel da VPS; sem estes parametros nao gera instalador. O novo EXE de entrada sera DRGinfo Acesso Remoto.exe; seu pacote inclui LICENCE e manifesto de arquivos. Nao usar os dados do ZIP 1.5.3-drginfo.1 no gui5.
