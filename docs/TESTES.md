# Matriz de homologação Windows — DRGinfo

| Critério | Estado | Evidência requerida |
|---|---|---|
| Compilação da revisão reconciliada | PENDENTE | Actions + commit + artefato |
| Nome do artefato corporativo | CONFIGURADO | publicação do artefato correto |
| Nome e recursos internos do EXE | PENDENTE | propriedades Windows/ícone/UI |
| Logo oficial e ícones | PENDENTE | inspeção visual em VM |
| Servidor, relay e chave pública | PENDENTE | estado Pronto e conexão fim a fim |
| Atualização oficial bloqueada | PENDENTE | logs e comportamento controlado |
| ACL Program Files e ProgramData | PENDENTE | relatório Auditar-Seguranca-DRGinfo.ps1 |
| Serviço, UAC e desinstalação | PENDENTE | inspeção e rollback em VM |
| Authenticode | NÃO ASSINADO | assinatura válida ou risco explicitamente aprovado |
| Backup e rollback | PENDENTE | versão anterior preservada + procedimento |

Não confundir script disponível com execução ou homologação.

## Evidência visual 26/11/2026
- Windows: imagem do usuário mostrou estado `Pronto`, porém ausência de logotipo corporativo. Portanto, **identidade visual NÃO APROVADA** no build #9.
- Correção em `flutter/lib/common.dart` e gerador de assets; a existência do código não equivale à aprovação da nova build.

## Evidência do operador — 26/11/2026, build Windows #10
- Revisão de origem: `e1e7c30a5327af1b4ed600be7b3c54f6ebeda253`.
- Interface e logotipo DRGinfo exibidos; ID e estado `Pronto` apresentados (capturas fornecidas pelo operador).
- Servidor ID/relay `drgvps.drginfo.com.br` e chave pública configurados (captura fornecida pelo operador).
- **Conexão remota fim a fim: APROVADA pelo operador**, que confirmou “conectou normalmente”.
- Escopo da aprovação: conectividade assistida desta build; não constitui aprovação de ACLs, atualização oficial, serviço desassistido, instalador, assinatura ou distribuição final.
- Pendências de produto posteriores: links de Privacidade e Website no domínio DRGinfo; definição do recurso Conta/Login.

## Auditoria ACL e instalação — 26/11/2026, laboratório WIN11PROLAB
- Evidências: DRGinfo-Auditoria-Windows-20261126-143537.md e DRGinfo-ACL-Recursiva.txt fornecidos pelo operador; arquivos brutos retidos com o operador, não publicados no Git.
- Instalador: SHA-256 do ZIP `B533C0EE7183CF5B7040BEE3C017A9C36D156AEA0150B22055839FF08A01C477`; instalação concluída; atalhos, ARP, serviço, conectividade e acesso fim a fim após reinicialização aprovados pelo operador.
- Aplicativo instalado: `C:\Program Files\DRGinfo Acesso Remoto\DRGinfo Acesso Remoto.exe`; SHA-256 registrado do EXE `C07C317C4C83749D2E08114B0A370C9BA520C359E2214318C9C57D614EEA8C8B` (não significa assinatura de origem).
- Serviço `DRGinfo Acesso Remoto`: Running, Auto, LocalSystem, caminho citado com argumento `--service`.
- `icacls /T /C`: 127 objetos em Program Files e 440 em ProgramData, zero falhas em ambos.
- Em todos os objetos exportados, permissões para BUILTIN/Usuários limitadas a RX ou GR,GE; sem concessão de modificação/escrita aos usuários comuns evidenciada nas ACLs exportadas. SISTEMA e Administradores com controle total.
- **ACLs de arquivos e pastas: APROVADAS com base nos relatórios coletados**. Não alterar ACLs que já estejam adequadas.
- **Ainda não avaliado:** DACL do objeto serviço, ACL de registro do serviço, arquivos de perfil AppData, contas de usuário/autenticação, exposição de logs, política de atualizações/telemetria e demais riscos de aplicação. LocalSystem demanda atenção como risco residual de privilégio.
- Authenticode NotSigned: exceção de homologação explicitamente aceita, não equivalendo a assinatura e não autorizando distribuição irrestrita.
- Diretórios históricos de pacotes/releases existentes em ProgramData, protegidos; retenção a revisar sem exclusão automática.

## DACL de serviço e modalidade do instalador — 26/11/2026
- Evidência de `sc.exe sdshow "DRGinfo Acesso Remoto"` fornecida pelo operador: `D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;WD)`.
- DACL do objeto serviço: SYSTEM e Administradores possuem privilégios de gerenciamento; IU/SU possuem consulta/leitura e não possuem SERVICE_CHANGE_CONFIG (DC), SERVICE_START (RP), SERVICE_STOP (WP), WRITE_DAC (WD), WRITE_OWNER (WO) ou DELETE (SD). **Aprovado segundo SDDL fornecido**.
- Escopo restrito à DACL do serviço; SACL de auditoria não é concessão de acesso.
- A homologação de instalação foi executada diretamente pelo motor PowerShell `Instalar-DRGinfo-AcessoRemoto.ps1`. A interface gráfica do instalador **não foi utilizada e permanece pendente de homologação**, sem evidência de falha da GUI.

## Auditoria AppData — 26/11/2026, WIN11PROLAB
- Evidência recebida: `DRGinfo-Auditoria-AppData.txt`, 312 linhas, data de coleta 2026-11-26 14:49:36 -03:00; arquivo completo permanece com operador, não publicar caminhos pessoais no Git.
- 51 objetos, 153 ACEs `Allow` explícitas no relatório e **zero erros**. Todas as ACEs são `FullControl` herdado, distribuídas igualmente entre `NT AUTHORITY\\SYSTEM`, `BUILTIN\\Administrators` e SID/nome do usuário titular do perfil; nenhuma ACE para grupos amplos como Everyone/Users/Authenticated Users no escopo coletado.
- Pastas abrangidas: Roaming do aplicativo, `config/*.toml`, logs, e Local/DRGinfo/RustDesk/Auditoria do usuário da sessão.
- **ACLs AppData: APROVADAS no escopo efetivamente coletado**, sem necessidade de alterar permissões.
- Limites: somente metadados ACL; não foram lidos segredos, logs nem conteúdo TOML; não cobre todos os perfis, arquivos do serviço em caminhos diferentes ou eventual configuração global.
- Diretório de auditoria legado identificado com nome RustDesk dentro de Local/DRGinfo: padronização futura, sem exclusão automática.

## Revisão estática — servidor corporativo e atualizações, 26/11/2026
- Revisão analisada: build Windows #10, commit `e1e7c30a5327af1b4ed600be7b3c54f6ebeda253`; nenhuma nova compilação e nenhuma alteração na VM.
- `src/core_main.rs`: no Windows, após `global_init()`, chama `load_embedded_drginfo_client()` (em vez do carregamento de `custom.txt`).
- `src/common.rs`: `load_embedded_drginfo_client()` atribui `APP_NAME=DRGinfo Acesso Remoto`, `custom-rendezvous-server` e `relay-server` para `drgvps.drginfo.com.br`, e `key` com chave pública do servidor. Requer revisão separada das possibilidades de alteração em tempo de execução da UI e demais rotas CLI.
- `src/common.rs`: `check_software_update()` retorna para cliente customizado; `do_check_software_update()` retorna antes de consulta oficial para cliente customizado.
- `src/updater.rs`: `check_update()` retorna antes de consulta/download ao detectar cliente customizado; caminho root/macOS também o impede.
- `flutter/lib/common.dart`: `checkUpdate()` não inicia consulta pela UI do cliente customizado; `flutter/lib/desktop/pages/desktop_home_page.dart` não exibe card de atualização RustDesk quando `bind.isCustomClient()`.
- **Revisão estática dos controles citados: APROVADA**. Não alegar prova de ausência de todo o tráfego de rede do fornecedor sem auditoria de tráfego; essa verificação permanece fora do escopo.
- Pendências: revisar política de mudanças de configuração via UI/CLI (se for requisito de imutabilidade), autenticação e links corporativos; não alterar a build homologada sem controle de versão.

## Revisão P4.23 — Bloqueio de configurações corporativas, 26/11/2026
- Revisão dos caminhos atuais em `src/common.rs`, `src/ui_interface.rs`, `src/ipc.rs` e `src/core_main.rs`, branch `fix/drginfo-windows-startup-diagnostics`.
- O recebedor IPC `Data::Options(Some(...))` rejeita chaves corporativas antes da persistência via `trusted_devices::config::update_options`; as rotas de envio UI/CLI/IPC têm filtros adicionais.
- Os mapas de opções são substituições completas, portanto a filtragem de chaves corporativas remove valores dessas chaves dos mapas de opções locais/IPC. Não se deve interpretar isso como preservação byte a byte do TOML anterior. Os valores corporativos devem continuar efetivos via `OVERWRITE_SETTINGS`; precedência e sincronização real ainda exigem teste de regressão.
- Adicionado teste unitário Windows em `src/common.rs`: quatro chaves protegidas rejeitadas como gerenciadas e cinco preferências comuns não bloqueadas. **Teste incluído, NÃO EXECUTADO** nesta etapa.
- A revisão pontual não substitui a verificação de todas as origens alternativas (`Config::set_options` diretas, sincronismo, importação, perfil, inicialização de processos); não alegar imutabilidade total antes de análise/execução.
- Critérios antes da aprovação: compilação Windows; preservar conexão ao servidor DRGinfo, relay e chave pública após reinício; confirmar bloqueio pela UI/CLI/IPC; confirmar que mudanças comuns permanecem funcionais; confirmar tentativa de redirecionamento não altera a conexão; nenhum segredo nos logs; rollback da build #10.
- **Status: revisão estática pontual e teste fonte registrados; build e testes funcionais pendentes. Não foi iniciada compilação GitHub Actions.**

## P4.30 — Pré-validação estática consolidada e controle do custo de builds (26/11/2026)
- Analisados diretamente no HEAD da branch: `src/common.rs`, `src/core_main.rs`, `src/ipc.rs`, `src/ui_interface.rs`, `src/trusted_devices/config.rs`, `src/platform/windows.rs`, os workflows DRGinfo e a revisão fixada do submódulo `hbb_common`.
- **Falha operacional confirmada e corrigida:** `.github/workflows/drginfo-diagnostico-windows-x64.yml` continha `on.push` para a branch de desenvolvimento, com `src/common.rs` e `src/core_main.rs` nos filtros. Isso podia iniciar builds Rust/Flutter caros a cada commit nesses arquivos, mesmo sem `workflow_dispatch`. Workflow agora aceita **apenas disparo manual**; commit `5c708118fbdac464840217e141a569ced341df68`. A mudança não cancela execuções que possam ter sido enfileiradas antes.
- O workflow `drginfo-build-windows.yml` é manual/reutilizável (`workflow_dispatch`/`workflow_call`); o `ci.yml` possui push apenas na branch `master` e PR, não o push direto nesta branch de correção. Eventuais outros workflows e execução anterior devem ser verificados separadamente.
- Gate estático existente na rotina diagnóstica verifica identidade/branding e presença de configurações antes do build, mas **não** testa todos os bloqueios DRG-WIN-006, precedência de API nem sincronismo de autenticação; não tratar `DRGINFO_PREBUILD_STATIC_GATE=PASS` como homologação.
- Verificação estática textual e de referências concluída; **não equivale a `cargo check`, `cargo test`, Flutter analyzer nem build**. Testes específicos já adicionados ainda não executados.
- Riscos residuais: `setServerConfig()` do Flutter pode informar sucesso mesmo quando o núcleo recusa alterações gerenciadas; interface deve impedir edição/importação dessas chaves para evitar falso feedback. O `api-server` retorna vazio na edição Windows, o que intencionalmente desativa recursos de conta dependentes de API. Revisar regressões em homologação.
- A build #10 existente permanece sendo a única build homologada; nenhuma nova compilação foi **solicitada** nesta etapa. Antes de fazer nova build, verificar runs anteriores e confirmar que não existe build disparada por commits antigos.

## P4.31 — Bloqueio da edição de servidor na UI Flutter (26/11/2026)
- `flutter/lib/desktop/pages/desktop_setting_page.dart`: opção de abrir `ID/Relay Server` ocultada quando `isWindows && isCustomClient`, mantendo opções de proxy/WebSocket e preferências comuns.
- `flutter/lib/common.dart::importConfig()`: na mesma edição, recusa importação de configuração de servidor e informa ao usuário que somente a DRGinfo gerencia esse recurso.
- `flutter/lib/common.dart::setServerConfig()`: retorna `false` antes de alterar controladores/UI ou emitir `mainSetOption`, evitando confirmação falsa de gravação por chamadas alternativas.
- Outros sistemas operacionais e o RustDesk sem customização continuam utilizando o caminho original.
- Commits: `53f3bdbde8c41b50770bae723bcf8b5b93493118` e `4c4130802519c2ff6565ad854e4893ed63faf698`.
- **Pendências:** Flutter analyzer/compilação não executados; verificar que todas as entradas da caixa de servidor foram cobertas, inclusive deep links. A regra de proteção efetiva continua em Rust; ocultar UI não é um limite de segurança isolado. A build #10 permanece homologada no escopo anterior, inalterada.

## Homologação da auditoria local (Fase 1)

Pré-requisito: patch aplicado em branch de teste, build Windows x64 gerada pelo workflow `drginfo-diagnostico-windows-x64.yml`.

1. Compilar e confirmar que a identidade DRGinfo permanece inalterada.
2. Iniciar o serviço e verificar ACL de `ProgramData\DRGinfo Acesso Remoto\auditoria\sessoes`: somente SYSTEM e Administradores, sem herança.
3. Conexão assistida com aceite: eventos `aceita` e `encerrada` com o mesmo `session_id`, modo `assistido`.
4. Conexão com senha permanente: modo `nao_assistido`.
5. Recusa: nenhum evento `aceita`; evento `recusada` no encerramento.
6. Conferir em cada linha: UTC, `duration_seconds`, `peer_id`, `peer_name`, `origin_ip`, JSON válido e ausência de credenciais ou conteúdo remoto.
7. Forçar falha de escrita (diretório sem permissão) e confirmar erro no log sem interromper a conexão.
8. Retenção: criar registros com `started_at_utc` de 91 dias e 89 dias em arquivo de teste; após a purga, somente os de 89 dias permanecem e o arquivo temporário não fica no diretório.
9. Dois processos servidores disputando o mutex: nenhuma linha perdida após purga concorrente.
10. Reinício e encerramento abrupto: o evento `aceita` permanece no arquivo.

Critério: todos os itens executados e documentados com data, operador e resultado.
