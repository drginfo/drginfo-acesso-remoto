# DRGinfo Acesso Remoto P4 — Página Sobre e acesso ao código-fonte

**Data:** 27/11/2026
**Status:** documentação de entrega preparada e homologação Windows concluída; publicação autenticada no site e correlação exata do binário ainda precisam comprovação.
**Versão:** `1.5.3-drginfo.p4`.
**Licença:** GNU AGPL-3.0 com preservação dos avisos RustDesk OSS.

## Texto para publicação no site

O DRGinfo Acesso Remoto é uma personalização do projeto de software livre RustDesk OSS, licenciado sob a GNU Affero General Public License versão 3 (AGPL-3.0). O código-fonte do fork DRGinfo está disponível em https://github.com/drginfo/drginfo-acesso-remoto e a licença integral em https://github.com/drginfo/drginfo-acesso-remoto/blob/release/drginfo-windows-p4-links-docs/LICENCE .

Versão Windows atual: 1.5.3-drginfo.p4. Pacote de aplicação Windows x64 com SHA-256 `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a`. Esta versão ainda **não tem assinatura digital Authenticode**. O Windows pode apresentar alertas de segurança; a DRGinfo não recomenda desativar mecanismos de proteção.

A vinculação pública à revisão exata do código correspondente ao executável será acrescentada após recuperação da execução de compilação original. Consulte `docs/releases/P4-RASTREABILIDADE-BINARIO.md` para o estado dessa verificação.

O aplicativo destina-se a suporte remoto autorizado. A instalação e utilização devem observar o contrato de suporte, a política de privacidade aplicável e os direitos dos titulares de dados.

## Controle de revisão e disponibilização

- **NÃO** apontar a build #18 `fdd7525551d8f06a76ffe65241f7ebbfa26596e3` como código correspondente à P4.
- O endereço geral do repositório **não substitui** o código-fonte correspondente ao binário exato, exigido nos casos aplicáveis pela AGPL.
- Não afirmar que a página está publicada ou que a política de privacidade está disponível em WordPress antes de conferência autenticada.
- Realizar backup da página e preservar blocos/CSS da versão existente antes de aplicar.
- Conferir avisos legais na interface e atribuição original RustDesk.
- Leia também `P4-CONFORMIDADE-LICENCA-PRIVACIDADE.md` e `P4-PACOTE-ENTREGA-E-OPERACAO.md`.

## Homologação concluída (2026-11-27)

GUI online, GUI offline sem rede, portabilidade, serviço automático, branding, desinstalação e conectividade fim a fim foram aprovados. Pendências de distribuição legal e assinatura constam nos documentos acima; não repetir os testes funcionais sem alteração da build.

## Notebook

Após estas alterações documentais, sincronizar a branch com `git fetch` seguido de `git pull --ff-only` apenas em árvore limpa. A sincronização registrada anteriormente, no commit `694de34582b6cfcbd57dd83dc13f3bb1b639fec1`, **não inclui** os commits documentais posteriores.
