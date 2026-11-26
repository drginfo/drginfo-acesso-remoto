# Segurança — DRGinfo Acesso Remoto Windows

## Política e evidência
- Nunca incluir senha, token, chave privada SSH ou seed de assinatura no código, artefato ou log. A chave do servidor de rendezvous é pública.
- O script `install/windows/Auditar-Seguranca-DRGinfo.ps1` é **somente leitura** e coleta ACLs de `Program Files/DRGinfo Acesso Remoto`, `ProgramData/DRGinfo/AcessoRemoto`, serviço, assinatura e hash. A presença do script não significa que ACLs estejam corretas.
- Requerer acesso restrito à escrita em diretório do programa e scripts executados em contexto elevado. Revisar especificamente Users, Authenticated Users e Everyone, herança, contas do serviço e reparse points antes da distribuição.
- Observar UAC, princípio do menor privilégio, execução de código assinado quando disponível e integridade SHA-256.
- Preservar hash da versão homologada e rollback antes de qualquer instalação ou alteração de serviço.
- O workflow restaura o pacote oficial corporativo e bloqueia erros estáticos previsíveis *antes* do build caro; isso **não substitui** auditoria Windows de ACL.
- Não divulgar relatórios com nomes pessoais, tokens, credenciais, IPs internos sensíveis ou dados de clientes (LGPD).

## Bloqueios de aprovação
Não liberar se faltar marca, configuração embarcada ou proteção contra atualizações. Sem homologação: ACL, serviço, UAC, assinatura, instalação/desinstalação e teste fim a fim permanecem pendentes.

## Revisão estática de alterações de servidor — P4.21, 26/11/2026
- Build examinada: `e1e7c30a5327af1b4ed600be7b3c54f6ebeda253`.
- `src/common.rs::load_embedded_drginfo_client()` insere `custom-rendezvous-server`, `relay-server` e `key` em `config::OVERWRITE_SETTINGS`.
- `src/ui_interface.rs::is_option_fixed()` consulta `OVERWRITE_SETTINGS`, mas `set_option()` também transmite opções por IPC; a mera existência desse método não prova mudança efetiva dos valores fixos.
- `flutter/lib/common.dart::setServerConfig()` inclui tentativa de definir ID/relay/API/key via `mainSetOption`.
- `src/core_main.rs` contém comandos administrativos `--option` e `--config`; `--option` consulta `is_cli_setting_change_disabled()` e exige instalação/administração para acessar IPC. O ramo `--config` depende de privilégios administrativos e caminho de configuração reconhecido.
- **Resultado:** canais de escrita persistem; a imutabilidade efetiva e a precedência dos valores embarcados no serviço ainda NÃO foram demonstradas; não rotular como bypass comprovado nem como bloqueio definitivo comprovado.
- **Recomendação para fase de produto:** impor política de bloqueio de mudança de rendezvous/relay/chave em camada central de aplicação/IPC e limitar a UI para edição DRGinfo; preservar opções comuns do usuário. Requer decisão de escopo e futura alteração versionada, não modificar a build homologada nesta etapa.

## DRG-WIN-006 — Implementação inicial em fonte (26/11/2026)
- Implementação feita na branch de desenvolvimento; NÃO incorporada ao executável homologado da build #10.
- `src/common.rs`: função Windows `is_drginfo_protected_server_key()` com quatro opções gerenciadas: `custom-rendezvous-server`, `relay-server`, `key` e `api-server`.
- `src/ui_interface.rs`: `set_option()` rejeita mudança individual; `try_set_options()` remove chaves gerenciadas de mapas completos antes de IPC.
- `src/ipc.rs`: `set_option()` e `set_options()` rejeitam/removem alterações locais; o receptor `Data::Options(Some(...))` também filtra essas chaves antes da atualização persistente.
- `src/core_main.rs`: comandos Windows `--config` e `--option CHAVE VALOR` recusam alteração de endpoint gerenciado. Mudanças legítimas exigem uma nova release da DRGinfo; **não foi implementado painel administrativo remoto**.
- Rejeições de alterações são registradas sem valor/segredo, no padrão `DRGINFO_MANAGED_SETTING_REJECTED`.
- Escopo: controles de entrada UI/CLI/IPC na edição Windows e configuração corporativa estática via `OVERWRITE_SETTINGS`. NÃO é prova contra modificação binária por administrador local, alteração de memória, substituição do serviço ou todas as outras rotas internas. Revisar precedência e interceptações adicionais antes de classificar a configuração como imutável.
- **Status:** código alterado, inspeção estática pontual concluída, compilação/validação funcional e teste de regressão PENDENTES. Não substituir a build #10 nem distribuir o código não homologado; preservar rollback.

## DRG-WIN-006 — Fechamento de importação TOML por CLI (26/11/2026)
- Commit de fonte: `08be7b3e3651f19b64eb4b87d59d421edd9c975d`, `src/core_main.rs`.
- No Windows, `--import-config` retorna antes de chamar `import_config()`, registra tentativa rejeitada sem incluir dados do arquivo e não escreve configurações. Nas demais plataformas o fluxo permanece intacto.
- Decisão de segurança provisória: desabilitar importação TOML em bloco na edição Windows, inclusive preferências, até existir importador com lista permissiva e testes de preservação de campos. Isso impede esse desvio da política corporativa.
- **Pendente:** `Data::SyncConfig(Some(...))` aplica objetos `Config`/`Config2` por rota alternativa sem filtro corporativo explícito; NÃO alterar cegamente porque pode envolver sincronismo de autenticação e dados necessários ao serviço. Requer inspeção do submódulo `hbb_common` na revisão travada pelo repositório e entendimento de `trusted_devices::config::set_config`.
- **Pendente:** verificar configuração efetiva na inicialização e precedência do servidor fixo versus nome do EXE; evitar regressões na conexão.
- Nenhuma compilação nem teste Windows executado nesta etapa; build #10 homologada mantida para rollback.

## DRG-WIN-006 — Sincronização Config2 protegida (26/11/2026, P4.26)
- Inspecionado o fluxo real `src/ipc.rs::Data::SyncConfig(Some(...))`, `src/ipc.rs::sync_security_config_from_server()`, `src/trusted_devices/config.rs::{sync_config,set_config,set_config2,effective_options}`.
- `Config2.options` também é gravado durante sincronização IPC, independentemente do filtro de `Data::Options`.
- `effective_options()` incorpora `DEFAULT_SETTINGS`, depois opções persistidas e, por último, `OVERWRITE_SETTINGS`; isso indica prioridade para configurações incorporadas nessa função, mas não comprova todas as rotas de conexão.
- Aplicado em `src/trusted_devices/config.rs` filtro Windows `strip_managed_endpoint_options` antes de persistência em `sync_config` e `set_config2`, removendo somente quatro chaves gerenciadas (ID/relay/chave/API) de `Config2.options`; os outros campos continuam sendo sincronizados e `sync_trusted_devices()` permanece inalterado.
- Limites: a sincronização de objeto `Config` (que pode conter dados de conexão em campos próprios), gravações diretas a arquivos e precedência de leitura efetiva ainda exigem inspeção completa. Não afirmar proteção integral apenas por esta mudança.
- **Status:** fonte alterado, sem compilação, testes automatizados ou homologação Windows. Build #10 intacta; rollback obrigatório.

## DRG-WIN-006 — Verificação de Config e precedência do EXE (26/11/2026, P4.27)
- Inspecionadas `src/core_main.rs`, `src/platform/windows.rs`, `src/common.rs`, `src/trusted_devices/config.rs` e a referência pública da implementação `rustdesk/hbb_common/src/config.rs`. ATENÇÃO: a referência pública consultada não comprova equivalência ao commit exato do submódulo Git; confirmar SHA fixado antes de homologar.
- Na referência pública, `Config` concentra identidade, senha/salt e estado de chaves confirmadas; `Config2` contém `rendezvous_server` e `options`. `Config::get_option()` privilegia `OVERWRITE_SETTINGS`; `Config::get_rendezvous_server()` e `get_rendezvous_servers()`, porém, privilegiam `EXE_RENDEZVOUS_SERVER`.
- Desvio identificado no fonte da DRGinfo: `platform/windows.rs::bootstrap()` inicializava `EXE_RENDEZVOUS_SERVER` a partir de nome do EXE; `common.rs` também tinha prioridades diretas de licença do nome do EXE para rendezvous, API e chave.
- Código alterado: `platform/windows.rs::bootstrap()` limpa `EXE_RENDEZVOUS_SERVER`; `common.rs::{get_rendezvous_server,get_custom_rendezvous_server,get_api_server_,get_key}` deixa de usar o nome do EXE para priorizar servidor/API/chave sobre as opções efetivas corporativas.
- Commits: `c867319fdc6a7de6ffa5ad249feb2d526992dcf1`, `acd599eaf4c3bfa8f442e86ad1f581d698eed65e`.
- Riscos ainda pendentes: confirmar SHA/implementação exata do submódulo; validar dinâmica de leitura de configurações pelo serviço e clientes; analisar dependências residuais em `platform/windows.rs::get_license()` e outras rotas, bem como configuração de API sem endpoint próprio; verificar autenticação/dispositivos confiáveis e atualização de opções após sincronismo.
- **Estado:** correções em fonte, sem build ou teste Windows nesta etapa. Versão instalada #10 preservada.
