# Segurança — DRGinfo Acesso Remoto Windows

## Política e evidência
- Nunca incluir senha, token, chave privada SSH ou seed de assinatura no código, artefato ou log. A chave do servidor de rendezvous é pública.
- O script `install/windows/Auditar-Seguranca-DRGinfo.ps1` é **somente leitura** e coleta ACLs de `Program Files/DRGinfo Acesso Remoto`, `ProgramData/DRGinfo/AcessoRemoto`, serviço, assinatura e hash. A presença do script não significa que ACLs estejam corretas.
- Requerer acesso restrito à escrita em diretório do programa e scripts executados em contexto elevado. Revisar especificamente Users, Authenticated Users e Everyone, herança, contas do serviço e reparse points antes da distribuição.
- Observar UAC, princípio do menor privilégio, execução de código assinado quando disponível e integridade SHA-256.
- Preservar hash da versão homologada e rollback antes de qualquer instalação ou alteração de serviço.
- O workflow restaura o pacote oficial corporativo e bloqueia erros estáticos previsíveis *antes* do build caro; isso **não substitui** auditoria Windows de ACL.
- Não divulgar relatórios com nomes pessoais, tokens, credenciais, IPs internos sensíveis ou dados de clientes (LGPD).

## Bloqueios de aprovação
Não liberar se faltar marca, configuração embarcada ou proteção contra atualizações. Sem homologação: ACL, serviço, UAC, assinatura, instalação/desinstalação e teste fim a fim permanecem pendentes.
