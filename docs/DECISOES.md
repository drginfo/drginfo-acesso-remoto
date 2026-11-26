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
