# DRGinfo Acesso Remoto Windows P4 — Proveniência do binário

Data: 2026-11-27. Status: **homologação funcional concluída; vínculo imutável entre ZIP e revisão do compilador NÃO comprovado**.

## Identificação imutável comprovada
- Produto: DRGinfo Acesso Remoto 1.5.3-drginfo.p4, Windows x64.
- ZIP distribuído: `DRGinfo-Acesso-Remoto-Windows-x64.zip`; na VPS, objeto publicado sob o nome `DRGinfo-AcessoRemoto-windows-x64.zip`.
- SHA-256 do conteúdo ZIP aprovado e baixado da VPS na VM: `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a`.
- URL do ZIP da VPS: https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/1.5.3-drginfo.p4/DRGinfo-AcessoRemoto-windows-x64.zip
- Branch de manutenção documental P4: `release/drginfo-windows-p4-links-docs`. **Não identificar o HEAD atual como commit do executável.**
- O commit `fdd7525551d8f06a76ffe65241f7ebbfa26596e3` pertence à build #18, **não à P4**.
- Submódulo no checkout do operador em 2026-11-27: `libs/hbb_common` em `450cc1d7b729cfa8d19b5a7527c9cc2fe54cf5eb`. Não supor que essa foi a versão exata utilizada no build do executável.

## Investigação realizada
- Workflow de build identificado: `.github/workflows/drginfo-diagnostico-windows-x64.yml` (acionamento manual `workflow_dispatch`, checkout de submódulos recursivo).
- Documentos de branch, scripts do instalador, logs de Windows e hash ZIP conferidos.
- O acesso disponível ao GitHub Actions neste ambiente **não apresentou lista de runs com head_sha e artefato ZIP correlacionado**. A pesquisa de commits não comprova a associação byte-a-byte.
- **Ainda requer evidência independente:** run_id, head_sha, job, nome e hash do artefato da execução, versão dos submódulos e dependências; correlacionar o ZIP baixado ao build, considerando renomeações/reempacotamentos.

## Procedimento seguro de identificação (sem recompilar)
1. Na interface GitHub, abrir Actions > `DRGinfo - Diagnostico Windows x64` > execução que gerou o ZIP P4.
2. Registrar URL da execução, Run ID, Commit (head_sha), nome do artefato, conclusão e logs da etapa de upload; se disponível, baixar o artefato original.
3. Calcular `Get-FileHash -Algorithm SHA256` no **ZIP original da compilação**, comparando ao SHA de release. Se houve reempacotamento, comparar arquivos internos e guardar manifesto de hashes e cadeia de transformação.
4. Consultar `git ls-tree <head_sha> libs/hbb_common` e as versões/lockfiles no commit original.
5. Criar tag imutável `drginfo-windows-v1.5.3-p4-source` **apenas depois** de comprovada a correspondência; publicar URL do commit/tag na página Sobre e nas instruções da release.

## Condição de liberação
O repositório geral disponível e a licença AGPL são evidências positivas, mas **não substituem o acesso ao Corresponding Source da versão exata**, inclusive scripts de build/instalação e dependências relevantes, conforme GNU AGPL-3.0. **Não afirmar conformidade plena nem fechar este requisito sem correlação verificável.**
