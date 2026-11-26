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
