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
