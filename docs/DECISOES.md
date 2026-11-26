# Decisões de engenharia — DRGinfo Acesso Remoto

## DRG-WIN-001 — Uma única identidade corporativa Windows
**Onde:** src/common.rs, src/core_main.rs, flutter/windows/runner/Runner.rc, ícones, logo, install/windows/Preparar-Distribuicao-DRGinfo.ps1 e workflow Windows.
**Como:** configuração embarcada do nome, servidor, relay e chave pública; UI e empacotamento preservam a nomenclatura DRGinfo; nomes internos de DLLs permanecem originais.
**Por quê:** evitar dependência de custom.txt externo e regressões de branding entre branches.
**Riscos:** nome corporativo no artefato não comprova identidade executável; exige homologação.
**Estado:** implementação recuperada, aprovação da nova build pendente.

## DRG-WIN-002 — Proteção das atualizações oficiais
**Onde:** src/common.rs / do_check_software_update() e src/updater.rs / check_update().
**Como:** retorno antecipado para cliente personalizado; garantir inicialização do nome DRGinfo antes da consulta.
**Por quê:** impedir atualização do cliente white-label por releases oficiais.
**Risco:** outros caminhos de atualização e inicialização ainda exigem homologação funcional.
**Estado:** implementado em fonte; não homologado em EXE.

## DRG-WIN-003 — Preservação e distribuição
**Onde:** install/windows e documentação docs; workflow pré-build.
**Como:** recuperar arquivos já versionados da branch comercial, incluir gate estático, inventário e manifesto; não sobrescrever release anterior.
**Por quê:** rastreabilidade, segurança e rollback.
**Estado:** recuperação de fonte, não atestado de integridade de instalação em produção.

## DRG-WIN-004 — Escopo
Windows x64 primeiro; Linux/Android somente depois de Windows integralmente homologado. Sem aprovação implícita de uma nova release.

## DRG-WIN-005 — Assinatura Authenticode adiada na fase de homologação
**Decisão do responsável, 26/11/2026:** não adquirir certificado de assinatura de código antes de existir demanda comercial/clientes que justifique o custo.
**Onde:** instalador Windows, que dispõe do parâmetro explícito `-AllowUnsigned`, e processo de homologação.
**Como:** instalação exclusivamente na VM de laboratório com aceite explícito de artefato não assinado, SHA-256 calculado do ZIP efetivamente usado, origem e commit registrados. Sem desabilitar SmartScreen/Defender globalmente nem contornar políticas corporativas.
**Por quê:** preservar capital de giro e concluir o produto sem despesa prematura.
**Risco residual:** SHA-256 verifica integridade relativa ao hash de referência, mas não autentica o publicador; alertas SmartScreen e dificuldades de distribuição podem ocorrer.
**Limite:** autorização para laboratório não é autorização automática de distribuição comercial. Reavaliar assinatura e controles antes de fornecer a terceiros.

## DRG-WIN-006 — Configuração corporativa exclusiva da DRGinfo
**Decisão do responsável, 26/11/2026:** somente a DRGinfo está autorizada a alterar o servidor ID/rendezvous, servidor relay e chave pública de autenticação de servidor na edição DRGinfo Acesso Remoto. Qualquer endpoint de API associado à infraestrutura corporativa deve seguir a mesma política de autorização quando configurado.
**Objetivo de produto:** impedir que usuários finais, inclusive via interface, importação de configuração, deep link ou argumentos CLI comuns, redirecionem a aplicação para servidores de terceiros. Operações de alteração devem utilizar mecanismo administrativo exclusivo, auditável e com autorização verificável da DRGinfo; não equiparar simplesmente elevação UAC ou conta administradora local à autorização DRGinfo.
**Implementação requerida:** política central na camada de configuração/IPC, verificação de todas as rotas de escrita e leitura efetiva, preservação de preferências não sensíveis dos usuários e registro de tentativas de mudanças sem registrar segredos. A chave embarcada é pública; nunca embarcar chaves privadas, credenciais ou segredo administrativo reutilizável no cliente.
**Evidência para aprovação:** testes de alteração via UI, CLI, configuração importada e arquivos locais, inclusive sob administrador local, além de teste de manutenção legítima e rollback. Uma simples ocultação de campos na interface não atende o requisito.
**Estado em 26/11/2026:** requisito APROVADO; implementação e testes de imutabilidade/controle de autorização PENDENTES. A build Windows #10 permanece homologada apenas nos testes concluídos; nenhuma mudança de código ou compilação foi realizada por esta decisão.

## DRG-WIN-007 — API corporativa desabilitada até implantação formal
**Decisão técnica provisória, 26/11/2026:** o servidor DRGinfo atualmente homologado para ID/relay é OSS. Não há evidência nesta auditoria de uma API DRGinfo autorizada, implantada e testada; portanto, a edição Windows não deve inferir `http://<servidor-ID>:21114` nem usar `https://admin.rustdesk.com` como fallback.
**Implementação:** em `src/common.rs::get_api_server()`, a edição Windows retorna API vazia. Servidor rendezvous/relay e chave pública continuam embarcados e independentes de API. Os outros sistemas operacionais preservam o comportamento upstream.
**Efeito deliberado:** funcionalidades dependentes de API (conta/login, sincronização de catálogo e outros recursos de servidor de aplicação) ficam indisponíveis nesta edição OSS até provisionamento explícito. O acesso remoto via ID/relay não deve depender dessa API, mas deverá ser confirmado em homologação.
**Retorno futuro:** qualquer endpoint corporativo deverá ser incorporado somente por release controlada pela DRGinfo; não aceitar configuração via usuário ou CLI.
**Status:** código-fonte alterado (`7bda3fed5b23`, `750f11a12b3`), ainda sem compilação ou testes de regressão; build #10 preservada.
