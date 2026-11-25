# DRGinfo Acesso Remoto — Engenharia, distribuição e homologação
Data: 25/11/2026 | Versão técnica: 1.0 | Status: PRÉ-HOMOLOGAÇÃO GUI5

## 1. Escopo / componentes
Repositório: https://github.com/drginfo/drginfo-acesso-remoto
Branch de integração: feat/drginfo-embedded-config
Aplicativo: RustDesk OSS 1.5.3, derivado e personalizado (Rust, Flutter, C++).
Infraestrutura de identidade e relay: drgvps.drginfo.com.br
Windows: Win10/11 x64; servidor ID/Relay com chave pública incorporada no código.
Componentes internos, DLLs, IPC, esquema de configuração e protocolo não
devem ser renomeados sem validação sistemática de dependências.

## 2. Identidade visual e pacote
Marca cliente: DRGinfo Acesso Remoto.
Nome do executável distribuído: DRGinfo Acesso Remoto.exe.
Ícones: branding/drginfo-square-icon.png.base64 gerados por
branding/tools/build-windows-brand-assets.py; runner ICO, Flutter ICO/PNG/SVG
e bandeja do sistema. Mascote reservado a materiais de ajuda.
Build CI: .github/workflows/drginfo-build-windows.yml, Windows x64.
Artifact: DRGinfo-Acesso-Remoto-Windows-x64.
Empacotador: install/windows/Preparar-Distribuicao-DRGinfo.ps1.
Inclui LICENCE, LEIA-ME-DRGinfo.txt e manifesto-sha256.csv.
Não alterar librustdesk.dll: dependência dinâmica esperada em runtime.

## 3. Distribuição controlada (gui5)
**Não assumir que a compilação do binário publicado corresponde ao novo ícone.**
A partir do artifact DRGinfo gerado no CI:
1. Baixar artifact novo e conferir nome EXE, versão, data, ícone, DLL e hashes.
2. Confirmar conexão de ID/Relay em VM isolada, sem serviço legado.
3. Gerar software ZIP com install/windows/Gerar-Release-DRGinfo-Windows.ps1.
4. Registrar SHA-256 ZIP e do EXE, mantendo artefato imutável.
5. Publicar ZIP em:
   https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/<VERSAO>/DRGinfo-AcessoRemoto-windows-x64.zip
6. Conferir HEAD/GET HTTPS e SHA-256 baixando do servidor com origem pública.
7. Gerar instalador gui5 com install/windows/Gerar-Pacote-Instalador.ps1,
   informando SoftwareUrl, SoftwareSha256 e SoftwareVersion publicados.
8. Gerador incorpora release-config.psd1, logo e scripts de instalação/desinstalação.
9. Validar ZIP instalador, SHA-256, manifesto e o código-fonte usado (SourceCommit).
10. Testar numa VM restaurada de snapshot e somente então liberar aos clientes.

Exemplo de geração APÓS publicação, substituir pelos valores reais:
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Gerar-Pacote-Instalador.ps1 -Version 1.0.0-gui5 -SoftwareVersion 1.5.3-drginfo.2 -SoftwareUrl '<URL_IMUTAVEL_HTTPS>' -SoftwareSha256 '<SHA256_ZIP_PUBLICADO>'

**Regra obrigatória:** NÃO reutilizar o hash ou ZIP da versão 1.5.3-drginfo.1.
Não publicar novo conteúdo sobre URL da release anterior.

## 4. Instalador e segurança
Interface: install/windows/Interface-DRGinfo-AcessoRemoto.ps1 (WinForms).
Motor: install/windows/Instalar-DRGinfo-AcessoRemoto.ps1.
Remoção: install/windows/Desinstalar-DRGinfo-AcessoRemoto.ps1.
O instalador lê manifesto PSD1, exige HTTPS, host/download path controlado,
confronta o hash SHA256 do ZIP e valida entradas ZIP antes de extrair.
UAC é solicitado quando usuário confirma a instalação; não embutir senhas.
Sem assinatura Authenticode atualmente: transição para assinatura de código
verificada deve ser requisito antes de distribuição pública ampla.
A instalação não sobrescreve versão prévia: desinstalar antes da migração.
Registro Windows: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DRGinfoAcessoRemoto.
Valores: DisplayName, DisplayVersion, Publisher, InstallLocation,
DisplayIcon, UninstallString, InstallDate, EstimatedSize, NoModify/NoRepair.
Desinstalador preserva logs e dados dos usuários; remoção integral de dados
pessoais é procedimento separado conforme política de retenção/LGPD.

## 5. Riscos e rollback
- Conflito entre serviço instalado e aplicativo portátil: testar separadamente.
- EXE novo depende de DLL compilada para a mesma versão; nunca misturar pastas.
- TCP 21115/21116/21117 disponível não substitui teste fim-a-fim de ID/Relay.
- Snapshots libvirt: confirmar tipo (interno/externo) e procedimento de retorno.
- Falha após instalação: preservar logs, coletar diagnóstico somente leitura;
  restaurar snapshot ou reinstalar pacote anterior homologado por release.
- Não realizar remoção indiscriminada de registro/configuração de terceiros.
- Não inserir senhas, chave privada de servidor, certificados A1, tokens em logs.
- Status GUI5 não homologado até teste completo de instalação e remoção.

## 6. Evidências de teste 25/11/2026
- Build visual novo, aberto isoladamente com serviço anterior parado: status Pronto.
- gui4: download versão 1.5.3-drginfo.1, hash antigo comprovado,
  serviço Windows criado e iniciado; registro ARP visível em captura.
- gui4: remoção por Aplicativos instalados; entrada desapareceu em captura.
- A auditoria limpa WIN11PROLAB encontrou serviços=0, processos=0, ARP=0.
**Observação:** ainda não há evidência de gui5 + novo binário instalado
como serviço, reiniciado e conectado fim-a-fim. Nem de assinatura Authenticode.

## 7. Checklist de homologação gui5
[ ] Artifact novo no GitHub Actions encontrado e verificado
[ ] EXE DRGinfo, ícones (Explorer, janela, tarefa e bandeja) revisados
[ ] ZIP da nova versão publicado e hash verificado por download HTTPS
[ ] gui5 gerado usando URL+SHA+versão corretos
[ ] Instalação com usuário comum e UAC sob demanda
[ ] Entrada ARP mostra a versão nova e o editor DRGinfo
[ ] Serviço automático após reinicialização
[ ] Estação pronta e conexão remota fim-a-fim com outra VM
[ ] Desinstalação por Aplicativos instalados remove pasta/serviço/ARP
[ ] Logs preservados e sem senhas
[ ] Documentação, licenças e fontes da revisão distribuída disponíveis
[ ] Teste sem alertas críticos na versão assinada antes da oferta comercial

## 8. Histórico
gui2 e portable1: homologados anteriormente em VM.
gui4: fluxo de instalação, serviço, entrada em Aplicativos instalados
e remoção validados por operador/capturas. gui4 utiliza BINÁRIO ANTIGO.
gui5: implementação de empacotamento fixo do BINÁRIO NOVO; integração pendente
de publicação VPS e teste operacional. Não confundir status.

## 9. Conformidade e licenciamento
Licença RustDesk OSS: AGPL-3.0.
Preservar copyright de terceiros e cópias da licença.
Disponibilizar código-fonte correspondente da versão distribuída, incluindo
alterações, scripts e instruções para compilar e instalar. Não tratar a
troca da marca na UI como cessão de direitos autorais.
Avaliar outras marcas/marcas registradas e licenças de dependências
antes de comercialização. Endereço de fontes: configurar link público
para a revisão imutável liberada.
Fonte: https://www.gnu.org/licenses/agpl-3.0.html
Origem: https://github.com/rustdesk/rustdesk
