# Manual de instalação — DRGinfo Acesso Remoto Windows x64
**Estado:** procedimentos baseados na build #18 homologada; instalador GUI/novos pacotes requerem testes separados.
## Pré-requisitos
- Windows 10/11 x64 atualizado, conectividade ao servidor corporativo e permissão administrativa **somente para instalação como serviço**.
- Baixar exclusivamente de distribuição aprovada DRGinfo; comparar SHA-256 com valor publicado independentemente.
- Não desabilitar SmartScreen, antivírus, UAC ou políticas empresariais. A edição testada não possui assinatura Authenticode; risco residual formalmente aceito para homologação.
## Modalidade portátil
1. Receba o ZIP do artefato corporativo completo; compare o SHA-256 publicado.
2. Extraia **toda** a pasta, mantendo EXE, DLLs e `data/` juntos.
3. Abra `DRGinfo Acesso Remoto.exe`; verifique **Pronto** e teste conexão autorizada.
4. Sem serviço automático por padrão; encerramento e exclusão da pasta não garantem remoção de dados do perfil.
## Modalidade instalável / offline — motor técnico homologado
- No laboratório, o motor `install/windows/Instalar-DRGinfo-AcessoRemoto.ps1` foi executado com `-PackageFile`, `-PackageSha256`, `-PackageVersion` e `-AllowUnsigned`; validar antes com `-ValidateOnly`.
- O motor depende do `Desinstalar-DRGinfo-AcessoRemoto.ps1` no mesmo diretório; a implantação utiliza privilégios elevados, serviço LocalSystem automático e entrada em Aplicativos instalados.
- A GUI `Interface-DRGinfo-AcessoRemoto.ps1` usa configuração de release `release-config.psd1` e valida URL/hash/assinatura; **NÃO FORÇAR** versões novas editando o manifesto sem revisão do código.
- Modo online requer URL HTTPS em `downloads.drginfo.com.br` já publicada e hash pinado. Modo offline usa binário completo pré-incluído, mas o acesso remoto operacional ainda requer rede.
## Verificação mínima
No PowerShell:
```powershell
Get-Service -Name 'DRGinfo Acesso Remoto' | Select-Object Name,Status,StartType
Get-Item 'C:\Program Files\DRGinfo Acesso Remoto\DRGinfo Acesso Remoto.exe' | Select-Object FullName,Length
```
Conferir **Running/Automatic**, interface **Pronto**, ID, teste fim a fim autorizado, reinicialização e repetição do teste.
## Desinstalar
Usar Windows > Configurações > Aplicativos instalados > DRGinfo Acesso Remoto. A desinstalação pode preservar arquivos de configuração e logs. Não excluir dados de auditoria ou instalar versão nova sobre antiga sem procedimento de migração.
## Reversão
1. Antes da alteração, snapshot/backup da VM e inventário da versão/hashes.
2. Em falha, não repetir instalador indiscriminadamente.
3. Registrar log, restaurar snapshot aprovado ou seguir processo documentado de desinstalação/instalação limpa.
4. Conferir conexões, serviço e caminhos de registro após retorno.
## Contatos
**sac@drginfo.com.br** e **privacidade@drginfo.com.br**.
