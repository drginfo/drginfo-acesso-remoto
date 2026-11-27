# Documentação técnica — DRGinfo Acesso Remoto
**Corte:** 26–27/11/2026. **Natureza:** fonte e rastreabilidade, não laudo de pentest.
## Arquitetura
- Fork RustDesk OSS Windows x64; aplicação Flutter/Dart, núcleo Rust, componentes nativos Windows.
- Identidade visual e configuração DRGinfo embarcadas na inicialização: `src/common.rs`, `src/core_main.rs`, `flutter/lib/common.dart`; `drgvps.drginfo.com.br` atua como serviço de rendezvous/relay OSS.
- Política de bloqueio de edição de servidor em `src/common.rs`, `src/ipc.rs`, `src/ui_interface.rs`, `src/platform/windows.rs`, `src/trusted_devices/config.rs`; testes de desvio são pendência distinta de conectividade aprovada.
- Serviço Windows: `DRGinfo Acesso Remoto`, inicialização automática, conta LocalSystem. Programa em `C:\Program Files\DRGinfo Acesso Remoto`; trilhas técnicas em `C:\ProgramData\DRGinfo\AcessoRemoto`.
## Código e branches
- Base aprovada: `fix/drginfo-windows-startup-diagnostics` @ `fdd7525551d8f06a76ffe65241f7ebbfa26596e3`.
- Trabalho novo: `release/drginfo-windows-p4-links-docs`, deve passar por revisão antes de eventual merge.
- Base padrão atual do repositório é **`feat/android-config-asset`**, diferente da branch de homologação Windows; cuidado com `git clone` e `git pull` sem branch explícita.
## Configuração e marca
- O nome e ativos DRGinfo são intencionais; preservar nomes internos de DLLs para compatibilidade.
- Link na tela Sobre: `/acesso-remoto/` e `/privacidade-acesso-remoto/` quando cliente personalizado.
- Link de privacidade também na tela de instalação.
- Guia de preços RustDesk só é acessível por edição não personalizada.
- Conservar avisos de copyright do upstream e publicar código-fonte correspondente.
## Rastreabilidade de alterações
- `flutter/lib/desktop/pages/desktop_setting_page.dart`: links da tela Sobre.
- `flutter/lib/desktop/pages/install_page.dart`: link de política durante instalação.
- `flutter/lib/desktop/pages/connection_page.dart`: bloqueio de guia comercial upstream.
- `docs/releases/*`: documentação da nova revisão.
- O CSS em produção WordPress foi aplicado em CSS adicional e confirmado visualmente; sem exportação exata da configuração do site, sua versão no Git não é atestado completo de estado.
## Repositório, CI e artefatos
- Compilação longa: `.github/workflows/drginfo-diagnostico-windows-x64.yml`; disparar **manualmente** após revisão estática.
- Build #18 já homologada não deve ser substituída nem confundida com binário desta branch.
- ZIP #18 verificado: `F4D6944138477B2C0900DE8CCD99BFC561C48E1FE0564A66A4CB8E0FD31D2825`.
- Instalação padrão: `install/windows/Instalar-DRGinfo-AcessoRemoto.ps1` e desinstalador correspondente.
- Geradores históricos `Gerar-Pacote-Instalador.ps1` / `Gerar-Pacotes-Offline-Portatil.ps1` ainda contêm versões/hashes FIXADOS em release antiga e **não estão aptos** à geração da próxima revisão.
## QA e segurança
- Evidência operador: #18 portátil com UI e ponta a ponta, instalação via motor PowerShell, serviço Running/Automatic e pós-reboot ponta a ponta.
- Pendente: builds novos, GUI, regressão de URLs, atualização manual, bloqueio adversarial de configs, reinstalação/desinstalação, manifesto/hash externo, SBOM, SCA, revisão LGPD e AGPL.
- Não armazenar segredos (incluindo senhas, tokens e chaves privadas) em documentação, commits ou logs.
## Manutenção / operação
- Inventariar versão, commit, artifact run ID, SHA-256 ZIP e EXE, status serviço e cenário de teste por entrega.
- Cada alteração precisa de mudança rastreável, README/CHANGELOG, backup/rollback, homologação em VM isolada e somente então publicação.
- Durante operação, diagnósticos por scripts somente leitura e logs sanitizados.
