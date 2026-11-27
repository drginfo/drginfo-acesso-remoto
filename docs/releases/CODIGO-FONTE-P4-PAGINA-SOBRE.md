# DRGinfo Acesso Remoto P4 — Página Sobre e acesso ao código-fonte

**Data:** 27/11/2026
**Status:** documentação de entrega preparada e homologação Windows concluída; correlação de binário e código-fonte comprovada; o operador confirmou publicação e enviou captura do trecho de licença com link correto; a auditoria do conteúdo integral não foi realizada.
**Versão:** `1.5.3-drginfo.p4`.
**Licença:** GNU AGPL-3.0 com preservação dos avisos RustDesk OSS.

## Texto para publicação no site

O DRGinfo Acesso Remoto é uma personalização do projeto de software livre RustDesk OSS, licenciado sob a GNU Affero General Public License versão 3 (AGPL-3.0). O código-fonte do fork DRGinfo está disponível em https://github.com/drginfo/drginfo-acesso-remoto/tree/5bbef89a64c707a67a8ff4b5de9c228eb732dc79 e a licença integral em https://github.com/drginfo/drginfo-acesso-remoto/blob/5bbef89a64c707a67a8ff4b5de9c228eb732dc79/LICENCE .

Versão Windows atual: 1.5.3-drginfo.p4. Pacote de aplicação Windows x64 com SHA-256 `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a`. Esta versão ainda **não tem assinatura digital Authenticode**. O Windows pode apresentar alertas de segurança; a DRGinfo não recomenda desativar mecanismos de proteção.

A revisão exata do código-fonte correspondente ao executável foi identificada no commit `5bbef89a64c707a67a8ff4b5de9c228eb732dc79`, pela execução GitHub Actions https://github.com/drginfo/drginfo-acesso-remoto/actions/runs/45929565631 e SHA-256 idêntico ao ZIP homologado. Submódulo `libs/hbb_common`: `450cc1d7b729cfa8d19b5a7527c9cc2fe54cf5eb`. Consulte `docs/releases/P4-RASTREABILIDADE-BINARIO.md` para a evidência detalhada.

O aplicativo destina-se a suporte remoto autorizado. A instalação e utilização devem observar o contrato de suporte, a política de privacidade aplicável e os direitos dos titulares de dados.

## Controle de revisão e disponibilização

- **NÃO** apontar a build #18 `fdd7525551d8f06a76ffe65241f7ebbfa26596e3` como código correspondente à P4.
- A referência imutável da revisão de build foi encontrada; preservar e disponibilizar o Corresponding Source completo, incluindo scripts e dependências exigíveis pela AGPL.
- A página Sobre e a política de privacidade foram declaradas publicadas pelo operador; captura do trecho Sobre comprova o link correto. Conteúdo jurídico integral da política e arquivo HTML local ainda requerem conferência.
- Realizar backup da página e preservar blocos/CSS da versão existente antes de aplicar.
- Conferir avisos legais na interface e atribuição original RustDesk.
- Leia também `P4-CONFORMIDADE-LICENCA-PRIVACIDADE.md` e `P4-PACOTE-ENTREGA-E-OPERACAO.md`.

## Homologação concluída (2026-11-27)

GUI online, GUI offline sem rede, portabilidade, serviço automático, branding, desinstalação e conectividade fim a fim foram aprovados. Pendências de distribuição legal e assinatura constam nos documentos acima; não repetir os testes funcionais sem alteração da build.

## Notebook

O notebook foi sincronizado até `80426ecb71b3df82f6f859272cf93c9f7448c14e` conforme saída apresentada; novos commits documentais exigem nova atualização `git pull --ff-only` em árvore limpa. Sincronizar também o HTML local efetivamente usado na publicação se estiver sob controle de versão.
