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
