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
