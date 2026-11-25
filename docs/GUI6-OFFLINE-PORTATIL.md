# DRGinfo Acesso Remoto — Offline e Portatil (pendrive)
Data: 25/11/2026
Software: 1.5.3-drginfo.2 | Instalador base: gui6
Estado: IMPLEMENTADO EM FONTE, TESTES OPERACIONAIS PENDENTES.

## Objetivo
Entregar duas distribuicoes Windows 10/11 x64 autocontidas a partir do
mesmo ZIP comercial publicado e validado:
`DRGinfo-AcessoRemoto-windows-x64.zip`.
SHA256 software:
`7770f8d6b61217568124bbb2fb96d482621ba52fbf1c8ceff2cd31a2ef776525`.

## Geradores
- Debian: `install/linux/Gerar-Pacotes-Offline-Portatil.sh`
- Windows PowerShell 5.1:
  `install/windows/Gerar-Pacotes-Offline-Portatil.ps1`
- Ambos criam novo diretorio e nunca sobrescrevem uma release existente.
- A preparacao requer Internet para baixar scripts de revisao Git fixa;
  os pacotes prontos nao dependem de download do software na instalacao.

## Instalador offline
Arquivo final: `DRGinfo-Instalador-Offline-Windows-x64.zip`.
Contem instalador-drginfo.cmd, GUI WinForms, scripts de instalacao e
desinstalacao, logo, release-config.psd1 e ZIP integral de software.
- GUI verifica SHA256 do arquivo local antes de solicitar UAC.
- Motor aceita `-PackageFile` exclusivo de `-PackageUrl`; valida novamente
  SHA256 e usa ZIP local em vez de HTTPS.
- Mantem o mesmo servico automatico, ARP, Desktop publico e pasta DRGinfo
  no Menu Iniciar do gui6, desinstalador com retirada de atalhos proprios.
- Sem Internet **para instalar**, mas sessoes remotas exigem rede e acesso
  aos servidores ID/Relay da DRGinfo.
- Extrair o ZIP completo numa pasta local antes de abrir .cmd.
- Nao remover/desabilitar Defender, SmartScreen ou UAC.

## Portatil
Arquivo final: `DRGinfo-Portatil-Windows-x64.zip`.
Contem o software Windows x64 integral, licenca, manifesto, dependencias,
`Abrir-DRGinfo-Portatil.cmd` e manual.
- O launcher apenas executa o EXE, sem UAC, servico, ARP ou atalhos.
- O proprio aplicativo pode persistir dados/configuracoes no perfil do
  usuario Windows; portanto NAO GARANTE zero rastros.
- Recursos que requerem elevacao nao ficam automaticamente habilitados.
- Evitar execucao simultanea com servico de outra instalacao DRGinfo.
- Extrair o ZIP integral antes de executar.
- Nao executar codigo diretamente de ZIP compactado.

## Testes minimos para liberar
1. Gerar ambos ZIPs no Debian e registrar hashes `release.txt`.
2. Comparar conteudo, assinatura/hash software e licenca.
3. VM limpa offline (sem acesso ao dominio de downloads):
   instalar offline; UAC, servico Automatic, atalhos, ARP.
4. Reiniciar, conectar rede e testar conexao ID/Relay fim a fim.
5. Remover e validar servico, aplicativo, ARP, atalhos.
6. Em outra VM limpa executar `Abrir-DRGinfo-Portatil.cmd` sem admin.
7. Verificar ausencia de servico e ARP criados pelo launcher,
   conectividade e integridade de icones; documentar logs no perfil.
8. Preservar hashes, fontes correspondentes GNU AGPL-3.0 e resultado.

## Comando Debian
```bash
SCRIPT="$HOME/DRGinfo/homologacao/1.5.3-drginfo.2/Gerar-Pacotes-Offline-Portatil.sh"
RELEASE="$HOME/DRGinfo/homologacao/1.5.3-drginfo.2/release/DRGinfo-AcessoRemoto-windows-x64.zip"
curl -fLSs "https://raw.githubusercontent.com/drginfo/drginfo-acesso-remoto/ddb008391fb7b3e22e613f46ebe371b0a19ac56f/install/linux/Gerar-Pacotes-Offline-Portatil.sh" -o "$SCRIPT"
bash -n "$SCRIPT"
bash "$SCRIPT" "$RELEASE" "$HOME/DRGinfo/homologacao/1.5.3-drginfo.2"
```

## Conformidade
Base RustDesk OSS GNU AGPL-3.0; o pacote inclui LICENCE no ZIP software.
Distribuicao exige fonte correspondente, modificacoes, instrucoes de build
e creditos/licencas de dependencias. Produto ainda nao tem assinatura
Authenticode; testes antes de publicidade comercial.
