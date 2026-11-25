# DRGinfo — Compilacao Windows x64 com marca completa

Data: 2026-11-25
Branch: feat/drginfo-embedded-config
Origem visual: logo quadrada DRGinfo aprovada em conversa.
Escopo: nova compilacao Rust + Flutter Windows x64; nenhum deploy automatico.
Versao prevista: 1.5.3-drginfo.2 (a ser atribuida apos validacao).
Pipeline: .github/workflows/drginfo-build-windows.yml

Criterios:
- Recursos ICO Windows, Flutter, bandeja, PNG e SVG gerados pela mesma fonte.
- Publicar somente GitHub Actions artifact para homologacao.
- Preservar versoes homologadas, instalavel gui2 e portable1.
- Nao informar build concluido ate o workflow e o pacote validarem.
- Manter avisos legais e oferta do codigo-fonte AGPL-3.0.

Build acionado por push deste arquivo nesta branch.

## Rebuild corporativo 2026-11-25
Gerar artifact DRGinfo-Acesso-Remoto-Windows-x64, exe renomeado, licença AGPL.

## Rebuild gui5 - correcao manifesto 2026-11-25
Correcao 1e9cafeae5a3dc2576f5a3c85f9874a2433a9f72: manifesto excluido da propria enumeracao SHA256. Build para artefato DRGinfo-Acesso-Remoto-Windows-x64, sem publicacao VPS.
