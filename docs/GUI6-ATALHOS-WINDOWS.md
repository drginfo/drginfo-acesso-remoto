# DRGinfo Acesso Remoto — GUI6, atalhos corporativos
Data: 25/11/2026
Status: IMPLEMENTADO EM FONTE, NAO HOMOLOGADO EM VM.

## Motivo
A homologacao do gui5 (instalador 1.0.0-gui5 com software 1.5.3-drginfo.2)
confirmou UAC, download/SHA256, servico Automatic + Running apos reboot,
indicador Pronto, sessao remota fim a fim e desinstalacao pelo Windows.
O operador identificou ausencia de atalhos da Area de Trabalho e pasta no Menu Iniciar.

## Correcao
- Motor: install/windows/Instalar-DRGinfo-AcessoRemoto.ps1.
- Desinstalador: install/windows/Desinstalar-DRGinfo-AcessoRemoto.ps1.
- Gerador: install/windows/Gerar-Pacote-Instalador.ps1, versao gui6.
- Cria .lnk publico em [Environment]::GetFolderPath('CommonDesktopDirectory').
- Cria pasta DRGinfo em [Environment]::GetFolderPath('CommonPrograms'),
  contendo DRGinfo Acesso Remoto.lnk.
- Atalhos sao nativos do Windows via WScript.Shell e apontam exatamente
  para o executavel instalado, com WorkingDirectory e IconLocation do EXE.
- Recusa sobrescrever atalhos preexistentes: falha fechada.
- Rollback remove somente atalhos criados pela tentativa de instalacao.
- Desinstalacao verifica TargetPath do .lnk antes de remover;
  preserva arquivos de outros aplicativos e exclui pasta DRGinfo so se vazia.
- Nao cria atalho no perfil do administrador que forneceu UAC.
- Binario de software 1.5.3-drginfo.2 e seu SHA256 permanecem os mesmos.
- GUI5 homologado e imutavel; GUI6 so pode ser anunciado apos reteste.

## Criterios de aceitacao GUI6
[ ] VM limpa, sem servico, pasta de programa nem registro ARP DRGinfo.
[ ] Gerar release de instalador 1.0.0-gui6 em caminho novo.
[ ] ZIP do instalador, manifesto release-config.psd1, origem e SHA verificados.
[ ] Instalar com usuario comum + UAC de conta administrativa.
[ ] Confirmar area de trabalho publica: DRGinfo Acesso Remoto.lnk.
[ ] Confirmar Menu Iniciar > Todos os aplicativos > DRGinfo > DRGinfo Acesso Remoto.
[ ] Confirmar abertura do aplicativo por ambos os atalhos.
[ ] Confirmar servico Automatic + Running apos reboot e acesso remoto.
[ ] Remover pelo Windows, confirmar atalhos excluidos, pasta DRGinfo removida
    somente se estiver vazia, servico/pasta/ARP ausentes.
[ ] Preservar logs e registrar SHA do novo ZIP.
