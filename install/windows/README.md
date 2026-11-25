## Homologacao funcional — Portable 1.5.3-drginfo.1-portable1 (2026-11-24)

**Aprovado pelo operador na segunda VM Windows:** download/copia e extracao, execucao direta de `DRGinfo Acesso Remoto.exe` com usuario comum e sem instalacao, exibicao do ID e status Pronto, e conexao remota assistida funcional **fim a fim**. O gerador informou que nao alterou servicos ou programas instalados. Teste separado de ausencia de rastros de perfil/registro nao foi realizado; nao interpretar portatil como sem persistencia de configuracoes.

- Artefato: `DRGinfo-AcessoRemoto-Portable-Windows-x64.zip`
- Diretorio de criacao: `C:\ProgramData\DRGinfo\AcessoRemoto\releases\portable\1.5.3-drginfo.1-portable1\`
- SHA256 reportado pela geracao: `965EBEFA62D7ED808634B68990D9786C3D4F26B11D3A0E9709958FD86B49669D`
- Fonte: pacote binario homologado `1.5.3-drginfo.1`; nenhuma recompilacao.
- Aprovacao: **funcionamento da modalidade portatil**. Publicacao na VPS e conferência HTTPS externa ainda pendentes.
- Nao implica validacao de acesso desassistido apos reinicio (somente instalavel oferece servico automatico).
- Mantida limitacao de ausencia de assinatura Authenticode na release atual.

---

## Evolucao: Instalavel gui3 e Portable (24/11/2026)

**Instalavel gui3:** `Instalar-DRGinfo-AcessoRemoto.ps1` preserva instalacao e servico homologados; agora copia o desinstalador tecnico de `Desinstalar-DRGinfo-AcessoRemoto.ps1` para `C:\ProgramData\DRGinfo\AcessoRemoto\tools\`, cria entrada HKLM em `SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DRGinfoAcessoRemoto` com nome, versao, fabricante, diretorio, icone e comando `UninstallString`. Registro so apos servico atingir Running, com rollback da chave ao falhar. Usuário comum pode selecionar Desinstalar e autorizar UAC; dados e logs sao preservados. **Nao atualizar o gui2 in place**: motor atual recusa sobrescrever uma instalacao existente.

**Gerador gui3:** `Gerar-Pacote-Instalador.ps1 -Version 1.0.0-gui3` agora inclui 6 arquivos: interface, motor, desinstalador, iniciador .cmd, logo e LEIA-ME. Revisao de origem fixa `18b4f829c35f8a4724cf58472a0f64d780ce8760`. Gerar em `C:\ProgramData\DRGinfo\AcessoRemoto\releases\installer-gui\1.0.0-gui3`; publicar em novo diretorio da VPS somente apos teste.

**Portable:** `Gerar-Pacote-Portable.ps1` utiliza o mesmo ZIP do aplicativo já homologado na VPS, valida SHA-256 `3AC5BAC4B6AD211395C8C98FC9BA0E220517105C70F30003A818E36E588E8BA9`, valida caminhos e componentes e gera `DRGinfo-AcessoRemoto-Portable-Windows-x64.zip` em `C:\ProgramData\DRGinfo\AcessoRemoto\releases\portable\1.5.3-drginfo.1-portable1`. O pacote nao cria serviço, nem entrada de desinstalacao. O operador extrai tudo e abre `DRGinfo Acesso Remoto.exe`. Apagar a pasta encerra a distribuicao, mas configuracoes do usuario podem permanecer em AppData. **Nao prometer acesso desassistido depois de reiniciar no modo portatil.**

**Testes pendentes:** confirmar em VM instalacao gui3, registro no Windows, desinstalacao GUI/UAC, ausencia de entradas orfas e preservacao dos logs. Para Portable, testar abrir sem admin, ID, conexao assistida, fechamento, ausencia de servico criado e artefatos persistidos no perfil. Para os dois: a assinatura Authenticode comercial ainda nao esta implantada. Nao declarar homologado antes destes testes.

---

## Interface comercial — revisao gui2 (24/11/2026)

- A mensagem visivel no formulario nao utiliza mais a expressao `release provisoria`; apresenta `Download seguro pela infraestrutura DRGinfo | Integridade verificada por SHA-256.`
- A release atual **nao possui assinatura Authenticode**. Essa limitacao permanece documentada e informada na confirmacao da instalacao; HTTPS e SHA-256 nao substituem assinatura de codigo.
- Pacote de interface `1.0.0-gui2`, com fonte fixada no commit `c14de0df64a32f9c94b2a4314400380efb46195b` e publicacao em diretorio separado na VPS.
- Nao sobrescrever o ZIP `1.0.0-gui1` eventualmente existente. Nenhuma alteracao no cliente instalado `1.5.3-drginfo.1`.

---

## Pacote unico do instalador grafico — v1.0.0-gui1 (2026-11-24)

Objetivo: entregar **um ZIP de instalador** com quatro recursos operacionais e um LEIA-ME, sem o binario de 68 MB. O aplicativo e obtido exclusivamente na VPS HTTPS com SHA-256 fixado na hora da instalacao.

- `instalador-drginfo.cmd`: ponto de entrada por duplo clique, pode iniciar como usuario comum
- `Interface-DRGinfo-AcessoRemoto.ps1`: interface WinForms e elevacao UAC no clique de Instalar
- `Instalar-DRGinfo-AcessoRemoto.ps1`: backend ja homologado em Windows 11
- `logo-drginfo.png`: identidade visual oficial
- `LEIA-ME.txt`: instrucoes para o tecnico

**Geracao em pasta permanente:** executar `Gerar-Pacote-Instalador.ps1` em Windows PowerShell 5.1. O gerador baixa os recursos de revisao Git fixa `0049673ef12bf7973c0c15b74b0919705ee6c260`, confere sintaxe dos PS1, verifica a estrutura PNG, cria um ZIP versionado e grava manifesto SHA256. Esta fase de **montagem** utiliza GitHub, mas o instalador de campo nao baixa o cliente do GitHub.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\ProgramData\DRGinfo\AcessoRemoto\Gerar-Pacote-Instalador.ps1" -Version "1.0.0-gui1"
```

Saida: `C:\ProgramData\DRGinfo\AcessoRemoto\releases\installer-gui\1.0.0-gui1\DRGinfo-Instalador-Windows-x64.zip` e `release.txt` com SHA256.

**Publicacao:** copiar esse ZIP ao Debian administrativo e executar `install/linux/publicar-instalador-vps.sh` com ZIP e hash gerado. Diretorio VPS: `/srv/drginfo-downloads/rustdesk/drginfo-acesso-remoto/instalador/1.0.0-gui1/`. Nunca sobrescrever releases anteriores.

**Teste em VM limpa:** baixar do dominio HTTPS DRGinfo, comparar SHA256 com manifesto independente, extrair o ZIP inteiro e abrir `instalador-drginfo.cmd` com usuario comum. Confirmar UAC apenas ao clicar Instalar, instalação com credencial admin aprovada, servico automatico e acesso remoto funcional. Em VM ja instalada, somente interface e botao Abrir aplicativo (sem reinstalar).

**Estado:** scripts e empacotador publicados no GitHub; o ZIP do instalador grafico ainda nao foi gerado/publicado na VPS nem homologado em VM limpa. Nao divulgar como release final.

---

## Correcao 24/11/2026 — Logotipo com usuario comum

A interface procura `logo-drginfo.png` primeiro ao lado do `.ps1` e depois em `C:\ProgramData\DRGinfo\AcessoRemoto\logo-drginfo.png`. Isto evita desaparecer a marca quando o script e executado de `Downloads` com usuario padrao. Na distribuicao final, scripts, logo e motor de instalacao devem ser empacotados e verificados juntos, sem depender do diretorio de trabalho.

## Privilegios e UAC — revisao 24/11/2026

- `Interface-DRGinfo-AcessoRemoto.ps1` e `instalador-drginfo.cmd` podem abrir com usuario comum, sem solicitacao de UAC antecipada.
- Na abertura, a interface apenas consulta o servico e verifica se o aplicativo ja esta instalado. Para instalacao existente, botao Instalar desabilitado, Abrir aplicativo habilitado.
- Ao clicar **Instalar DRGinfo**, a interface confirma a acao e inicia o **motor PowerShell** via `Start-Process -Verb RunAs`; Windows solicita consentimento ou credenciais administrativas no UAC.
- Nao usa, coleta ou armazena senha de administrador. Se o UAC for cancelado ou indisponivel, nenhuma instalacao e executada.
- O backend continua exigindo elevacao antes de criar arquivos/servicos. Nao ha como registrar servico Windows com privilegios de usuario comum sem autorizacao administrativa.
- **Validacao pendente:** testar o fluxo completo de instalacao via GUI em VM limpa com usuario comum e credencial admin autorizada. O nucleo e servico ja foram homologados na VM existente; nao reinstalar por cima.
- O `-ExecutionPolicy Bypass` e aplicado somente ao processo do script, nao altera a politica global; distribuicao final deve verificar integridade dos scripts antes de executa-los e, se aplicavel, assina-los.

---

## Interface grafica - revisao visual 24/11/2026

- Fundo branco continuo no painel principal e no cabecalho; detalhes em azul corporativo.
- Logo original de `flutter/assets/drginfo-logo.png` exibida na janela sem retangulo branco de contraste; o carregamento do PNG cria copia em memoria e converte branco exato em canal transparente, sem alterar o arquivo original.
- Na abertura, verifica `DRGinfo Acesso Remoto` no Service Control Manager e a pasta do programa. Quando instalado, mostra o estado do servico, desabilita **Instalar DRGinfo** e habilita **Abrir aplicativo** quando existe o EXE esperado.
- Continua oferecendo **Abrir log**; nao oferece botao ficticio de Atualizar/Reparar enquanto o modulo nao estiver homologado.
- Interface alterada, nao implica nova instalacao e nao modifica a release `1.5.3-drginfo.1` da VPS.
- Teste grafico na VM ainda pendente desta revisao.

## Interface grafica DRGinfo (primeira versao de homologacao)

- Arquivo: `Interface-DRGinfo-AcessoRemoto.ps1` (Windows Forms, UAC nativo, barra de atividade, acompanhamento de logs).
- Backend: `Instalar-DRGinfo-AcessoRemoto.ps1` **ja homologado**; nao modifica executavel nem o ZIP da VPS.
- Para mostrar o logotipo oficial na interface, colocar `logo-drginfo.png` ao lado do script (o codigo ja inclui suporte a essa imagem). A interface exibe a identidade DRGinfo em texto quando o recurso nao estiver presente. A imagem oficial esta versionada no projeto em `flutter/assets/drginfo-logo.png`.
- **Nao instalar de novo na VM ja homologada**: a interface detecta o servico ou a pasta existente e preserva a instalacao.
- A interface grafica e nova: requer teste visual e funcional antes de ser distribuida aos clientes. A barra em modo indeterminado indica atividade, nao porcentagem medida.

## Assinatura de codigo gratuita: o que existe

- O documento antigo `Dossie-Tecnico-DRGinfo-RustDesk.pdf` registra que a assinatura Authenticode do **RustDesk original 1.5.3** era validada. Nao demonstra que a DRGinfo tinha certificado proprio.
- A assinatura do `custom.txt` e diferente da assinatura Authenticode de EXE/DLL. O novo cliente dispensa `custom.txt`.
- `Criar-Certificado-Laboratorio.ps1` permite gerar certificado autoassinado `CodeSigningCert` gratuito, **apenas** no laboratorio e por autorizacao explicita. Exporta somente a parte publica; chave privada nao exportavel fica no Windows.
- Sem uma cadeia confiavel, a assinatura autoassinada nao sera reconhecida como editor publico confiavel. Nao introduzir esse certificado nas autoridades raiz de clientes sem politica apropriada; isso NAO equivale a EV/OV, nem a reputacao SmartScreen.
- A release atual `1.5.3-drginfo.1`, publicada na VPS e homologada na VM, **permanece sem assinatura**. O processo de assinatura produz uma **nova** release versionada, sem sobrescrever a homologada.

---

## Distribuicao provisoria SEM Code Signing (autorizada em 24/11/2026)

A DRGinfo aprovou distribuir a release portatil homologada sem certificado de assinatura de codigo no momento, mantendo HTTPS e hash SHA256 fixado **independente** do arquivo baixado. Isso reduz risco de corrupcao e adulteracao em transporte, mas NAO substitui a autenticidade oferecida por Authenticode, e o SmartScreen podera alertar.

**Gerar a release sem recompilar**, na VM Windows homologada:

```powershell
& 'C:\ProgramData\DRGinfo\AcessoRemoto\Preparar-Release-Provisoria.ps1' -SourceDirectory 'C:\DRGinfo-Teste' -Version '1.5.3-drginfo.1'
```

O script gera ZIP e release-sha256.txt em `C:\ProgramData\DRGinfo\AcessoRemoto\releases\windows-x64\1.5.3-drginfo.1`. O arquivo antigo `/rustdesk/1.5.3/rustdesk-1.5.3-x86_64.exe` nao sera alterado.

**Publicar na VPS**, a partir do Debian, usando `install/linux/publicar-release-vps.sh`, com o SSH e o caminho real do document root da VPS, sem adivinhar o mapeamento HTTP:

```bash
bash install/linux/publicar-release-vps.sh vpsdrg /srv/drginfo-downloads 1.5.3-drginfo.1 DRGinfo-AcessoRemoto-windows-x64.zip SHA256_VALIDADO
```

**Executar instalacao somente depois de verificar publicacao da release na VPS**, baixando de `https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/1.5.3-drginfo.1/DRGinfo-AcessoRemoto-windows-x64.zip` e passando `-AllowUnsigned` explicitamente:

```powershell
& 'C:\ProgramData\DRGinfo\AcessoRemoto\Instalar-DRGinfo-AcessoRemoto.ps1' -PackageUrl 'https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/1.5.3-drginfo.1/DRGinfo-AcessoRemoto-windows-x64.zip' -PackageSha256 'SHA256_VALIDADO_64_HEX' -AllowUnsigned -ValidateOnly
```

Depois da validacao sem efeitos, remover apenas `-ValidateOnly` para instalar. Nao desativar TLS, UAC, antivírus ou SmartScreen para contornar alertas. A release e **provisoria**, nao homologada como instalador comercial.

---

# DRGinfo Acesso Remoto — Distribuicao pela VPS (Windows x64)

## Politica definitiva

1. O instalador baixa a distribuicao **exclusivamente** por HTTPS da VPS DRGinfo, nunca do GitHub.
2. O dominio e o repositorio VPS ja constam na documentacao DRGinfo: `https://downloads.drginfo.com.br/rustdesk/1.5.3/rustdesk-1.5.3-x86_64.exe` (cliente RustDesk anterior, **nao** reutilizar como release DRGinfo personalizada). O ZIP novo sera publicado sob um caminho **versionado e separado** em `/rustdesk/`, a ser confirmado apos deploy na VPS.
3. O pacote ZIP possui SHA-256 **fixado** por release, enviado como parametro; um hash recebido da mesma conexao de download **nao e suficiente** para garantir autenticidade.
4. O executavel `rustdesk.exe` e `librustdesk.dll` devem possuir assinaturas **Authenticode Valid** da DRGinfo, verificadas por thumbprint de certificado autorizado.
5. A compilacao de GitHub Actions `45468695045` foi homologada em **modo portatil** e tem o artefato `rustdesk-unsigned-windows-x86_64`. Ele **ainda nao e uma release assinada** e, portanto, o instalador definitivo se recusara a instala-lo.
6. O certificado TLS da VPS **nao** substitui o certificado de assinatura de codigo Windows. O certificado A1 de emissao fiscal nao deve ser presumido apto para assinar executaveis (verificar EKU Code Signing).

## Pastas definitivas

| Funcao | Pasta |
| --- | --- |
| App instalado | `C:\Program Files\DRGinfo Acesso Remoto` |
| Releases/cache validado | `C:\ProgramData\DRGinfo\AcessoRemoto\packages\<SHA256>` |
| ZIP original | `...\packages\<SHA256>\package.zip` |
| Arquivos de origem extratidos | `...\packages\<SHA256>\extracted` |
| Logs | `C:\ProgramData\DRGinfo\AcessoRemoto\instalacao.log` |
| Inventario SHA256 | `C:\ProgramData\DRGinfo\AcessoRemoto\manifesto-sha256.csv` |
| Hospedagem VPS | `https://downloads.drginfo.com.br/rustdesk/` (origem documental confirmada); URL definitiva da release DRGinfo personalizada somente apos publicacao na VPS |

As pastas de release sao persistentes e nao sao apagadas em caso de falha de instalacao. Sem `%TEMP%` como fonte operacional. O cliente Windows usa configuracao incorporada, sem `custom.txt`.

## Preparacao de release assinada (nao concluida)

1. Disponibilizar um certificado valido de **assinatura de codigo** da DRGinfo, com sua chave privada armazenada fora do repositório, preferencialmente em armazenamento protegido/hardware.
2. Assinar o executavel e a DLL do nucleo Rust, com SHA-256 e carimbo do tempo confiavel. Verificar ambos usando `Get-AuthenticodeSignature`.
3. Empacotar a distribuicao completa (EXE, DLLs, `data/`, plugins) em ZIP, preservando estrutura de diretórios. **Nao** incluir `custom.txt`.
4. Calcular o SHA-256 definitivo do ZIP, salvar em manifesto de release de acesso controlado e disponibilizar o pacote na VPS via deploy atomico.
5. Confirmar DNS/HTTPS e acesso ao pacote. Publicar SHA-256 e thumbprint para o procedimento de instalacao; nunca publicar chaves privadas.

**O dominio/caminho base constam na documentacao, mas o ZIP DRGinfo personalizado e assinado ainda nao foi publicado/validado. Nao executar instalacao ate confirmar sua URL especifica e o certificado.**

### Preparador de release assinada

Foi adicionado `install/windows/Preparar-Release-Assinada.ps1`: recebe a pasta portatil homologada, exige certificado com EKU Code Signing e chave privada acessivel pelo Windows, assina EXE/DLL principal, verifica Authenticode e produz ZIP + manifesto SHA-256 em `C:\ProgramData\DRGinfo\AcessoRemoto\releases\windows-x64\<versao>`. Nao publica na VPS e nao exporta chaves privadas.

```powershell
& 'C:\ProgramData\DRGinfo\AcessoRemoto\Preparar-Release-Assinada.ps1' -SourceDirectory 'C:\DRGinfo-Teste' -CertificateThumbprint '<THUMBPRINT-DO-CERTIFICADO-DE-CODE-SIGNING>' -Version '1.5.3-drginfo.1'
```

A release antiga localizada em `/rustdesk/1.5.3/rustdesk-1.5.3-x86_64.exe` nao deve ser sobrescrita. A publicacao da versao assinada deve adotar caminho separado e versionado na mesma raiz da VPS.

**Caminho fisico da VPS confirmado pelo operador:** `/srv/drginfo-downloads/rustdesk/1.5.3/rustdesk-1.5.3-x86_64.exe`. Logo, o document root da publicacao do projeto e `/srv/drginfo-downloads`. A nova release vai para `/srv/drginfo-downloads/rustdesk/drginfo-acesso-remoto/1.5.3-drginfo.1/`, preservando a distribuicao antiga.

## Instalacao/validacao em pastas definitivas

Windows PowerShell x64 **como Administrador**, apos disponibilizacao da release assinada:

```powershell
$Script = 'C:\ProgramData\DRGinfo\AcessoRemoto\Instalar-DRGinfo-AcessoRemoto.ps1'
$Url = '<URL-HTTPS-VPS-RELEASE-DRGINFO-VERSIONADA>'
$Hash = '<SHA256-OFICIAL-DO-ZIP-64-HEX>'
$Thumbprint = '<CERTIFICADO-CODE-SIGNING-40-OU-64-HEX>'

# Validacao sem instalar servico nem alterar Program Files
& $Script -PackageUrl $Url -PackageSha256 $Hash -PublisherThumbprint $Thumbprint -ValidateOnly

# So executar depois de aprovar a validacao
& $Script -PackageUrl $Url -PackageSha256 $Hash -PublisherThumbprint $Thumbprint
```

O arquivo do script deve ser distribuido por canal administrado/confiavel e ter sua integridade verificada. A validacao de ZIP protege o pacote, mas nao autentica um script adulterado.

## Homologacao

- [x] Build portatil abriu, apresentou ID/Pronto e passou em conexao fim a fim, sem `custom.txt`
- [ ] Certificado de assinatura de codigo DRGinfo verificado
- [ ] Build portatil assinado (EXE + DLL), validado e empacotado
- [ ] VPS publica release HTTPS com hash oficial confirmado
- [ ] Instalador executou `-ValidateOnly` na pasta definitiva
- [ ] Instalacao com servico Windows testada em VM
- [ ] Reboot e acesso remoto sem login interativo comprovados
- [ ] Desinstalacao, rollback e convivencia com outras instalacoes confirmados
- [ ] Assinatura do instalador PowerShell e publicacao comercial revisadas

## Rollback / desinstalacao

O script de instalacao **nao sobrescreve** instalacoes existentes. Em falha apos instalacao, tenta remover somente servico e pasta criados; mantem cache persistente para auditoria. O desinstalador fica em `Desinstalar-DRGinfo-AcessoRemoto.ps1` e exige `-ConfirmRemoval`.

## Direitos e suporte

Conservar avisos AGPL-3.0/atribuicoes RustDesk e disponibilizar o codigo-fonte correspondente quando exigido pela licenca. Nenhum instalador foi homologado ate a conclusao dos testes acima.
