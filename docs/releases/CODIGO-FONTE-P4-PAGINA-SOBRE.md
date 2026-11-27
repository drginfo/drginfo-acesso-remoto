# DRGinfo Acesso Remoto P4 — Página Sobre e código-fonte

**Data:** 27/11/2026  
**Status:** texto de referência revisado e versionado; a alteração no WordPress de produção exige publicação autenticada e conferência do conteúdo atual.  
**Versão da aplicação:** `1.5.3-drginfo.p4`  
**Licença do projeto derivado:** GNU AGPL-3.0, respeitados os avisos e direitos do projeto RustDesk original.

## Texto aprovado para a seção de código-fonte da página Sobre

> O DRGinfo Acesso Remoto é uma versão personalizada baseada no RustDesk OSS, distribuído sob a licença GNU AGPL-3.0. O código do projeto DRGinfo está disponível no [repositório público](https://github.com/drginfo/drginfo-acesso-remoto). A identificação imutável da revisão de código-fonte correspondente ao executável da versão P4 será acrescentada após a conferência do registro de compilação e dos artefatos. Os avisos de direitos autorais e a licença original são preservados.

**Não indicar** o commit `fdd7525551d8f06a76ffe65241f7ebbfa26596e3` como fonte correspondente à P4: refere-se à build #18.

O link geral ao repositório **não demonstra, por si só,** que o código-fonte correspondente à versão distribuída está disponibilizado conforme os requisitos da AGPL-3.0. Antes de distribuição definitiva, verificar o commit exato do ZIP compilado, dependências e submódulos aplicáveis, bem como a forma de acesso ao código-fonte correspondente.

## Identificação da compilação — não adivinhar

**ZIP P4 homologado:** `DRGinfo-Acesso-Remoto-Windows-x64.zip`  
**SHA-256 do ZIP:** `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a`.

Investigar a execução do GitHub Actions que gerou exatamente esse ZIP e registrar `run_id`, `head_sha`, nome do artefato, dependências e submódulos. **Não** usar automaticamente o head atual da branch P4 ou o `SourceCommit` do pacote de instalador: ambos podem ser posteriores ou diferentes do código compilado.

## Limites operacionais

- Windows: aplicação P4, serviço automático e reinicialização passaram nos testes informados.
- Portátil: abertura e sessão fim a fim aprovadas.
- GUIs online/offline: botões e reconhecimento de instalação existente aprovados.
- **Ainda não testados:** fluxo de instalação nova via botões GUI, assinatura Authenticode para distribuição comercial e demais requisitos de release.
- WordPress: preservar backup de página, blocos Elementor e CSS; publicar somente após revisão autenticada.

## Base de comparação Git

A consulta GitHub realizada em 27/11/2026 confirmou `master` → `release/drginfo-windows-p4-links-docs`: **94 à frente, 0 atrás**, 64 arquivos; o commit `51f94394ce61e1f3d26229565c326b2862cbdd1f` é ancestral comum. Não trocar por `92/1` sem evidência de outra comparação.

## Sincronização do notebook Debian

Após esta atualização documental estar no GitHub, executar o script versionado `tools/sincronizar-notebook-drginfo.sh` (somente com working tree limpa e origem validada) ou o procedimento assistido. Usar `git fetch` e `git pull --ff-only`; **não usar** `reset --hard`, `clean -fd` ou `push --force`.
