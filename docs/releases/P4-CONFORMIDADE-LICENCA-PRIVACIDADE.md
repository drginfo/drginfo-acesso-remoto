# DRGinfo Acesso Remoto P4 — Avisos legais e condições de oferta

Data: 2026-11-27. Documento técnico de conformidade, não parecer jurídico.

## Licença e atribuição
- Base de software: RustDesk OSS. Projeto original: https://github.com/rustdesk/rustdesk
- Fork da DRGinfo: https://github.com/drginfo/drginfo-acesso-remoto
- Licença preservada no repositório: arquivo `LICENCE`, GNU Affero General Public License v3.0.
- A marca comercial DRGinfo identifica esta personalização, **não transforma o código AGPL em software proprietário exclusivo nem elimina direitos de terceiros**.
- Clientes podem receber o software e o serviço de instalação/suporte mediante remuneração; as liberdades concedidas pela AGPL devem permanecer intactas. Não cobrar para exercer os direitos sobre o código-fonte que a licença exige disponibilizar.
- Preservar avisos de copyright, alteração da obra, texto integral da licença, eventuais avisos legais de interface, autorias e condições de dependências. Conferir marcas e materiais visuais de terceiros antes de divulgação.
- Fonte correspondente à **revisão EXATA** é pendência controlada em `P4-RASTREABILIDADE-BINARIO.md`. Repositório genérico não comprova, sozinho, obrigação satisfeita.

## Uso de rede e segurança
- A operação do acesso remoto depende de configuração e permissão legítima do titular/administrador da máquina. Disponibilizar o app exclusivamente para suporte autorizado.
- Antes do atendimento, informar claramente finalidade, responsáveis, escopo, necessidade de consentimento ou outra base legal adequada, política de acesso, procedimentos de revogação, retenção de registros e canal de suporte.
- Proteger chaves/segredos; **não colocar credenciais, senhas de uso único, IDs individuais ou logs pessoais em repositório público**.
- Aplicar autenticação robusta, controle de operadores, mínimo privilégio, trilha de auditoria e procedimento para incidentes, conforme obrigações legais e contratos.
- Publicação da página de política de privacidade em WordPress **ainda deve ser validada em produção**. Não afirmar publicação sem evidência.
- Lei 13.709/2018 (LGPD): https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm e https://www.gov.br/anpd/pt-br/assuntos/titular-de-dados .

## Distribuição sem assinatura
- A aplicação atual é **Win32 não assinada (Authenticode ausente)**. Isso não significa, por si só, que seja proibido distribuí-la diretamente; pode gerar alerta do SmartScreen/Smart App Control, bloqueios por políticas corporativas e riscos de confiança.
- O ZIP é fornecido por HTTPS e seu SHA-256 é fixado e validado no instalador. **Hash e TLS não substituem autenticação do editor por assinatura**.
- Não instruir cliente a desativar globalmente antivírus, SmartScreen ou políticas de segurança. Se bloqueado, avaliar caminho compatível com a política do cliente.
- Ser transparente no site/contrato: versão **não assinada digitalmente**, origem, SHA-256 publicado, modo de suporte, verificação e mecanismo de remoção.
- Certificado de assinatura será adquirido quando houver disponibilidade financeira. **Sem data prometida e sem afirmar assinatura existente**.
- Para distribuição via formatos específicos (p.ex. MSIX/Store) há regras próprias de assinatura; o pacote atual é instalador Win32, não MSIX.

## Escopo da responsabilidade
A ausência de certificado não é automaticamente motivo de ação judicial. Contudo, descumprimento da licença, uso indevido de marcas, violação de privacidade, instalação não autorizada ou falhas contratuais podem gerar reclamações, responsabilização ou sanções. Revisão por advogado antes de exposição comercial ampla é prudente.

## Fontes oficiais
- AGPL-3.0: https://www.gnu.org/licenses/agpl-3.0.html
- FAQ GNU: https://www.gnu.org/licenses/gpl-faq.html
- Microsoft: https://learn.microsoft.com/windows/apps/package-and-deploy/code-signing-options
- Microsoft SmartScreen: https://learn.microsoft.com/windows/apps/package-and-deploy/smartscreen-reputation
- ANPD: https://www.gov.br/anpd/pt-br/assuntos/titular-de-dados
