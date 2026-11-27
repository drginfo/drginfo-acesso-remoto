# CHANGELOG — Preparação DRGinfo Windows P4 (26–27/11/2026)

## Não lançada / sem nova compilação
- Branch de desenvolvimento: `release/drginfo-windows-p4-links-docs`, base `fix/drginfo-windows-startup-diagnostics`.
- A tela **Sobre** passa a apontar para páginas DRGinfo de Website e Privacidade, restrita ao cliente personalizado; preserva links upstream na edição não corporativa.
- Na tela do instalador, link de privacidade passa ao domínio DRGinfo na edição personalizada.
- Guia de preços RustDesk não abre no cliente corporativo.
- Páginas públicas registradas: `https://drginfo.com.br/acesso-remoto/` (WordPress ID 924) e `https://drginfo.com.br/privacidade-acesso-remoto/` (ID 923), após correção CSS confirmada pelo operador.
- Documentação versionada: `docs/releases/DOCUMENTACAO-TECNICA-DRGINFO.md`, `MANUAL-USUARIO-DRGINFO.md`, `MANUAL-INSTALACAO-DRGINFO.md`, `CONTROLE-WORDPRESS-PAGINAS-DRGINFO.md`, `DRGINFO-P4-PLANO-RELEASE.md`.
- Script Debian de sincronização do notebook: `tools/sincronizar-notebook-drginfo.sh`.

## Evidência já homologada — build #18, NÃO alterada
- Revisão de compilação: `fdd7525551d8f06a76ffe65241f7ebbfa26596e3`.
- ZIP SHA-256: `F4D6944138477B2C0900DE8CCD99BFC561C48E1FE0564A66A4CB8E0FD31D2825`.
- Confirmação do operador: nome/logo, serviço Running/Automatic pós-reboot e conexão remota fim a fim.

## Bloqueadores para a próxima release
- Nova build **ainda não gerada**: nenhuma comprovação de binário com links novos.
- Geradores de instalador online/offline atuais são fixados em software `1.5.3-drginfo.2`; precisam revisão/versão e hashes da próxima release antes de executar.
- Ainda não existem, para a revisão P4, os três pacotes binários testados: online, offline, portátil.
- Requer teste estático Flutter, compilação manual, teste regressivo, segurança, documentação AGPL e hashes públicos.
- A fonte ainda **não foi sincronizada fisicamente no notebook**; execução do script pelo operador é necessária.

Este registro separa claramente **implementação do código**, **compilação**, **homologação** e **distribuição**.
