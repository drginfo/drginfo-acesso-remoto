# Matriz de homologação Windows — DRGinfo

| Critério | Estado | Evidência requerida |
|---|---|---|
| Compilação da revisão reconciliada | PENDENTE | Actions + commit + artefato |
| Nome do artefato corporativo | CONFIGURADO | publicação do artefato correto |
| Nome e recursos internos do EXE | PENDENTE | propriedades Windows/ícone/UI |
| Logo oficial e ícones | PENDENTE | inspeção visual em VM |
| Servidor, relay e chave pública | PENDENTE | estado Pronto e conexão fim a fim |
| Atualização oficial bloqueada | PENDENTE | logs e comportamento controlado |
| ACL Program Files e ProgramData | PENDENTE | relatório Auditar-Seguranca-DRGinfo.ps1 |
| Serviço, UAC e desinstalação | PENDENTE | inspeção e rollback em VM |
| Authenticode | NÃO ASSINADO | assinatura válida ou risco explicitamente aprovado |
| Backup e rollback | PENDENTE | versão anterior preservada + procedimento |

Não confundir script disponível com execução ou homologação.

## Evidência visual 26/11/2026
- Windows: imagem do usuário mostrou estado `Pronto`, porém ausência de logotipo corporativo. Portanto, **identidade visual NÃO APROVADA** no build #9.
- Correção em `flutter/lib/common.dart` e gerador de assets; a existência do código não equivale à aprovação da nova build.
