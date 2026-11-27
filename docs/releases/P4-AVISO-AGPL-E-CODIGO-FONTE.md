# DRGinfo Acesso Remoto P4 — Aviso de software livre e acesso ao código-fonte

**Versão:** 1.5.3-drginfo.p4 | **Data:** 2026-11-27 | **Natureza:** texto de atribuição e guia de distribuição; não equivale a certificado jurídico de conformidade.

## Aviso para a página Sobre, pacote de entrega e documentação do cliente

> O **DRGinfo Acesso Remoto** é uma versão modificada do **RustDesk OSS**, projeto de software livre mantido por seus respectivos autores e colaboradores. O software derivado é disponibilizado sob a **GNU Affero General Public License versão 3 (AGPL-3.0)**, observadas as licenças aplicáveis aos componentes de terceiros.
>
> As modificações e a identidade visual DRGinfo não retiram do usuário os direitos previstos na AGPL-3.0, incluindo acesso ao código-fonte correspondente, estudo, modificação e redistribuição nos termos da licença. A remuneração cobrada pela DRGinfo refere-se aos serviços profissionais contratados, como suporte, implantação e manutenção, sem impor restrições adicionais aos direitos concedidos pela licença de software livre.
>
> **Código-fonte da compilação Windows P4:** https://github.com/drginfo/drginfo-acesso-remoto/tree/5bbef89a64c707a67a8ff4b5de9c228eb732dc79
>
> **Licença integral:** https://github.com/drginfo/drginfo-acesso-remoto/blob/5bbef89a64c707a67a8ff4b5de9c228eb732dc79/LICENCE
>
> **Projeto original:** https://github.com/rustdesk/rustdesk
>
> Este software não é uma edição oficial do RustDesk. RustDesk e demais marcas de terceiros pertencem a seus titulares. O aplicativo Windows P4 ainda **não possui assinatura digital Authenticode**; verifique a origem e o SHA-256 do pacote, sem desativar mecanismos de segurança do sistema.

## Rastreabilidade exata do aplicativo

- Commit da compilação: `5bbef89a64c707a67a8ff4b5de9c228eb732dc79`.
- Execução: https://github.com/drginfo/drginfo-acesso-remoto/actions/runs/45929565631
- Aplicativo Windows x64 SHA-256: `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a`.
- Submódulo do commit: `libs/hbb_common` em `450cc1d7b729cfa8d19b5a7527c9cc2fe54cf5eb`, remoto declarado em `.gitmodules`: https://github.com/rustdesk/hbb_common.
- Arquivos de lock na revisão: `Cargo.lock` e `flutter/pubspec.lock`. Consulte `P4-RASTREABILIDADE-BINARIO.md`.
- A pré-release `v1.5.3-drginfo.p4` foi criada **como rascunho privado de publicação**, com quatro ZIPs e `SHA256SUMS`; não anunciar como release pública até efetiva publicação.

## Corresponding Source — requisitos que não se resolvem apenas com o link Git

Ao distribuir código objeto ou operar versão modificada que permita interação remota, devem ser respeitadas as seções aplicáveis da AGPL-3.0, em particular 1, 4, 5, 6 e 13. O Corresponding Source pode abranger, conforme o caso, **todo o código necessário para gerar, instalar, executar e modificar o programa**, incluindo scripts de compilação/instalação, interfaces e componentes exigidos. Não abrange automaticamente bibliotecas de sistema e ferramentas gerais inalteradas, nas exceções definidas pela própria licença.

1. Manter o commit exato acima acessível, incluindo submódulos nas revisões fixadas; **um arquivo ZIP de código baixado do GitHub pode não incorporar o conteúdo dos submódulos**.
2. Disponibilizar instruções e scripts correspondentes à construção e instalação da P4. Verificar se tudo que foi usado na compilação, inclusive artefatos e modificações de terceiros, está publicado e não depende de material inacessível.
3. Preservar avisos de copyright e alterações, texto integral `LICENCE`, avisos legais na interface e atribuições/dependências sob licenças adicionais quando aplicáveis.
4. Oferecer acesso ao código-fonte correspondente sem cobrar por esse acesso quando a modalidade escolhida exigir a oferta gratuita, especialmente na interação de rede da seção 13.
5. Manter disponível a oferta de código por período e meios compatíveis com o regime efetivo de distribuição da seção 6; não presumir que um link de branch mutável satisfaça o requisito.
6. Não expor senhas, tokens, chaves privadas, IDs pessoais de clientes ou logs ao publicar código-fonte; **não omitir código sujeito à AGPL sob pretexto de segurança**. Se houver segredo incorporado à configuração, substituí-lo operacionalmente e revisar o material antes da distribuição.

### Verificação ainda não comprovada

Há evidência da revisão, hash, licença principal e gitlink. **Não foi realizada auditoria exaustiva de todas as dependências, recursos gráficos de terceiros, avisos de interface, scripts de construção e disponibilidade integral do Corresponding Source.** Não afirmar “100% em conformidade” até realizar essa verificação. A existência do repositório público é um componente importante, mas não substitui integralmente essa comprovação.

## Integridade dos pacotes no rascunho GitHub

| Pacote | SHA-256 |
|---|---|
| `DRGinfo-Acesso-Remoto-Windows-x64.zip` | `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a` |
| `DRGinfo-Instalador-Offline-Windows-x64.zip` | `a64327d732ca7c81736242cb995bd26626dbf23a8b059d5dfdf8ed910f35e49b` |
| `DRGinfo-Instalador-Windows-x64.zip` | `0c55846bd82ac030fb51bc7a65478696385f9e281a66e2e2244f1e8c6a6ceddb` |
| `DRGinfo-Portatil-Windows-x64.zip` | `46dedf2d9497e940d2a35ffb81a142eaa6caacfc57361500ab5505bbd1cffc2d` |

**Fontes:** https://www.gnu.org/licenses/agpl-3.0.html ; https://github.com/rustdesk/rustdesk/blob/master/LICENCE .
