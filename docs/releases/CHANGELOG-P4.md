## 2026-11-27 — Homologação funcional P4 portátil (evidência informada pelo operador)
- Artefato `DRGinfo-Acesso-Remoto-Windows-x64.zip`; SHA-256 `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a`.
- Auditoria inicial ZIP: 109 entradas, integridade aprovada, componentes essenciais presentes; ausência de `rustdesk.exe` legado.
- Auditoria integral de manifesto: 108/108 hashes correspondentes, nenhum arquivo fora do manifesto, zero falhas.
- VM Windows de teste: serviço instalado da build #18 interrompido antes da execução P4 para minimizar conflito de duas instâncias.
- **APROVADO PELO OPERADOR:** execução portátil P4, logotipo DRGinfo, ID, estado Pronto, links Website/Privacidade corporativos e acesso remoto assistido fim a fim.
- **NÃO COMPROVADO/CONCLUÍDO NESTA EVIDÊNCIA:** restauração do serviço build #18, instalação automática e persistência pós-reboot P4, GUI online/offline, desinstalação, atualização, assinatura Authenticode, vinculação do artefato ao SHA exato do workflow GitHub Actions, distribuição comercial.
- A aprovação limita-se ao modo portátil e à conexão testada; manter a build #18 homologada e não substituir instalações existentes.

## 2026-11-27 — Correção dos três bloqueios de empacotamento (somente fonte)
- `install/windows/Gerar-Pacote-Instalador.ps1`: versão do instalador, versão do software, SHA-256, URL HTTPS e commit de origem são entradas obrigatórias; `-UnsignedLab` restrito ao canal laboratório; distribuição regular exige thumbprint Authenticode.
- `install/windows/Gerar-Pacotes-Offline-Portatil.ps1`: recebe explicitamente `-Version`, `-ExpectedHash`, `-InstallerVersion`, `-SourceCommit` e política de assinatura; remove os valores fixos da versão antiga.
- `install/windows/Interface-DRGinfo-AcessoRemoto.ps1`: valida `SourceCommit` (40 hex), `ReleaseChannel`, `UnsignedPilot` e certificado sem referência a versão antiga; distribuição em produção não usa modo unsigned.
- `tools/validar-p4-release.sh`: verifica os novos requisitos estáticos e recusa referências antigas nos três scripts.
- **Não foram executados Windows PowerShell 5.1, build Rust/Flutter, novo empacotamento, nem testes de GUI/UAC/reboot nesta alteração.** Integridade de pacote e assinatura continuam exigidas.
- O novo `SourceCommit` para empacotamento deve ser o SHA do commit final efetivamente aprovado, nunca a branch móvel; `SoftwareSha256` deve vir do ZIP efetivamente compilado e verificado.

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
