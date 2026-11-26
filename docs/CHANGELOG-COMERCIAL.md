## 2026-11-25 — Corrigido erro de empacotamento do build #4
- Workflow #4: https://github.com/drginfo/drginfo-acesso-remoto/actions/runs/45650025503
- Falha real: etapa 21 `DRGinfo - criar pacote Windows com nome corporativo`.
- `Get-FileHash` tentou ler `drginfo-windows-x64/manifesto-sha256.csv` enquanto `Export-Csv` o mantinha aberto para escrita. Erro Windows: arquivo usado por outro processo.
- A compilacao do binario principal foi concluida antes da falha; o artefato comercial nao foi publicado.
- Correcao: `install/windows/Preparar-Distribuicao-DRGinfo.ps1` exclui o proprio manifesto do inventario SHA-256.
- Commit do fix: `1e9cafeae5a3dc2576f5a3c85f9874a2433a9f72`.
- Novo build #5 acionado por commit `46a287a255106968b01614f5c6dd79b9801f0f06`:
  https://github.com/drginfo/drginfo-acesso-remoto/actions/runs/45696065760
- Status no momento do registro: queued. Nao confundir com sucesso/homologacao.
- Nenhuma release da VPS alterada por este fix.

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
