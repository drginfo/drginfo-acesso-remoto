# DRGinfo — Tratamento da segunda opinião (25/11/2026)

## Baseline e critérios
Fonte da análise: `analise-segunda-opiniao-2026-11-25.md` recebido pelo proprietário, base `04b0faa2e7ca42e0c378cb49a4f5adaa151609e2`. Software funcional `1.5.3-drginfo.2`, build #5, commit fonte `46a287a255106968b01614f5c6dd79b9801f0f06`. SHA256 ZIP software `7770f8d6b61217568124bbb2fb96d482621ba52fbf1c8ceff2cd31a2ef776525`. As alterações abaixo não reescrevem o ZIP homologado.

## Alterações em fonte (não homologadas)

- **P3 / CR-001:** `src/updater.rs` agora retorna antecipadamente de `check_update` quando `crate::is_custom_client()`; evita que a atualização manual use a busca upstream do RustDesk. Commit `76bcfee0f327d3a73e7342950f4409566c6a1a1e`. Exige nova compilação e teste de tráfego.
- **P1 / CR-002:** `install/windows/Interface-DRGinfo-AcessoRemoto.ps1` não passa mais `-AllowUnsigned` indiscriminadamente: exige `PublisherThumbprint` por padrão e limita `UnsignedPilot` à release/hash legado. Commit `63b99a5176bd7a43320d1b02e09ab0ebf0b8e159`. Exige novo gerador/manifesto e teste em Windows. **Não usar esta política como comprovação de binário assinado**. O motor mantém possibilidade explícita de laboratório.

## Registro P1 a P11

| ID | Status | Encaminhamento obrigatório |
|---|---|---|
| P1 Authenticode | Fonte modificada, não testada | Build instalador novo, certificado OV, fluxo fail-closed e verificação |
| P2 LocalSystem/ACL | Pendente | Obter `icacls`/DACL da VM, verificar pastas pai, EXE/DLL e IPC |
| P3 Updater RustDesk | Fonte modificada, não testada | Nova build, teste botão manual e captura de rede |
| P4 Links upstream | Pendente | Revisar telas e definir URLs DRGinfo válidas sem apagar créditos legais |
| P5 Signing remoto | Pendente | Confirmar operador de `SIGN_BASE_URL` e verificar condição do workflow, sem expor segredos |
| P6 SBOM/proveniência | Pendente | CycloneDX/Syft, cargo-audit, cargo-deny, atestados e pin de commits |
| P7 Branch paralela | Baseline definido | Atual `feat/drginfo-embedded-config`; preservar outra branch como histórica |
| P8 Consentimento/sessão | Pendente | Requisitos e testes de autorização, logs, política de senhas e MFA para técnico |
| P9 AGPL | Bloqueador comercial | Entregar fonte correspondente, scripts de build, patches e licenças por release |
| P10 Handoff antigo | Classificado histórico | Colocar aviso no documento antigo |
| P11 Dados em capturas | Pendente | Redigir screenshots e invalidar senha temporária divulgada |

## PDCA e ITIL 4

- **PLAN:** matriz, risco, baseline e responsabilidades; gestão de mudanças e segurança da informação.
- **DO:** duas correções em fonte, sem reempacotar nem publicar a versão existente.
- **CHECK:** compilar e testar updater, assinatura, ACL, hashes públicos, SBOM, comportamento portátil, termos e LGPD.
- **ACT:** formalizar aprovação e tag, atualizar documentação e processos de release/rollback e somente então autorizar distribuição pública.

## Limites e parecer

Nenhuma VPS/VM foi acessada nesta rodada; não se confirmaram ACLs reais, arquivos ZIP físicos, configuração de GitHub secrets, assinatura ou condições de privacidade. O revisor externo também marcou esses itens não verificados. Não há parecer jurídico definitivo. A modalidade offline gui6 e o portátil foram homologados funcionalmente na VM pelo operador, mas **não passaram nova auditoria completa de segurança**.

**Decisão:** correções iniciais e documentação OK; **liberação comercial irrestrita NÃO OK** até a resolução dos bloqueadores acima.

## Evidência P2 — WIN11PROLAB, 26/11/2026 07:55:35 -03:00
Relato do operador, auditoria somente leitura (arquivo `DRGinfo-Auditoria-Windows-20261126-075535.md`):
- Software 1.5.3-drginfo.2, EXE SHA256 `58FC2C5E09782543951E42E3A7E06B9AA26AB57DF7EFE4E651A3596AA7CE3454` — confere com a release conhecida.
- Authenticode `NotSigned`; serviço `DRGinfo Acesso Remoto` `Running`, `Auto`, `LocalSystem` e caminho entre aspas em `C:\\Program Files\\DRGinfo Acesso Remoto\\DRGinfo Acesso Remoto.exe --service`.
- Registro ARP e atalhos Desktop e Menu Iniciar presentes.
- `C:\\Program Files\\DRGinfo Acesso Remoto`: grupo Usuários apenas RX / GR,GE, sem ACE de escrita explícita no diretório listado. Provisoriamente adequado para executável de serviço; DACLs de arquivos e ACLs do próprio serviço ainda não conferidas.
- `C:\\ProgramData\\DRGinfo\\AcessoRemoto`: `BUILTIN\\Usuários:(I)(CI)(WD,AD,WEA,WA)`, herdado e propagável a contêineres filhos. **Potencial de escrita não privilegiada** em subdiretórios/arquivos, dependente de herança, ACEs adicionais e uso pelo processo SYSTEM.
- **P2 = ABERTO / NECESSITA TRIAGEM DIRECIONADA**. Evidência insuficiente para declarar exploração ou segurança da cadeia de arquivos de ProgramData. Não modificar DACLs sem inventário, avaliação de compatibilidade e rollback.
- Próxima coleta: inspeção somente leitura dos subdiretórios packages/tools, arquivos release/manifestos/logs e ACL do próprio serviço (SDDL via sc.exe sdshow), com saída redigida para segunda avaliação.

## Segunda coleta P2 — 26/11/2026 07:59:13 -03:00
Fonte: saída `P2-ACL-Detalhada.txt` comunicada pelo operador em WIN11PROLAB, sem coleta direta da VM por este revisor.

- `ProgramData\\DRGinfo\\AcessoRemoto`, `packages`, `releases` e `tools` apresentam `BUILTIN\\Usuários:(I)(CI)(WD,AD,WEA,WA)` — ACE herdada de escrita/criação para diretórios e descendentes; verificar ACEs em arquivos individualmente antes de concluir permissões efetivas.
- `instalacao.log` e `manifesto-sha256.csv`: Usuários apenas RX (não é evidência de gravação por usuário nesses arquivos).
- SDDL do serviço: `SY` e `BA` possuem direitos de controle; `IU` e `SU` recebem consulta/leitura, sem `DC`, `WD` ou `WO` de alteração; o descritor de segurança do serviço não indica permissão administrativa para usuário comum.
- `Program Files\\DRGinfo Acesso Remoto`: Usuários apenas RX. O executável conferiu com SHA256 do build #5, não assinado.
- O código em `Instalar-DRGinfo-AcessoRemoto.ps1` usa `packages/<sha>/package.zip`, `packages/<sha>/extracted` e `tools/Desinstalar-DRGinfo-AcessoRemoto.ps1` durante instalação/remoção com elevação. A criação dos diretórios ocorre antes da confirmação de administrador; recomenda-se corrigir a ordem e fixar ACLs antes do uso dos pacotes. O hash do ZIP reduz adulteração do arquivo, mas não cobre toda a árvore extraída em toda reutilização.
- **Veredito P2: RISCO REAL DE CONFIGURAÇÃO / ABERTO PARA CORREÇÃO DE ACL E FLUXO DE INSTALAÇÃO.** Ainda não há demonstração de exploração, nem análise dos objetos descendentes e permissões efetivas.
- **Plano corretivo:** proteger a raiz e os diretórios operacionais com ACEs explícitas para SYSTEM/Administradores e leitura para Usuários; preservar backup da DACL e rollback; corrigir fonte do instalador para não recriar estrutura insegura; validar serviço, remoção e permissões em VM. Não aplicar `icacls /reset` indiscriminadamente nem remover ACLs de perfis do aplicativo.

## P2 — implementação de proteção de ACL no instalador (26/11/2026)
- Fonte: `install/windows/Instalar-DRGinfo-AcessoRemoto.ps1`.
- Commit inicial `ab2c9c68512d452956749b5f131e70ca4f9f6d76`; correção de construtores .NET em `7b61be2f029f9685fcc0397f9c5e362fc8c72af5`.
- Mudança 1: exige administrador e Windows x64 ANTES de criar as pastas ou gravar logs.
- Mudança 2: restringe ACL das pastas gerenciadas ao escopo `%ProgramData%\\DRGinfo\\AcessoRemoto`, sem alterar `C:\\ProgramData` global ou perfis.
- Mudança 3: usa SIDs invariantes do Windows `S-1-5-18` SYSTEM, `S-1-5-32-544` Administradores (FullControl) e `S-1-5-32-545` Usuários (ReadAndExecute), sem dependência de idioma.
- Mudança 4: protege a raiz e os subdiretórios `packages`, `releases`, `tools` e a pasta do pacote antes de abrir ZIP, extrair, usar DLL ou registrar serviço. Também ajusta os objetos já presentes nessa árvore, recusando reparse points.
- Estado: **IMPLEMENTADO EM FONTE, NÃO VALIDADO EM VM**. Pode haver incompatibilidade com arquivos ou ferramentas que dependam de gravação sem elevação. Não executar em cliente real antes de teste.

### Plano de teste controlado P2 — QA Windows 11
1. Capturar snapshot de VM; exportar DACL do diretório gerenciado antes do teste com `icacls "C:\\ProgramData\\DRGinfo\\AcessoRemoto" /save "%TEMP%\\drginfo-acl-previo.txt" /T`, com arquivo protegido e leitura humana do resultado.
2. Obter versão de pacote nova (gui7 ou superior) que incorpore o instalador no commit corrigido, sem sobrescrever `gui6` ou os ZIPs homologados.
3. Conferir hash/SHA do script, passar pelo parser PS 5.1 e inspecionar o diff da versão.
4. Instalar em VM limpa/snapshot e validar `icacls` da raiz, `packages`, `releases`, `tools`, arquivos e subpastas. Confirmar ausência de escrita por conta padrão, inclusive criação de subdiretórios.
5. Validar serviço `LocalSystem`, conexões reais, atalhos, ARP, desinstalação e logs.
6. Repetir a instalação em VM com diretório antigo do gui6 e confirmar que a migração de permissões e o rollback funcionam sem perder registros.
7. Em falha: interromper publicação, retornar snapshot; usar backup de ACL apenas se o rollback for necessário, com avaliação do administrador.

### Limites e acompanhamento
- Nenhuma alteração de ACL foi aplicada nesta conversa à VM ou à VPS.
- Não há ainda evidências de PS 5.1 executando o instalador alterado ou dos direitos efetivos pós-correção.
- O pacote `gui6` continua histórico/homologado funcionalmente, mas com a configuração P2 anterior.
- Para fechar P2, precisam ser anexados relatório `icacls` pós-mudança, teste de escrita negada ao usuário comum, hash do instalador corrigido e logs de regressão.

## P2 — Validação de ACL na WIN11PROLAB (26/11/2026, 08:28 -03:00)
**Origem:** log `Texto colado(1).txt`, fornecido pelo operador; não houve acesso direto à VM nesta revisão.

1. Operador verificou previamente existência do script corrigido e pacote `packages/7770f8d6.../package.zip`; `Get-FileHash` do pacote correspondeu a `7770f8d6b61217568124bbb2fb96d482621ba52fbf1c8ceff2cd31a2ef776525`.
2. Backup `icacls /save /T /C` salvo em `C:\ProgramData\DRGinfo\Auditorias\P2-ACL-ANTES.txt`; **299 arquivos/diretórios processados; zero erros**.
3. Execução do instalador da revisão `7b61be2f029f9685fcc0397f9c5e362fc8c72af5` com `-PackageFile`, `-PackageSha256`, `-PackageVersion 1.5.3-drginfo.2`, `-AllowUnsigned`, `-ValidateOnly`.
4. Log apresentou `P2: ACLs gerenciadas verificadas`; pacote SHA-256 validado; modo `ValidateOnly` aprovado; `P2_VALIDATE_EXITCODE=0`. A execução **modificou ACLs**, mas não reinstalou o software nem alterou serviço, segundo a semântica documentada desse modo.
5. `icacls` pós-ação confirmou nas pastas raiz, `packages` e `tools`: SYSTEM `(OI)(CI)(F)`, Administradores `(OI)(CI)(F)`, Usuários `(OI)(CI)(RX)`, sem ACE de gravação para Usuários nos diretórios listados.

**Conclusão específica:** implementação e execução do endurecimento de ACL nas pastas exibidas **APROVADAS**. Não significa homologação final de P2 ou aprovação de distribuição comercial.

**Pontos a encerrar:** saída pós-correção de `releases` e dos objetos relevantes; tentativa de criação de arquivo por usuário comum com resultado `Access Denied` (sem privilégio elevado); avaliação de perfis/grupos específicos; teste de regressão de nova instalação/desinstalação gui7. O hash e o binário atual permanecem imutáveis e sem Authenticode.

## P2 — ACL releases e desinstalador (26/11/2026, terceira evidência)
Fonte: saída `icacls` fornecida pelo operador após execução de `ValidateOnly` em WIN11PROLAB.
- `C:\\ProgramData\\DRGinfo\\AcessoRemoto\\releases`: `SYSTEM:(OI)(CI)(F)`; `Administradores:(OI)(CI)(F)`; `Usuários:(OI)(CI)(RX)`. Sucesso: 1 arquivo, 0 falhas.
- `C:\\ProgramData\\DRGinfo\\AcessoRemoto\\tools\\Desinstalar-DRGinfo-AcessoRemoto.ps1`: `SYSTEM:(F)`; `Administradores:(F)`; `Usuários:(RX)`. Sucesso: 1 arquivo, 0 falhas.
- Resultado: **ACLs exibidas OK**; sem ACE de gravação concedida a Usuários nesses objetos. Não é medição de permissões efetivas por identidade/associações de grupos, tampouco verificação exaustiva do conteúdo.
- Gate para encerramento de P2: testar impossibilidade de escrita por uma conta padrão, sem elevar, e regressão da próxima instalação/desinstalação com o instalador corrigido. A release gui6 anterior continua imutável.

## P2 — Teste negativo com usuário padrão (26/11/2026)
Evidência comunicada pelo operador a partir de PowerShell sem elevação em `PS C:\\Users\\daniel>`: tentativa de `[System.IO.File]::WriteAllText` em `C:\\ProgramData\\DRGinfo\\AcessoRemoto\\packages\\teste-p2-acl.tmp` resultou em **`P2=OK - acesso de gravacao negado`**. O `catch` digitado posteriormente de forma isolada produziu `CommandNotFoundException`, erro de sintaxe interativa sem relação com o resultado anterior; não é necessário repetir a prova.

**Conclusão do controle de escrita:** aprovado para a identidade padrão testada na pasta `packages`. **P2 permanece pendente exclusivamente do teste de regressão de instalação/desinstalação com novo pacote contendo a correção**; não declarar comercialmente homologado antes disso. Teste de permissões efetivas não representa garantia absoluta sobre todas as identidades e caminhos.

## Gui7 — pacote de regressão P2, preparação 26/11/2026
- Fonte do gerador `install/windows/Gerar-Pacote-Instalador.ps1` ajustada no commit `6cdaf7bcc8380d880fbe3c4060379ff449cda1fb`; **somente release `1.0.0-gui7`**.
- Arquivos do payload baixados a partir do commit imutável `1cb50f277eb33cb497b7d8e364a2de3ce0f71624`, que inclui correção P2 do motor e ajuste P1 da interface. Não utiliza a versão histórica gui6.
- Integridade: pacote de software fixado ao SHA256 `7770f8d6b61217568124bbb2fb96d482621ba52fbf1c8ceff2cd31a2ef776525`, versão `1.5.3-drginfo.2` e URL oficial. `UnsignedPilot = $true` é exigido para este único binário legado em laboratório; demais versões não são aceitas.
- Saída esperada (gerador executado pelo operador em PowerShell 5.1 elevado): `C:\\ProgramData\\DRGinfo\\AcessoRemoto\\releases\\installer-gui\\1.0.0-gui7\\DRGinfo-Instalador-Windows-x64.zip`, `release.txt` e `manifesto-sha256.csv`.
- **Não gerado por este revisor**: execução Windows, ZIP e SHA256 final dependem da VM; não declarar pacote publicado nem testado. Gui6 permanece imutável.
- Validação gui7 requer snapshot; eventual desinstalação do gui6 somente após snapshot; execução gui7, inspeção ACLs, serviço/atalhos, E2E, desinstalação/rollback; documentação das evidências.

## GUI7 — resultado de geração informado pela VM (26/11/2026)
O operador relatou saída do gerador gui7:
- `PACOTE: C:\\ProgramData\\DRGinfo\\AcessoRemoto\\releases\\installer-gui\\1.0.0-gui7\\DRGinfo-Instalador-Windows-x64.zip`.
- SHA256 reportado: `CEE32A62E8719E2715B32AB66A13C9C814FDAAFE88B77C35FDF72376C9CC0483`.
- `MANIFESTO: C:\\ProgramData\\DRGinfo\\AcessoRemoto\\releases\\installer-gui\\1.0.0-gui7\\manifesto-sha256.csv`.
- Gerador afirmou consolidação; teste UAC em VM limpa ainda pendente.
- **Status: ZIP gerado segundo operador; hash apenas reportado, aguardando verificação independente, arquivo por arquivo, release-config e validação de integridade do ZIP.** Não distribuir para clientes.

## Adendo de segunda opinião — decisão de negócios e segurança, 26/11/2026
**Origem:** arquivo enviado pelo proprietário `analise-segunda-opiniao-2026-11-25(1).md` (a análise-base é de 25/11; a decisão inserida é de 26/11). O documento usa como base o commit histórico `04b0faa`, portanto suas observações sobre P1, P2 e P3 não refletem necessariamente os ajustes já incorporados na branch atual.

### Decisão DEC-2026-11-26-01 — não adquirir certificado Authenticode agora
- **Decisão aprovada pelo proprietário:** concluir a fase do projeto sem certificado de assinatura de código. A decisão é financeira; não equivale a declarar assinatura desnecessária.
- **Risco residual R02/P1:** executáveis sem Authenticode, alerta de editor desconhecido/SmartScreen e ausência de autenticação criptográfica do editor. Classificação **ACEITO TEMPORARIAMENTE** pelo proprietário. Aceite não dispensa integridade de transporte, pinagem SHA-256 e distribuição controlada.
- **Controle compensatório obrigatório antes de qualquer entrega:** publicar SHA-256 do ZIP por canal HTTPS independente do download, registrá-lo também em comunicação contratual/e-mail independente e instruir cliente a verificar o valor; impedir substituição silenciosa da versão e arquivar evidência do hash conferido.
- **Restrição:** `UnsignedPilot` permanece explicitamente vinculado à versão `1.5.3-drginfo.2` e ao SHA-256 `7770f8d6b61217568124bbb2fb96d482621ba52fbf1c8ceff2cd31a2ef776525` no instalador gui7; nenhuma permissão genérica para artefatos futuros. Se for proposta outra release sem assinatura, deve passar por novo aceite de risco, hash próprio e testes.
- **Gatilhos de revisão:** primeira receita gerada pelo serviço OU exigência contratual de assinatura por cliente, o que ocorrer primeiro. Revisar orçamento, certificado e medidas de distribuição.
- **Comunicação obrigatória:** informar no termo/treinamento que o Windows pode exibir aviso de editor não identificado; nunca instruir a desativar SmartScreen, antivírus ou UAC.
- **Limites legais:** aceite técnico/comercial não substitui observância da AGPL-3.0, LGPD, contrato e revisão jurídica. Sem verificação desses pontos não declarar pronto para venda pública.

### Estado reavaliado dos achados P1–P11
| Item | Reavaliação em 26/11 |
|---|---|
| P1 | Risco Authenticode **aceito temporariamente**, gui7 com `UnsignedPilot` restrito por versão e hash; canal independente de hash ainda pendente |
| P2 | Hardening de ACL aplicado e demonstrado na WIN11PROLAB, inclusive recusa de escrita a usuário comum; regressão gui7 instalação/desinstalação pendente |
| P3 | Guarda de cliente personalizado inserida em `src/updater.rs` (commit `76bcfee`); binário build #5 permanece anterior à correção, requer **novo build e teste de rede** |
| P4 | Links externos RustDesk precisam de inspeção/ajuste |
| P5 | Verificação do operador/secret de assinatura remota no workflow e logs do build #5 ainda pendente |
| P6 | SBOM/SCA/proveniência pendentes |
| P7 | Branch candidata atual `feat/drginfo-embedded-config`; registrar linha Android como histórica |
| P8 | Especificação de consentimento/código temporário/visibilidade e autenticação do técnico pendente |
| P9 | Pacote de código-fonte correspondente AGPL e procedimentos de oferta pendentes |
| P10 | Handoff histórico deve receber indicação de obsolescência |
| P11 | Procedimento de anonimização/rotação de IDs/senhas em capturas pendente |

### Decisão de liberação
- **GUI7**: somente laboratório até evidência de regressão e hashes independentes.
- **Piloto pago**: hipótese condicionada a correção/aceite dos demais riscos, termo e contrato, entrega de fonte correspondente, verificação de versão realmente corrigida para P3, avaliações de segurança e LGPD.
- **Distribuição pública**: não autorizada nesta etapa.

### Próximos passos de maior prioridade
1. Concluir auditoria independente da gui7: conferir hash `CEE32A62E8719E2715B32AB66A13C9C814FDAAFE88B77C35FDF72376C9CC0483`, arquivos e configuração.
2. Realizar regressão gui7 em snapshot Windows (instalar, reiniciar, conectar, desinstalar e rejeitar hash adulterado).
3. Preparar canal HTTPS separado para SHA-256 e instruções de verificação para o cliente.
4. Entregar fonte correspondente à versão distribuída (AGPL) e atualizar o código compilado para incorporar P3 antes de nova release.
5. Revisar P4/P5/P6/P8/P11, LGPD e termo antes de qualquer distribuição.

## GUI7 — conferência independente comunicada pelo operador (26/11/2026)
- Ambiente de homologação: WIN11PROLAB.
- ZIP: `C:\ProgramData\DRGinfo\AcessoRemoto\releases\installer-gui\1.0.0-gui7\DRGinfo-Instalador-Windows-x64.zip`.
- Hash esperado e conferido pelo script: `CEE32A62E8719E2715B32AB66A13C9C814FDAAFE88B77C35FDF72376C9CC0483`.
- Operador informou `GUI7_HASH=OK`, `GUI7_ESTRUTURA=OK`, `GUI7_CONFIGURACAO=OK`, `GUI7_PRONTA_PARA_HOMOLOGACAO`.
- Interpretação: aprovação da verificação de ZIP por SHA256, presença dos arquivos obrigatórios e configuração `UnsignedPilot`/hash de software. **Não equivale a assinatura Authenticode, teste de arquivos internos byte a byte contra manifesto, nem homologação funcional.**
- Próximo gate: snapshot da VM; desinstalação gui6 com registro de resultado; instalação gui7 (somente laboratório), checagem de ACLs, serviço, reinício, conectividade, rollback e desinstalação.
- Não publicar nem substituir pacotes anteriores.

## GUI7 — pré-requisito da reinstalação (26/11/2026)
- Operador informou `GUI6_REMOVIDA=OK`, a partir de inspeção de ausência do serviço Windows `DRGinfo Acesso Remoto` e da pasta `C:\Program Files\DRGinfo Acesso Remoto` na WIN11PROLAB.
- Estado: gui6 removida conforme controle definido. Snapshot ainda não comprovado por saída; confirmar antes da instalação. Preservar `ProgramData` e o ZIP gui7 já verificado.
- Próximo passo: executar `instalador-drginfo.cmd` do diretório `releases\installer-gui\1.0.0-gui7\payload` e coletar status; registrar testes de UAC, log, serviço e ACL em sequência.

## GUI7 — instalação gráfica concluída, evidências de 26/11/2026 08:50 (-03:00)
**Origem:** quatro capturas da WIN11PROLAB e log de instalação transmitidos pelo operador. Capturas incluem ID e senha temporária em uma tela do aplicativo: **não replicar os valores em documentação nem anexar imagem sem mascarar; rotacionar senha exibida**.

- Interface gráfica com identidade DRGinfo, mensagem `Instalacao detectada | Servico DRGinfo: em execucao` e progresso concluído.
- Log: `08:50:29 P2: ACLs gerenciadas verificadas`; SHA-256 do software `7770F8D6B61217568124BBB2FB96D482621BA52FBF1C8CEFF2CD31A2EF776525` conferido; modo de cliente sem assinatura reconhecido e previamente aceito para piloto; release validada.
- Log: `08:50:31` criação do serviço `Win32_Service.Create` e início; `08:50:36` registro em Aplicativos instalados, atalhos públicos `Desktop` e `Menu Iniciar`; `INSTALACAO CONCLUIDA. Servico automatico em execucao.`
- Tela do aplicativo aberta com interface DRGinfo e estado `Pronto`; configuração do servidor ID/Relay e chave pública presentes; campo API vazio apresenta aviso do cliente. **Não assumir exigência de API funcional apenas pelo aviso; verificar funcionalidade e modelo do servidor antes de mudar**.
- Registro em Aplicativos instalados exibe `1.5.3-drginfo.2` e editor DRGinfo.
- **Resultado:** gui7 **instalação gráfica e registro de serviço aprovados**; ainda não há prova de conexão ponta a ponta após gui7, reinício nem desinstalação gui7. O cliente em gui7 mantém binário build #5, anterior à correção P3 em código.
- **Segurança de evidências:** não versionar imagens originais que exibam senha temporária/ID; solicitar rotação da senha e mascaramento antes de arquivar capturas.

## GUI7 — persistência pós-reinício (26/11/2026)
Operador informou resultado de `Get-CimInstance Win32_Service -Filter "Name='DRGinfo Acesso Remoto'"` após reiniciar WIN11PROLAB:
`Name=DRGinfo Acesso Remoto`, `State=Running`, `StartMode=Auto`, `StartName=LocalSystem`.
**Resultado:** PASS — serviço persiste e inicializa automaticamente após reboot. Prova de conexão remota E2E após GUI7 ainda não fornecida; em seguida verificar desinstalação e encerrar P2.

Observação de privacidade: operador esclareceu que ID mostrado pertence à VM descartável e senha temporária muda após sessão. Ainda assim, não incluir valores em artefatos públicos.

## GUI7 — conexão ponta a ponta validada (26/11/2026)
- Operador comunicou `Conexão_gui7=ok` após instalação gui7 e reinicialização da WIN11PROLAB.
- **Resultado: PASS — conexão remota E2E**, evidência declarada pelo operador; sem dados de sessão incluídos por privacidade.
- Resultado cumulativo gui7: integridade ZIP verificada; instalação GUI, serviço, atalhos e ARP observados; reinício com serviço `Running/Auto/LocalSystem`; conexão E2E confirmada.
- **Último gate de regressão P2:** desinstalação gui7; depois verificar serviço, executável, chave ARP, atalhos Desktop/Menu Iniciar; preservar diretório ProgramData e evidências para auditoria.
- O resultado gui7 ainda **não** significa que o aplicativo foi recompilado com a correção P3 nem que todos os riscos de distribuição foram encerrados.

## Encerramento de P2 / GUI7 — 26/11/2026
O operador da WIN11PROLAB comunicou `GUI7_DESINSTALACAO=OK`, após teste da rotina de desinstalação em Aplicativos instalados. O script de verificação só retorna OK quando todos os seguintes itens estão ausentes:
- Serviço `DRGinfo Acesso Remoto`
- Diretório `C:\Program Files\DRGinfo Acesso Remoto`
- Registro ARP `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DRGinfoAcessoRemoto`
- Atalho em `Public\Desktop`
- Atalho em `ProgramData\Microsoft\Windows\Start Menu\Programs\DRGinfo`

**Resultado do teste de regressão:** PASS. A sequência documentada foi SHA256/estrutura/config da gui7, instalação via GUI, logs de ACL hardening, persistência pós-reboot `Running/Auto/LocalSystem`, sessão remota fim a fim, desinstalação e inspeção dos cinco itens acima. A tentativa de escrita em `packages` por usuário padrão foi previamente negada. O teste de integridade do pacote utilizou o ZIP gui7 SHA256 `CEE32A62E8719E2715B32AB66A13C9C814FDAAFE88B77C35FDF72376C9CC0483`.

**P2: ENCERRADO / APROVADO no escopo homologado WIN11PROLAB.** Não é certificação independente contra qualquer cenário de escalonamento de privilégios ou prova das ACLs de todas as futuras instalações. Gui6 histórico permanece imutável; gui7 não publicada. O executável `1.5.3-drginfo.2` do build #5 ainda não incorpora a correção P3 em `src/updater.rs`, e Authenticode permanece não assinado por decisão documentada de aceite de risco.

**Próximos gates:** publicar SHA256 independente (P1 mitigação), novo build de aplicativo incorporando P3, revisão P4/P5/P6/P8/P9/P11, AGPL/LGPD e critérios de liberação controlada. Não afirmar produto pronto para venda pública.

## P3 / P5 — rebuild solicitado por GitHub Actions, 26/11/2026
- Releitura do código atual: `src/updater.rs` contém bloqueio de cliente customizado no início de `check_update(manually)`, antes de `do_check_software_update()`. Também existe guarda no método macOS `check_update_as_root()`.
- P5: workflow `.github/workflows/drginfo-build-windows.yml` recebeu `SIGN_BASE_URL: '-2'` (commit `e7386923e56bd8ed6dcb14caba885452f7826587`). As etapas legadas de assinatura remota são condicionadas a `env.SIGN_BASE_URL != '-2'` e portanto ficam desativadas no build desta revisão. Nenhum segredo de assinatura é solicitado por esta alteração.
- Build disparado por alteração de `branding/BUILD_TRIGGER.md` na branch `feat/drginfo-embedded-config`, commit `d4ca6d4cc280ab37a4702d900cb3c944500dd59a`, conforme filtro `on.push.paths` do workflow.
- **Status CI: solicitado, execução e conclusão ainda NÃO verificadas nesta sessão.** Nenhum artefato novo baixado, validado ou publicado na VPS; não alterar gui7 existente.
- Próximo controle de qualidade: confirmar run associado ao commit, jobs Windows x64, artifact DRGinfo-Acesso-Remoto-Windows-x64, SHA256 e comportamento de update em VM após build.
