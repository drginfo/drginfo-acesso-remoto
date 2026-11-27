## 2026-11-27 — GUI offline P4: aprovação funcional; cache não isolado
- Operador informou: interface, logotipos, links, instalação, acesso remoto fim a fim, ícones, aplicativos, Menu Iniciar e Adicionar/Remover Programas: **todos OK**.
- Log 13:37:41–13:37:45: ACLs verificadas; hash P4 SHA-256 `926FAA9759236E18D4F5791A4A3BE76F0C96973676904F6F5FE08D8AA50B533A` validado; serviço criado/iniciado; registro ARP e atalhos criados; instalação concluída.
- Log informa executável **não assinado**: liberação comercial assinada segue pendente.
- **Limitação de evidência:** linha `Validando software offline sem usar rede.` não aparece; o ZIP do teste online permanecia no cache de `ProgramData`, logo o motor pode ter reutilizado o ZIP e não aberto `PackageFile`. Não declarar instalação offline sem cache/rede comprovada.
- **Fecho de evidência:** executar um último ensaio com VM sem rede, aplicação desinstalada e cache de SHA isolado reversivelmente; verificar log `Validando software offline sem usar rede.`, hash e instalação completa.
- Estado: instalador gráfico offline **aprovado funcionalmente**; independência de cache/rede **não demonstrada**.

## 2026-11-27 — GUI online P4: download da VPS e SHA-256 conferidos
- Operador forneceu log da instalação nova: `2026-11-27 13:14:21 [INFO] Baixando release da VPS: /rustdesk/drginfo-acesso-remoto/1.5.3-drginfo.p4/DRGinfo-AcessoRemoto-windows-x64.zip`.
- `2026-11-27 13:14:38 [INFO] Pacote SHA256 validado: 926FAA9759236E18D4F5791A4A3BE76F0C96973676904F6F5FE08D8AA50B533A`.
- `2026-11-27 13:14:47 [INFO] INSTALACAO CONCLUIDA. Servico automatico em execucao.`.
- `Get-FileHash` no ZIP recuperado em `ProgramData/.../packages/<sha>/package.zip`: SHA-256 idêntico à referência P4.
- Conclusão: **fluxo online confirmado com download real e integridade**, juntamente aos testes funcionais e conexão fim a fim já informados pelo operador.
- **Pendente separado:** confirmação explícita do UAC e instalação nova pela GUI offline.

## 2026-11-27 — Instalação nova via GUI ONLINE P4: testes funcionais aprovados
- Antes da execução: aplicação P4 desinstalada pelo desinstalador oficial, serviço/pasta/ARP/atalho ausentes e logs preservados.
- Cache P4 `packages/926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a` renomeado reversivelmente para `.backup-preteste-online`, impedindo reaproveitamento direto do ZIP no caminho original.
- Operador confirmou: **interface, logotipos, links, instalação, conexão remota fim a fim, ícones/aplicativo, Menu Iniciar e Adicionar/Remover Programas = OK**.
- **Aprovado funcionalmente:** nova instalação pelo instalador gráfico online com aplicação ausente.
- **Evidências ainda a conferir:** linha de log do download da VPS, SHA após instalação e elevação UAC (não explicitamente relatada no retorno).
- **Próximo teste:** desinstalar e homologar instalação nova pela GUI offline, preservando logs e backups; não repetir testes de portable já aprovados.

## 2026-11-27 — Botão Fechar da GUI online P4 aprovado
- Operador confirmou **OK** após acionar o botão `Fechar` do instalador GUI online, com a P4 já instalada.
- Testes aprovados da GUI online nesse cenário: abertura e identidade DRGinfo, detecção de instalação existente, `Abrir aplicativo`, `Abrir log`, exibição de ID/Pronto/logotipos e `Fechar`.
- Escopo de homologação: **controles da GUI online com aplicação existente**, sem executar nova instalação.
- **Pendência principal:** ciclo de instalação nova pela interface gráfica online com download HTTPS/UAC/serviço e desinstalação posterior, em condição controlada. Preservar logs e usar snapshot existente antes de remover serviço funcional.
## 2026-11-27 — GUI ONLINE P4: interface e integração com instalação existente aprovadas
- Operador confirmou: **GUI=OK; detecção de instalação=OK; botão Abrir aplicação=OK; botão Abrir log=OK; Pronto=OK; ID=OK; Logos=OK**.
- Teste realizado com o pacote `DRGinfo-Instalador-Windows-x64.zip` da release `1.0.0-p4-online-lab1`, inicialmente informado com SHA-256 `0C55846BD82AC030FB51BC7A65478696385F9E281A66E2E2244F1E8C6A6CEDDB`.
- Resultado: **interface gráfica do pacote online aprovada no cenário de aplicativo já instalado**; integração com aplicativo, logs e apresentação corporativa verificadas.
- Pendentes: instalação nova via botão da GUI online (download real da VPS, UAC, criação de serviço e atalhos), validação da ação Fechar online e homologação comercial (assinatura).
- Não repetir testes funcionais P4 já concluídos sem necessidade.

## 2026-11-27 — Instalador gráfico ONLINE P4 gerado em laboratório
- Operador confirmou execução concluída de `install/windows/Gerar-Pacote-Instalador.ps1`, com código e logotipo obtidos da revisão fixada `440cbab70fe4e2e330d2f47c546a0bbe11f4741e`.
- `Version=1.0.0-p4-online-lab1`, `SoftwareVersion=1.5.3-drginfo.p4`, `UnsignedLab`.
- ZIP: `C:\ProgramData\DRGinfo\AcessoRemoto\releases\installer-gui\1.0.0-p4-online-lab1\DRGinfo-Instalador-Windows-x64.zip`.
- SHA-256 **informado pelo gerador**: `0C55846BD82AC030FB51BC7A65478696385F9E281A66E2E2244F1E8C6A6CEDDB`.
- Manifesto: `C:\ProgramData\DRGinfo\AcessoRemoto\releases\installer-gui\1.0.0-p4-online-lab1\manifesto-sha256.csv`.
- Status: **GERADO; verificacao independente do pacote e testes GUI online pendentes**. Não alterar a P4 atualmente instalada nem distribuir comercialmente sem homologação e assinatura.

## 2026-11-27 — Publicação HTTPS do ZIP de software P4 confirmada
- Transferência da versão homologada do notebook Debian para VPS por SSH/SCP concluída (100%, aproximadamente 34 MiB).
- Diretório real: `/srv/drginfo-downloads/rustdesk/drginfo-acesso-remoto/1.5.3-drginfo.p4/DRGinfo-AcessoRemoto-windows-x64.zip`.
- SHA-256 calculado na VPS: `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a`, idêntico ao pacote homologado.
- Caddy existente: site `downloads.drginfo.com.br`, `root * /srv/drginfo-downloads`, `file_server`; nenhuma alteração/reload exigidos.
- Consulta HTTP HEAD relatada pelo operador: **HTTP/2 200**, `content-type: application/zip`, `content-length: 35565328`, `accept-ranges: bytes`, HSTS e `X-Content-Type-Options: nosniff`.
- URL: `https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/1.5.3-drginfo.p4/DRGinfo-AcessoRemoto-windows-x64.zip`.
- Resultado: **publicação e disponibilidade HTTPS aprovadas**. Geração e teste da GUI online continuam pendentes.

## 2026-11-27 — Serviço instalado restaurado após teste do portátil
- Após encerramento do uso do pacote portátil, o operador confirmou a saída de `Get-CimInstance Win32_Service` para `DRGinfo Acesso Remoto`:
  - `State=Running`
  - `StartMode=Auto`
  - `StartName=LocalSystem`
- Resultado: serviço principal restaurado com sucesso após os testes fim a fim do ZIP portátil, sem reinstalação ou recompilação.
- Pendências: pacote gráfico online, ensaio de instalação nova pela GUI offline e critérios comerciais (assinatura digital).

## 2026-11-27 — Conexão remota fim a fim do pacote portátil P4 APROVADA
- Operador confirmou **OK** após conexão de outro computador ao ID exibido pelo portátil extraído de `DRGinfo-Portatil-Windows-x64.zip`, com visualização e controle da área de trabalho e encerramento normal da conexão conforme teste solicitado.
- Serviço instalado permanecia em estado `Stopped` para evitar duas instâncias simultâneas.
- Resultado: **pacote portátil P4 homologado funcionalmente** em abertura, ID, estado Pronto, identidade visual e conexão remota fim a fim.
- Restauração do serviço instalado após encerrar o portátil: **pendente de confirmação do operador**.
- Não confundir com verificação de ausência de artefatos no perfil Windows; o software pode criar logs/configurações durante execução portátil.

## 2026-11-27 — Pacote portátil de distribuição P4: abertura e prontidão aprovadas
- Serviço instalado `DRGinfo Acesso Remoto` interrompido para evitar instâncias simultâneas; estado reportado: `Stopped`, inicialização `Automatic`.
- Operador extraiu `DRGinfo-Portatil-Windows-x64.zip` em `C:\DRGinfo-P4-Teste\Portatil-Teste` e abriu `Abrir-DRGinfo-Portatil.cmd` na console da VM.
- Operador respondeu **OK** às verificações de abertura da interface, identidade visual/logotipo, ID e estado `Pronto`.
- **APROVADO:** inicialização local e prontidão do pacote portátil de distribuição P4.
- **PENDENTE:** teste de conexão remota fim a fim deste ZIP portátil empacotado; verificação de encerramento e restauração do serviço instalado.
- Não confundir com teste portátil inicial do ZIP original já homologado anteriormente.

## 2026-11-27 — Botão Fechar da GUI offline aprovado
- Operador confirmou **OK** após usar `Fechar` na interface gráfica offline, tendo sido solicitado que verificasse o encerramento da janela sem interferência na instalação funcional existente.
- Controles da GUI offline com P4 instalada: identidade visual, detecção do serviço, abrir aplicativo, abrir log e fechar **aprovados** pelo operador.
- **Ainda pendente:** teste de instalação nova via botão GUI e solicitação UAC em VM sem aplicativo instalado; homologação funcional do ZIP portátil empacotado e instalador online.

## 2026-11-27 — Botão Abrir log na GUI offline aprovado
- Operador confirmou **OK** após acionar `Abrir log` no instalador gráfico offline P4.
- Resultado: visualização do log de instalação pelo botão da interface funcionou conforme esperado.
- Escopo: validação da ação de abrir log; sem reinstalação, UAC ou alteração do serviço.

## 2026-11-27 — Botão Abrir aplicativo na GUI offline aprovado
- Operador confirmou **OK** após acionar `Abrir aplicativo` no instalador GUI offline com P4 já instalada.
- Resultado: aplicativo principal iniciado corretamente a partir da interface do instalador.
- Escopo: validação da ação de abrir a aplicação existente; não abrange execução de nova instalação, UAC ou desinstalação.

## 2026-11-27 — Interface gráfica do instalador OFFLINE aprovada visualmente
- Evidência: captura de tela enviada pelo operador, GUI aberta na VM com P4 previamente instalada; teste realizado a partir de PowerShell de usuário comum conforme orientação operacional (confirmação independente do nível de privilégio/UAC ainda não registrada).
- Identidade corporativa DRGinfo (logotipo, cabeçalho ACESSO REMOTO e layout), indicação de `v1.5.3-drginfo.p4` e texto de modo offline aparecem corretamente.
- Estado apresentado: `Instalacao detectada | Servico DRGinfo: em execucao.`; botão `Ja instalado` indisponível para disparar instalação; opções `Abrir aplicativo`, `Abrir log` e `Fechar` visíveis.
- Resultado: **GUI offline — aparência e reconhecimento de instalação existente aprovados**.
- Limite: não houve clique em instalar nem teste de elevação UAC, instalação GUI em VM limpa ou ciclo de desinstalação da P4. Não declarar essas etapas homologadas.

## 2026-11-27 — Auditoria estrutural dos pacotes offline e portátil APROVADA
- Ambiente: PowerShell Windows 5.1 na VM de homologação; saída recebida do operador em **2026-11-27 08:37:59**.
- Auditor: `tools/Auditar-Pacotes-P4.ps1` corrigido no commit `4433251b05b22932266e8408ba276b8d2f4951b9`.
- **SHA-256 offline conferido:** `A64327D732CA7C81736242CB995BD26626DBF23A8B059D5DFDF8ED910F35E49B`.
- **SHA-256 portátil conferido:** `46DEDF2D9497E940D2A35FFB81A142EAA6CAACFC57361500AB5505BBD1CFFC2D`.
- **Manifesto offline:** 8/8 arquivos. Interface GUI, motor, logotipo e ZIP original P4 confirmados.
- **Manifesto portátil:** 111/111 arquivos. Executável, DLLs, dados e arquivo LICENCE confirmados.
- Resultado registrado: `RESULTADO=APROVADO_ESTRUTURALMENTE; HOMOLOGACAO_GUI_PENDENTE`.
- Relatório local: `C:\DRGinfo-P4-Teste\DRGinfo-Pacotes-1.0.0-p4-lab1\AUDITORIA-PACOTES-DRGinfo-P4.txt`.
- **Importante:** aprovacao estrutural nao constitui homologação funcional dos instaladores GUI, nem assinatura do executável.
- Incidentes corrigidos no auditor: falso positivo para separador de path Windows e parâmetro `Select-Object -CaseSensitive` não suportado em Windows PowerShell 5.1; nenhum artefato P4 precisou ser recompilado.

## 2026-11-27 — Geração dos dois pacotes P4 em VM (evidência informada pelo operador)
- Gerador `install/windows/Gerar-Pacotes-Offline-Portatil.ps1` executado em modo de laboratório, sem recompilação e sem substituir o serviço P4 instalado.
- Artefato de referência: `DRGinfo-Acesso-Remoto-Windows-x64.zip`, SHA-256 `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a`.
- Instalador offline: `C:\DRGinfo-P4-Teste\DRGinfo-Pacotes-1.0.0-p4-lab1\DRGinfo-Instalador-Offline-Windows-x64.zip`, SHA-256 **informado pelo gerador** `A64327D732CA7C81736242CB995BD26626DBF23A8B059D5DFDF8ED910F35E49B`.
- Portátil: `C:\DRGinfo-P4-Teste\DRGinfo-Pacotes-1.0.0-p4-lab1\DRGinfo-Portatil-Windows-x64.zip`, SHA-256 **informado pelo gerador** `46DEDF2D9497E940D2A35FFB81A142EAA6CAACFC57361500AB5505BBD1CFFC2D`.
- Manifesto do gerador: `C:\DRGinfo-P4-Teste\DRGinfo-Pacotes-1.0.0-p4-lab1\release.txt`.
- **Estado:** geração concluída; verificação independente dos pacotes e testes GUI ainda pendentes.
- `SourceCommit` do manifesto do pacote identifica o commit `30f4da7f3a48e7a062db20469a83fe102e7758bc` usado para obter scripts/logo do empacotador. **Não confundir com comprovação do commit de compilação do executável**, que exige verificação separada do run GitHub Actions.
- Auditor de pacotes de laboratório versionado em `tools/Auditar-Pacotes-P4.ps1`: valida SHA externo, cobertura do manifesto interno e ZIP de software embarcado sem executar o aplicativo.

## 2026-11-27 — Verificação final do serviço Windows P4 (confirmada pelo operador)
- Consulta `Get-CimInstance Win32_Service` para `DRGinfo Acesso Remoto`: **State=Running; StartMode=Auto; StartName=LocalSystem**.
- PathName: `"C:\Program Files\DRGinfo Acesso Remoto\DRGinfo Acesso Remoto.exe" --service`.
- Atalho Menu Iniciar e entrada Adicionar/Remover Programas confirmados visualmente pelo operador.
- Homologação funcional da instalação técnica + serviço + reboot + acesso fim a fim: **APROVADA na VM**.
- Pendências separadas: gerar e testar pacotes GUI online/offline/portátil, assinatura Authenticode comercial, desinstalação de P4/rollback e revisão dos requisitos de segurança.

## 2026-11-27 — Homologação de instalação P4 com persistência (evidência informada pelo operador)
- Ambiente: VM Windows 11 após desinstalação controlada da build #18; serviço anterior, executável, registro e atalhos removidos; logs, manifesto e cache em ProgramData preservados.
- Artefato P4: `DRGinfo-Acesso-Remoto-Windows-x64.zip`, SHA-256 `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a`. Auditoria interna: 108 de 108 hashes válidos e nenhum arquivo fora do manifesto.
- Motor de instalação: `install/windows/Instalar-DRGinfo-AcessoRemoto.ps1` obtido do commit `5bbef89a64c707a67a8ff4b5de9c228eb732dc79`; procedimento `-PackageFile`, `-PackageSha256`, `-PackageVersion 1.5.3-drginfo.p4`, `-AllowUnsigned`.
- `-ValidateOnly`: APROVADO com ACL gerenciada, verificação SHA-256 e cache permanente; nenhuma instalação/criação de serviço nessa pré-validação.
- **APROVADO PELO OPERADOR NA INSTALAÇÃO:** instalação concluída, ID, estado Pronto, links DRGinfo, logotipos e acesso remoto fim a fim.
- **APROVADO PELO OPERADOR APÓS REINICIALIZAÇÃO:** ID, estado Pronto, links DRGinfo, logotipos e acesso remoto fim a fim.
- **Ainda sem comprovação nesta rodada:** estado explícito `Running/Automatic` via consulta de serviço após reboot, teste do instalador gráfico online, empacotamento offline/portátil final, desinstalação da P4, assinatura Authenticode e testes de regressão adversariais.
- **Escopo:** homologação funcional da instalação técnica e do uso remoto nesta VM; não confundir com aprovação de distribuição comercial ou assinatura.
- Não executar outra compilação para gerar as modalidades: reutilizar os mesmos bytes do ZIP após conferência SHA-256.

## 2026-11-27 — Homologação funcional P4 portátil (evidência informada pelo operador)
- Artefato `DRGinfo-Acesso-Remoto-Windows-x64.zip`; SHA-256 `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a`.
- Auditoria inicial ZIP: 109 entradas, integridade aprovada, componentes essenciais presentes; ausência de `rustdesk.exe` legado.
- Auditoria integral de manifesto: 108/108 hashes correspondentes, nenhum arquivo fora do manifesto, zero falhas.
- VM Windows de teste: serviço instalado da build #18 interrompido antes da execução P4 para minimizar conflito de duas instâncias.
- **APROVADO PELO OPERADOR:** execução portátil P4, logotipo DRGinfo, ID, estado Pronto, links Website/Privacidade corporativos e acesso remoto assistido fim a fim.
- **NÃO COMPROVADO/CONCLUÍDO NESTA EVIDÊNCIA:** restauração do serviço build #18, instalação automática e persistência pós-reboot P4, GUI online/offline, desinstalação, atualização, assinatura Authenticode, vinculação do artefato ao SHA exato do workflow GitHub Actions, distribuição comercial.
- A aprovação limita-se ao modo portátil e à conexão testada; manter a build #18 homologada e não substituir instalações existentes.

## 2026-11-27 — Correção dos três bloqueios de empacotamento (somente fonte)
- `install/windows/Gerar-Pacote-Instalador.ps1`: versão do instalador, versão do software, SHA-256, URL HTTPS e commit de origem são entradas obrigatórias; `-UnsignedLab` restrito ao canal laboratório; distribuição regular exige thumbprint Authenticode.
- `install/windows/Gerar-Pacotes-Offline-Portatil.ps1`: recebe explicitamente `-Version`, `-ExpectedHash`, `-InstallerVersion`, `-SourceCommit` e política de assinatura; remove os valores fixos da versão antiga.
- `install/windows/Interface-DRGinfo-AcessoRemoto.ps1`: valida `SourceCommit` (40 hex), `ReleaseChannel`, `UnsignedPilot` e certificado sem referência a versão antiga; distribuição em produção não usa modo unsigned.
- `tools/validar-p4-release.sh`: verifica os novos requisitos estáticos e recusa referências antigas nos três scripts.
- **Não foram executados Windows PowerShell 5.1, build Rust/Flutter, novo empacotamento, nem testes de GUI/UAC/reboot nesta alteração.** Integridade de pacote e assinatura continuam exigidas.
- O novo `SourceCommit` para empacotamento deve ser o SHA do commit final efetivamente aprovado, nunca a branch móvel; `SoftwareSha256` deve vir do ZIP efetivamente compilado e verificado.

# CHANGELOG — Preparação DRGinfo Windows P4 (26–27/11/2026)

## Não lançada / sem nova compilação
- Branch de desenvolvimento: `release/drginfo-windows-p4-links-docs`, base `fix/drginfo-windows-startup-diagnostics`.
- A tela **Sobre** passa a apontar para páginas DRGinfo de Website e Privacidade, restrita ao cliente personalizado; preserva links upstream na edição não corporativa.
- Na tela do instalador, link de privacidade passa ao domínio DRGinfo na edição personalizada.
- Guia de preços RustDesk não abre no cliente corporativo.
- Páginas públicas registradas: `https://drginfo.com.br/acesso-remoto/` (WordPress ID 924) e `https://drginfo.com.br/privacidade-acesso-remoto/` (ID 923), após correção CSS confirmada pelo operador.
- Documentação versionada: `docs/releases/DOCUMENTACAO-TECNICA-DRGINFO.md`, `MANUAL-USUARIO-DRGINFO.md`, `MANUAL-INSTALACAO-DRGINFO.md`, `CONTROLE-WORDPRESS-PAGINAS-DRGINFO.md`, `DRGINFO-P4-PLANO-RELEASE.md`.
- Script Debian de sincronização do notebook: `tools/sincronizar-notebook-drginfo.sh`.

## Evidência já homologada — build #18, NÃO alterada
- Revisão de compilação: `fdd7525551d8f06a76ffe65241f7ebbfa26596e3`.
- ZIP SHA-256: `F4D6944138477B2C0900DE8CCD99BFC561C48E1FE0564A66A4CB8E0FD31D2825`.
- Confirmação do operador: nome/logo, serviço Running/Automatic pós-reboot e conexão remota fim a fim.

## Bloqueadores para a próxima release
- Nova build **ainda não gerada**: nenhuma comprovação de binário com links novos.
- Geradores de instalador online/offline atuais são fixados em software `1.5.3-drginfo.2`; precisam revisão/versão e hashes da próxima release antes de executar.
- Ainda não existem, para a revisão P4, os três pacotes binários testados: online, offline, portátil.
- Requer teste estático Flutter, compilação manual, teste regressivo, segurança, documentação AGPL e hashes públicos.
- A fonte ainda **não foi sincronizada fisicamente no notebook**; execução do script pelo operador é necessária.

Este registro separa claramente **implementação do código**, **compilação**, **homologação** e **distribuição**.
