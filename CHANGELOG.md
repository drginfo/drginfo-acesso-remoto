# CHANGELOG — DRGinfo Acesso Remoto

## 2026-11-26 — Reconciliação de marca, configuração e documentação Windows
- Comparação entre `fix/drginfo-windows-startup-diagnostics` e `feat/drginfo-embedded-config` revelou perda dos scripts e documentos Windows, marca, logo e configuração embarcada na branch de diagnóstico.
- Restaurados arquivos históricos em seus caminhos originais; preservadas correções de atualização em `src/common.rs` e `src/updater.rs`.
- Restaurada configuração de servidor/relay/chave pública no Windows; metadados de recursos e geração de ícones corporativos no workflow.
- Acrescentado gate estático de identidade antes da etapa de compilação e documentação de decisão, segurança, inventário, operação e homologação.
- **Não homologado**: compilação final, ACLs, serviço, assinatura, configuração fim a fim e UI.
- Nenhuma build Linux/Android autorizada.

## 2026-11-26 — Correção de logo e ícone Flutter Windows
- Corrigido o componente `loadLogo()` que ainda exibia assets RustDesk, para preferir o logotipo oficial no Windows customizado.
- Corrigido `loadIcon()` para usar ícone DRGinfo derivado do logotipo aprovado; adicionada geração do asset no build.
- Gate do workflow falha se estiver ausente o ícone gerado ou referência aos assets DRGinfo.
- Sem mudanças em servidor, chave, ACLs, instalador homologado e builds Linux/Android.

## Auditoria local de sessões (Fase 1, Windows, não homologada)

- Adicionado registro local JSONL por sessão (`src/server/session_audit.rs`), com eventos `aceita`, `encerrada` e `recusada` e modos `assistido`, `nao_assistido`, `troca_lado` e `indeterminado`.
- Adicionadas primitivas em `src/platform/windows/acl.rs`: diretório com DACL protegida, mutex nomeado com timeout e substituição atômica de arquivo.
- Retenção de 90 dias pelo timestamp de cada evento, com purga na inicialização e a cada hora no processo servidor.
- Nenhuma alteração em autenticação, autorização, rendezvous ou permissões de controle remoto.
- Pendente: compilação Windows x64 e homologação conforme `docs/TESTES.md`.
