# CHANGELOG — DRGinfo Acesso Remoto (fluxo comercial)
## 2026-11-25 — gui5, pré-homologação
- Instalador gui5 usa release-config.psd1 gerado: URL HTTPS, SHA256 e versão obrigatórios.
- GUI não pode mais apontar implicitamente para ZIP 1.5.3-drginfo.1.
- Win32 ARP DisplayVersion reflete versão declarada da release instalada.
- Assinatura Authenticode verifica executável real (nome DRGinfo quando presente).
- Gerador de release Windows cria ZIP imutável e registra hash local.
- Script Linux publica em /srv/drginfo-downloads via SSH vpsdrg sem sobrescrever.
- Auditoria gui5 em PowerShell valida manifesto, sintaxe, URL e hash baixado.
- Documentação de usuário e engenharia criada em docs/.
- Estado: SEM homologação completa; publicação do novo ZIP, install/reboot/uninstall pendentes.

## 2026-11-25 — gui4, homologação parcial confirmada
- GUI baixou software de 1.5.3-drginfo.1 com HTTPS+SHA256.
- Serviço DRGinfo registrado e iniciado; interface mostrou Pronto.
- Windows Aplicativos instalados mostrou DRGinfo Acesso Remoto, fornecedor DRGinfo.
- Desinstalação pelo Windows removeu a entrada, capturada antes e depois.
- A imagem do EXE ainda era a versão anterior; não liberar como identidade final.
- A auditoria pré-instalação WIN11PROLAB ficou com serviços=0, processos=0, ARP=0.

## 2026-11-25 — Windows x64, marca corporativa
- Logo quadrada aprovada; troca de ícones do runner, Flutter e bandeja.
- Novo artifact DRGinfo-Acesso-Remoto-Windows-x64 com EXE comercial DRGinfo Acesso Remoto.exe.
- librustdesk.dll e demais identificadores internos mantidos por compatibilidade.
- LICENCE AGPL-3.0 e manifesto do pacote incluídos.
- Build visual abriu com indicador Pronto somente quando isolado do serviço antigo.

## Próximo marco
- Receber artifact novo, publicar ZIP imutável, gerar gui5 com hash novo,
  testar em VM e registrar evidências/novos hashes antes da distribuição pública.
