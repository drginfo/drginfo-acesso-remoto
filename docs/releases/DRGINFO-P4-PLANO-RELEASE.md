# DRGinfo Acesso Remoto — Plano de release e inventário de entrega
Data: 2026-11-26/27. Responsável pela aprovação: DRGinfo. Escopo: Windows 10/11 x64.
## Linha de base e controle de mudanças
- Repositório: https://github.com/drginfo/drginfo-acesso-remoto
- Base homologada: branch `fix/drginfo-windows-startup-diagnostics`, commit `fdd7525551d8f06a76ffe65241f7ebbfa26596e3`, artefato Windows x64 do workflow diagnóstico #18.
- SHA-256 do ZIP da build #18 confirmado pelo operador: `F4D6944138477B2C0900DE8CCD99BFC561C48E1FE0564A66A4CB8E0FD31D2825`.
- Branch de preparação: `release/drginfo-windows-p4-links-docs`; **NÃO** é release homologada.
- Evidência operacional da build #18: instalação PowerShell `-PackageFile` + `-AllowUnsigned`, serviço `Running/Automatic`, reinício e conexão fim a fim aprovados pelo operador.
- Documentação e código preparados nesta branch ainda exigem compilação e QA próprio; **não atribuir aprovação #18 aos novos binários**.
## Correções P4 — links de marca
- `flutter/lib/desktop/pages/desktop_setting_page.dart`: privacidade e website no domínio DRGinfo quando `bind.isCustomClient()`; demais clientes mantêm upstream.
- `flutter/lib/desktop/pages/install_page.dart`: link para privacidade DRGinfo quando customizado.
- `flutter/lib/desktop/pages/connection_page.dart`: guia de preços upstream não abre no cliente corporativo.
- Destinos: https://drginfo.com.br/acesso-remoto/ e https://drginfo.com.br/privacidade-acesso-remoto/.
- Preservados direitos autorais upstream e licença AGPL; não alterar aviso Purslane Tech como se a DRGinfo fosse detentora do copyright original.
## WordPress / identidade visual
- Site gerenciado na Hostinger; páginas WordPress `924` (/acesso-remoto/) e `923` (/privacidade-acesso-remoto/).
- HTMLs de origem entregues pelo operador: `sobre-drginfo-acesso-remoto.html` e `privacidade-drginfo-acesso-remoto.html` (arquivos externos ao Git nesta etapa).
- O CSS foi aplicado pelo operador em `Aparência > Personalizar > CSS adicional`. A primeira correção CSS restaura estilos dos documentos, e um seletor adicional oculta a imagem duplicada do Elementor apenas nos IDs 923/924; a confirmação visual foi informada pelo operador.
- **Para backup exato do CSS em produção**, exportar o CSS adicional do WP e versionar a cópia literal; não considerar os seletores documentados como extração certificada do estado atual.
- Contatos oficiais: sac@drginfo.com.br; privacidade@drginfo.com.br.
## Três modalidades — critérios
| Modalidade | Esperado | Condição atual |
|---|---|---|
| Online | GUI Windows DRGinfo, HTTPS corporativo, SHA independente, UAC, serviço Auto, desinstalador | PENDENTE: gerador/GUI fixam release legada, requer atualização de versionamento, endereço publicado, validação |
| Offline | ZIP íntegro com binário + motor/GUI + manifesto, sem download de aplicativo | PENDENTE: gerador offline fixado em `1.5.3-drginfo.2` e SHA antigo; NÃO USAR com próxima build |
| Portátil | ZIP completo (EXE + DLLs + data + LICENCE), executar sem instalação | Build #18 portátil testada; nova revisão requer compilação e teste |
## Bloqueios antes de distribuição comercial
1. Compilar somente revisão final aprovada, anotando SHA do código e ID do workflow; usar execução manual, evitando repetição de builds longos.
2. Atualizar **todos** os geradores/manifestos e guardas `UnsignedPilot` para versão/hash específicos da nova release; não retirar validação para “fazer funcionar”.
3. Pacotes online, offline e portátil gerados e hashes públicos **independentes** do canal do próprio arquivo.
4. Instalação, atualização, desinstalação, rollback, persistência e acesso remoto testados em VM com snapshot; o instalador GUI permanece distinto do motor homologado.
5. Testes adversariais de UI/CLI/IPC/configuração de servidor; ausência de chamadas a endpoints oficiais RustDesk na edição DRGinfo.
6. Validar licenciamento AGPL, fonte correspondente ao commit, NOTICE/LICENCE e inventário de componentes/SBOM; realizar revisão LGPD e termos.
7. Testar URLs e renderização em desktop e mobile, preservar snapshot do CSS e conteúdo das páginas.
8. Conferir políticas de segurança e aceite explícito de distribuição de código não assinado; não alegar assinatura digital.
## Inventário de produção
- Windows VM: `C:\Program Files\DRGinfo Acesso Remoto` e serviço `DRGinfo Acesso Remoto`.
- Cachê e logs de instalador: `C:\ProgramData\DRGinfo\AcessoRemoto`.
- Código: GitHub repo acima; notebook local só poderá ser sincronizado pelo operador executando `git` (não há acesso remoto do assistente ao sistema de arquivos do notebook).
- Release binaries: GitHub Actions artifacts, **não** incluídos como binários nesta branch.
## Matriz de aceite
| Requisito | Estado |
|---|---|
| Build #18 acesso remoto, reboot e serviço | APROVADO operador |
| URLs WordPress públicas | PUBLICADO e correção visual confirmada pelo operador |
| Fonte P4 links | IMPLEMENTADO nesta branch, SEM BUILD |
| Novos pacotes online/offline/portátil | NÃO GERADOS |
| Sincronização do notebook | NÃO EXECUTADA |
| Manual do usuário, instalação e engenharia | Documentação nesta branch; revisão técnica/QA pendentes |
