# Instalacao Windows x64 — DRGinfo Acesso Remoto

## Origem validada

Build Windows x64 GitHub Actions: [execucao 45468695045](https://github.com/drginfo/drginfo-acesso-remoto/actions/runs/45468695045), commit `2dfc3bdd05452700475cc958d1b2ff7e3fb718ad`.

Artefato: `rustdesk-unsigned-windows-x86_64` (ID `14960691084`).
O cliente PORTATIL desse pacote foi testado no Windows 11 e teve acesso remoto fim a fim confirmado.

**O artefato nao tem assinatura Authenticode; NAO publicar para clientes como release final.**
Este instalador PowerShell e apenas para VM de homologacao.

## Preparar a VM

1. Extrair a distribuicao completa em `C:\DRGinfo-Teste` (inclusive `data`, DLLs e plugins).
2. Garantir que nao haja `custom.txt` nessa pasta. Configuracoes de ID/relay/chave publica ja estao no binario.
3. Baixar o script `install/windows/Instalar-DRGinfo-AcessoRemoto.ps1` na mesma VM.
4. Manter o RustDesk original e outros servicos intactos; a versao DRGinfo usa seu proprio nome.

## Instalacao (Windows PowerShell x64 COMO ADMINISTRADOR)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\DRGinfo-Teste\Instalar-DRGinfo-AcessoRemoto.ps1" -SourceDirectory "C:\DRGinfo-Teste"
```

O instalador verifica elevacao, arquitetura, arquivos, ausencia de `custom.txt` e inexistencia de instalacao previa. Copia a distribuicao completa para `C:\Program Files\DRGinfo Acesso Remoto`, renomeia o EXE para `DRGinfo Acesso Remoto.exe` (nome usado pelo proprio nucleo Rust), cria o servico Windows `DRGinfo Acesso Remoto`, configura inicio automatico, verifica o estado e gera manifesto SHA-256.

Falhas geram tentativa de rollback dos itens criados pelo script. Nenhuma configuracao de usuario e apagada.

## Verificacao unica

```powershell
Get-Service -Name 'DRGinfo Acesso Remoto' |
  Select-Object Name, Status, StartType
Get-Item 'C:\Program Files\DRGinfo Acesso Remoto\DRGinfo Acesso Remoto.exe' |
  Select-Object Name, Length, LastWriteTime
```

Abrir `C:\Program Files\DRGinfo Acesso Remoto\DRGinfo Acesso Remoto.exe` e verificar se apresenta ID, estado Pronto e permite conexao fim a fim. Depois, verificar permanencia do servico apos reinicializacao (teste isolado).

## Logs, integridade, rollback

- Log: `C:\ProgramData\DRGinfo\AcessoRemoto\instalacao.log`
- Manifesto: `C:\ProgramData\DRGinfo\AcessoRemoto\manifesto-sha256.csv`
- Desinstalacao explicitamente autorizada: `install/windows/Desinstalar-DRGinfo-AcessoRemoto.ps1 -ConfirmRemoval`
- O desinstalador valida o caminho do executavel, remove apenas o servico e arquivos DRGinfo, preservando dados e logs.
- Nao alterar/reinstalar os componentes RustDesk originais.

## Antes da distribuicao comercial

- [ ] Homologar instalacao e registro do servico em VM Windows limpa
- [ ] Confirmar inicializacao apos reboot e acesso remoto sem login interativo
- [ ] Validar conexao fim a fim com instalacao
- [ ] Validar desinstalacao/rollback e ausencia de interferencia com outras instalacoes
- [ ] Assinar o executavel/instalador com certificado de assinatura de codigo Windows apropriado
- [ ] Preservar aviso AGPL-3.0, atribuicoes RustDesk e disponibilizar fonte correspondente aos destinatarios

## Versoes

- 2026-11-24: primeira versao de homologacao do instalador PowerShell, sem rebuild do nucleo Rust/Flutter.
