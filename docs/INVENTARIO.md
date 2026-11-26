# Inventário técnico — reconciliação Windows

## Fontes de referência
- Branch Windows: `fix/drginfo-windows-startup-diagnostics`, proteção commit `8a00dd145`, empacotamento commit `a604dc104`.
- Origem dos arquivos comerciais recuperados: `feat/drginfo-embedded-config`; Git conserva SHA dos blobs.
- Entradas de aplicação: `src/core_main.rs`, `src/common.rs`, `flutter/windows/runner/Runner.rc`.
- Marca: `flutter/assets/drginfo-logo.png`, `tools/generate_drginfo_icons.py`, ícones em `res/` e `flutter/windows/runner/resources/`.
- Pacote e scripts: `install/windows/`; publicadores VPS: `install/linux/` (não são builds Linux).
- CI: `.github/workflows/drginfo-diagnostico-windows-x64.yml` (Windows x64).
- Documentos históricos: `docs/CHANGELOG-COMERCIAL.md`, `docs/DRGINFO-WINDOWS-WHITELABEL.md`, manuais GUI/usuário e `install/windows/README.md`.

## Política
Todos os binários e scripts devem registrar versão, commit, SHA256, ambiente, aprovação, limitações e rollback. Não incluir backups pessoais ou secretos.
