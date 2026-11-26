# DRGinfo Acesso Remoto — Manual do usuário (Windows 10/11 x64)
Versão documental: 1.0 — 25/11/2026
Produto comercial: DRGinfo Acesso Remoto
Fornecedor do suporte: DRGinfo Consultoria & Suporte

## 1. Finalidade
Acesso remoto assistido e suporte técnico autorizado. O usuário deve permitir conexões
somente de profissionais identificados e previamente autorizados.

## 2. Requisitos
Windows 10/11 x64, conexão à Internet, conta Windows capaz de autorizar UAC
para instalar. A ferramenta utiliza infraestrutura da DRGinfo.
Não é necessário desativar antivírus, SmartScreen ou firewall.

## 3. Instalação
1. Obtenha o instalador diretamente da DRGinfo, em canal confiável.
2. Confira a origem e, se informado, o SHA-256 do pacote.
3. Extraia o ZIP e execute instalador-drginfo.cmd.
4. Confira o nome DRGinfo Acesso Remoto e clique em Instalar DRGinfo.
5. Autorize a solicitação do Windows (UAC) com credenciais administrativas.
6. Aguarde a confirmação de instalação e início do serviço.
7. Confirme a presença de DRGinfo Acesso Remoto em
   Configurações > Aplicativos > Aplicativos instalados.
8. Abra o programa. O indicador verde Pronto indica conexão ao servidor
   de identificação, mas não garante por si só uma sessão remota válida.

## 4. Compartilhamento do acesso
Informe ao técnico autorizado somente o ID exibido no aplicativo.
Forneça senhas temporárias exclusivamente durante atendimento legítimo,
por um canal confiável e preferencialmente após validar a identidade do técnico.
Não divulgue credenciais de domínio, senhas permanentes, chaves privadas ou
dados pessoais em capturas de tela. A conexão pode depender de confirmação
no computador assistido.

## 5. Conexão e falhas
Verde/Pronto: comunicação inicial disponível. Vermelho/Não está pronto:
verificar conectividade, data/hora do sistema e informações de rede.
Não altere o servidor de ID/Relay ou a chave sem orientação da DRGinfo.
Não execute dois serviços DRGinfo de versões distintas simultaneamente.
Para diagnóstico, use ferramenta de auditoria autorizada; não compartilhe
logs brutos sem revisão de dados confidenciais.

## 6. Desinstalação
Configurações > Aplicativos > Aplicativos instalados > DRGinfo Acesso Remoto >
menu (...) > Desinstalar. Confirme na janela DRGinfo, autorize UAC.
O aplicativo e o serviço serão removidos. Logs técnicos e configurações
do perfil poderão ser preservados para auditoria e continuidade do suporte.
Para exclusão de dados pessoais, contate a DRGinfo conforme política contratual.

## 7. Privacidade e segurança
Utilize o programa somente com autorização do responsável pela estação.
Acesso remoto pode expor documentos pessoais e corporativos.
A DRGinfo deve informar contratos, finalidades, responsabilidades,
retenção de logs e atendimento às exigências de LGPD.

## 8. Créditos e licença
DRGinfo Acesso Remoto utiliza software livre derivado do RustDesk OSS,
licenciado sob GNU AGPL-3.0. A identificação comercial DRGinfo não altera
os direitos autorais originais. A licença e o código-fonte correspondente
devem estar disponíveis ao usuário, incluindo modificações e scripts de build.
Licença oficial: https://www.gnu.org/licenses/agpl-3.0.html
Projeto original: https://github.com/rustdesk/rustdesk
Projeto DRGinfo: https://github.com/drginfo/drginfo-acesso-remoto

## 9. Suporte
DRGinfo Consultoria & Suporte — https://drginfo.com.br
A versão do aplicativo pode ser consultada em Aplicativos instalados.
Para atendimento, informe o sistema operacional, a versão e o horário do erro,
sem transmitir senhas ou documentos confidenciais.
