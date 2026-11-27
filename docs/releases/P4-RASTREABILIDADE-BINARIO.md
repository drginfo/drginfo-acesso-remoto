# DRGinfo Acesso Remoto Windows P4 — Proveniência do binário (VERIFICADA)

Data: 2026-11-27. **Status: commit da compilação, artefato e SHA-256 comprovados diretamente nos registros do GitHub Actions.**

## Cadeia de evidências verificadas
- Produto: `DRGinfo Acesso Remoto 1.5.3-drginfo.p4`, Windows x64.
- **Código-fonte imutável (commit build):** [`5bbef89a64c707a67a8ff4b5de9c228eb732dc79`](https://github.com/drginfo/drginfo-acesso-remoto/tree/5bbef89a64c707a67a8ff4b5de9c228eb732dc79).
- **Execução GitHub Actions:** [#45929565631](https://github.com/drginfo/drginfo-acesso-remoto/actions/runs/45929565631), concluída com sucesso, iniciada em `2026-11-27T02:38:56Z`.
- **Workflow:** `DRGinfo - Diagnostico Windows x64`; branch da execução `release/drginfo-windows-p4-links-docs`.
- **Job de build Windows x64:** `x86_64-pc-windows-msvc`, ID `140279629862`, sucesso.
- **Artefato oficial da execução:** `DRGinfo-Acesso-Remoto-Windows-x64`, ID `15169411324`, tamanho **35.565.328 bytes**, não expirado na conferência.
- **SHA-256 do artefato registrado pelo GitHub Actions:** `sha256:926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a`.
- **SHA-256 do ZIP instalado e homologado na VM:** `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a` — correspondência **exata**.
- **Submódulo comprovado na árvore imutável do commit do build:** `libs/hbb_common`, modo gitlink `160000`, SHA `450cc1d7b729cfa8d19b5a7527c9cc2fe54cf5eb`.
- **Lockfiles no commit:** `Cargo.lock` SHA blob `72edd2e10e5ac24ad90f252c4f2c055fa51841ca`; `flutter/pubspec.lock` SHA blob `4130a49b5f593f49aa4ab6f837f1e36947a30bd8`.
- **Licença na árvore do build:** `LICENCE` (AGPL-3.0) blob `0ad25db4bd1d86c452db3f9602ccdbe172438f52`.
- **ZIP publicado na VPS:** https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/1.5.3-drginfo.p4/DRGinfo-AcessoRemoto-windows-x64.zip, hash reproduzido na VM.
- **Execução anterior descartada:** [#45886911372](https://github.com/drginfo/drginfo-acesso-remoto/actions/runs/45886911372), commit `fdd7525551d8f06a76ffe65241f7ebbfa26596e3`, **build #18, não P4**.

## Links públicos para o código da versão exata
- Código-fonte: https://github.com/drginfo/drginfo-acesso-remoto/tree/5bbef89a64c707a67a8ff4b5de9c228eb732dc79
- Arquivo-fonte ZIP GitHub da revisão: https://github.com/drginfo/drginfo-acesso-remoto/archive/5bbef89a64c707a67a8ff4b5de9c228eb732dc79.zip
- Submódulo (referência): https://github.com/rustdesk/hbb_common/tree/450cc1d7b729cfa8d19b5a7527c9cc2fe54cf5eb (confirmar URL de origem em `.gitmodules` e acessibilidade antes de reproduzir)
- Histórico da compilação: https://github.com/drginfo/drginfo-acesso-remoto/actions/runs/45929565631
- Texto integral da licença: https://github.com/drginfo/drginfo-acesso-remoto/blob/5bbef89a64c707a67a8ff4b5de9c228eb732dc79/LICENCE

## Reprodutibilidade e AGPL
A associação `head_sha ↔ artefato GitHub ↔ SHA-256 do ZIP homologado` ficou **comprovada**. Isso identifica o código correspondente e a configuração versionada da build. Não é uma auditoria completa de reprodutibilidade determinística nem prova automática de cumprimento de todos os termos AGPL e licenças transitivas. Preservar código-fonte correspondente, scripts de construção e instalação, dependências e informações de licenças para destinatários da aplicação. Verificar se há avisos legais adequados nas interfaces e se `.gitmodules` aponta para código acessível; distribuir pacote de fontes com submódulos quando necessário.

## Política de mudança
Não substituir este commit pelo HEAD atual da branch, que avançou com documentação. Não confundir o commit de empacotamento dos instaladores GUI com a compilação do aplicativo. Nenhuma recompilação foi necessária ou iniciada nesta investigação.
