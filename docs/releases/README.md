# Índice — DRGinfo Acesso Remoto / Preparação de release Windows
Data: 2026-11-27. Branch: `release/drginfo-windows-p4-links-docs`.

| Entregável | Arquivo | Status |
|---|---|---|
| Documentação técnica | [DOCUMENTACAO-TECNICA-DRGINFO.md](DOCUMENTACAO-TECNICA-DRGINFO.md) | Fonte documentada; revisão/QA pendentes |
| Manual do usuário | [MANUAL-USUARIO-DRGINFO.md](MANUAL-USUARIO-DRGINFO.md) | Elaborado; revisão final pendente |
| Manual de instalação | [MANUAL-INSTALACAO-DRGINFO.md](MANUAL-INSTALACAO-DRGINFO.md) | Elaborado; GUI nova não homologada |
| Plano/controle de release | [DRGINFO-P4-PLANO-RELEASE.md](DRGINFO-P4-PLANO-RELEASE.md) | Bloqueios explícitos |
| Registro WordPress/CSS | [CONTROLE-WORDPRESS-PAGINAS-DRGINFO.md](CONTROLE-WORDPRESS-PAGINAS-DRGINFO.md) | Complemento de CSS; exportação integral do WordPress pendente |
| Changelog | [CHANGELOG-P4.md](CHANGELOG-P4.md) | Atualizado |
| Sincronização de notebook | [../../tools/sincronizar-notebook-drginfo.sh](../../tools/sincronizar-notebook-drginfo.sh) | Script publicado; execução no notebook pendente |
| Instalador online | `install/windows/Gerar-Pacote-Instalador.ps1` | Gerador legado fixado em versão antiga; atualizar após novo artefato |
| Instalador offline/portátil | `install/windows/Gerar-Pacotes-Offline-Portatil.ps1` | Gerador legado fixado em versão antiga; atualizar após novo artefato |
| Código completo | [Repositório DRGinfo](https://github.com/drginfo/drginfo-acesso-remoto) | Versionado na branch; sincronização física do notebook requer operador |

**Referência de homologação:** build #18, commit `fdd7525551d8f06a76ffe65241f7ebbfa26596e3`. Novos links não constam dessa build.
**Não confundir** documentação criada e código alterado com a geração/teste de nova versão.

## Pré-validação local sem compilação
Executar `bash tools/validar-p4-release.sh` da raiz do repositório. Saída esperada **nesta fase**: código P4 pré-validado e `RELEASE_NÃO_APTA` (exit 2), pois os três arquivos de instalação seguem fixados no pacote antigo. Esse bloqueio é intencional; não remover validação de SHA nem trocar um valor fixo por outro sem ter o artefato final. O script não compila, não altera arquivos e não publica binários.
