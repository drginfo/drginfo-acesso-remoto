# DRGinfo Acesso Remoto — Encerramento técnico Windows P4

**Data:** 2026-11-27
**Versão:** 1.5.3-drginfo.p4
**Situação:** DESENVOLVIMENTO E HOMOLOGAÇÃO FUNCIONAL WINDOWS CONCLUÍDOS; **HOMOLOGADO PARA PILOTO CONTROLADO**. Distribuição comercial irrestrita depende de release formal, termo de autorização, revisão de privacidade e condições de licença; assinatura digital adiada.

**Reconciliação dos testes posteriores ao mapa preliminar:** ver `P4-RECONCILIACAO-E-CRITERIOS-DE-LIBERACAO.md`. Os testes de instalação nova e desinstalação da P4 foram realizados em 27/11, embora constassem como pendentes no mapa anterior. UAC não possui confirmação explícita separada na evidência enviada.

## Evidências de homologação
- Interface DRGinfo, logotipos, ícones, links e estado `Pronto`: aprovados pelo operador.
- GUI online: nova instalação, download HTTPS real da VPS, SHA-256 confirmado, serviço e conexão fim a fim: aprovados.
- GUI offline: nova instalação com rede virtual desligada e cache original isolado, criação de serviço, atalhos e registros Windows: aprovados. Reconexão recuperou automaticamente estado `Pronto`.
- Versão portátil: uso e sessão remota fim a fim anteriormente aprovados.
- Desinstalação controlada: remoção de serviço, pasta e registro Windows, preservação de logs: aprovada.
- Serviço automático / persistência / integração Windows: homologados.

## Correspondência exata entre binário e código-fonte
- Revisão de código-fonte: `5bbef89a64c707a67a8ff4b5de9c228eb732dc79`.
- Link: https://github.com/drginfo/drginfo-acesso-remoto/tree/5bbef89a64c707a67a8ff4b5de9c228eb732dc79
- Execução GitHub Actions: https://github.com/drginfo/drginfo-acesso-remoto/actions/runs/45929565631
- Artifact ID: `15169411324`, nome `DRGinfo-Acesso-Remoto-Windows-x64`, 35.565.328 bytes.
- SHA-256 do artefato e do ZIP homologado: `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a`.
- Submódulo `libs/hbb_common` na árvore do commit: `450cc1d7b729cfa8d19b5a7527c9cc2fe54cf5eb`.

## Publicação da referência de fonte
- Em 2026-11-27 o operador compartilhou captura da seção publicada `LICENCIAMENTO E CÓDIGO ABERTO`, exibindo o link correto acima, substituindo o link da build #18.
- A captura mostra referência à licença AGPL-3.0, atribuição ao RustDesk e seus titulares. **Confirmação visual do conteúdo mostrado**, sem auditoria independente do endpoint público nem da página inteira.
- Política de privacidade e página Sobre já declaradas como publicadas pelo operador. Não afirmar auditoria jurídica completa nem confirmação independente da URL pública.
- Preservar avisos AGPL e disponibilizar código correspondente, componentes e materiais exigidos pela licença.

## Decisão sobre assinatura Authenticode
- **ADIADA** por decisão de custo: ausência de verba para aquisição de certificado no momento.
- Não afirmar que o executável está assinado ou que o editor é verificado pelo Windows.
- HTTPS e SHA-256 protegem/verificam transporte e integridade do pacote, mas não substituem assinatura do editor.
- Não pedir ao cliente que desabilite globalmente SmartScreen, antivírus ou políticas da organização.
- Reavaliar certificado quando houver receita para financiá-lo; executar validação de assinatura e distribuição quando adotado.

## Identidade do código versus revisão documental
- O build foi disparado em `5bbef89...`; seu pai `18c15907e63a263d0ee9ae35904e85f7778766fd` tem código de execução equivalente: o único arquivo alterado no commit foi `docs/releases/DRGINFO-P4-PLANO-RELEASE.md`, confirmado por comparação de commits no GitHub.
- A identidade do ZIP foi comprovada pelo SHA-256, não apenas pelo tamanho.
- Nome canônico futuro: `DRGinfo-Acesso-Remoto-Windows-x64.zip`; nome atual na VPS: `DRGinfo-AcessoRemoto-windows-x64.zip`. Preservar link antigo até publicação/migração.
- Zero GitHub Releases identificadas na consulta; a futura pré-release deverá conter os quatro ZIPs auditados. **Nenhuma release foi criada neste fechamento.**

## Encerramento e limites
**Encerradas:** alterações de código da Windows P4, builds e homologação funcional, rastreabilidade do ZIP, correção do link de código-fonte na página Sobre conforme captura do operador, documentação.
**Acompanhamento operacional:** verificar regras corporativas de execução e autorização de acesso remoto, política de privacidade, avisos de licença e disponibilidade do Corresponding Source completo. A homologação técnica não substitui avaliação jurídica ou contratual.
**Não realizar novos builds nem alterar funcionalidades da P4 sem requisito novo e homologação específica.**

## Documentos relacionados
- `docs/releases/P4-RASTREABILIDADE-BINARIO.md`
- `docs/releases/P4-PACOTE-ENTREGA-E-OPERACAO.md`
- `docs/releases/P4-CONFORMIDADE-LICENCA-PRIVACIDADE.md`
- `docs/releases/CODIGO-FONTE-P4-PAGINA-SOBRE.md`
- `docs/releases/CHANGELOG-P4.md`
