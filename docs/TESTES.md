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
