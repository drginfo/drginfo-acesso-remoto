# DRGinfo Acesso Remoto — Distribuicao pela VPS (Windows x64)

## Politica definitiva

1. O instalador baixa a distribuicao **exclusivamente** por HTTPS da VPS DRGinfo, nunca do GitHub.
2. O dominio previsto e \`downloads.drginfo.com.br\`, que deve ter DNS, certificado TLS e virtual host validados **antes** da primeira instalacao.
3. O pacote ZIP possui SHA-256 **fixado** por release, enviado como parametro; um hash recebido da mesma conexao de download **nao e suficiente** para garantir autenticidade.
4. O executavel \`rustdesk.exe\` e \`librustdesk.dll\` devem possuir assinaturas **Authenticode Valid** da DRGinfo, verificadas por thumbprint de certificado autorizado.
5. A compilacao de GitHub Actions \`45468695045\` foi homologada em **modo portatil** e tem o artefato \`rustdesk-unsigned-windows-x86_64\`. Ele **ainda nao e uma release assinada** e, portanto, o instalador definitivo se recusara a instala-lo.
6. O certificado TLS da VPS **nao** substitui o certificado de assinatura de codigo Windows. O certificado A1 de emissao fiscal nao deve ser presumido apto para assinar executaveis (verificar EKU Code Signing).

## Pastas definitivas

| Funcao | Pasta |
| --- | --- |
| App instalado | \`C:\Program Files\DRGinfo Acesso Remoto\` |
| Releases/cache validado | \`C:\ProgramData\DRGinfo\AcessoRemoto\packages\<SHA256>\` |
| ZIP original | \`...\packages\<SHA256>\package.zip\` |
| Arquivos de origem extratidos | \`...\packages\<SHA256>\extracted\` |
| Logs | \`C:\ProgramData\DRGinfo\AcessoRemoto\instalacao.log\` |
| Inventario SHA256 | \`C:\ProgramData\DRGinfo\AcessoRemoto\manifesto-sha256.csv\` |
| Hospedagem VPS | URL publica \`https://downloads.drginfo.com.br/acesso-remoto/windows-x64/DRGinfo-AcessoRemoto-windows-x64.zip\`; caminho local na VPS depende da configuracao do web server |

As pastas de release sao persistentes e nao sao apagadas em caso de falha de instalacao. Sem \`%TEMP%\` como fonte operacional. O cliente Windows usa configuracao incorporada, sem \`custom.txt\`.

## Preparacao de release assinada (nao concluida)

1. Disponibilizar um certificado valido de **assinatura de codigo** da DRGinfo, com sua chave privada armazenada fora do repositório, preferencialmente em armazenamento protegido/hardware.
2. Assinar o executavel e a DLL do nucleo Rust, com SHA-256 e carimbo do tempo confiavel. Verificar ambos usando \`Get-AuthenticodeSignature\`.
3. Empacotar a distribuicao completa (EXE, DLLs, \`data/\`, plugins) em ZIP, preservando estrutura de diretórios. **Nao** incluir \`custom.txt\`.
4. Calcular o SHA-256 definitivo do ZIP, salvar em manifesto de release de acesso controlado e disponibilizar o pacote na VPS via deploy atomico.
5. Confirmar DNS/HTTPS e acesso ao pacote. Publicar SHA-256 e thumbprint para o procedimento de instalacao; nunca publicar chaves privadas.

**Nao ha prova de que o endereco de download ja esteja online. Nao executar instalacao ate o pacote assinado ser publicado.**

## Instalacao/validacao em pastas definitivas

Windows PowerShell x64 **como Administrador**, apos disponibilizacao da release assinada:

\`\`\`powershell
$Script = 'C:\ProgramData\DRGinfo\AcessoRemoto\Instalar-DRGinfo-AcessoRemoto.ps1'
$Hash = '<SHA256-OFICIAL-DO-ZIP-64-HEX>'
$Thumbprint = '<CERTIFICADO-CODE-SIGNING-40-OU-64-HEX>'

# Validacao sem instalar servico nem alterar Program Files
& $Script -PackageSha256 $Hash -PublisherThumbprint $Thumbprint -ValidateOnly

# So executar depois de aprovar a validacao
& $Script -PackageSha256 $Hash -PublisherThumbprint $Thumbprint
\`\`\`

O arquivo do script deve ser distribuido por canal administrado/confiavel e ter sua integridade verificada. A validacao de ZIP protege o pacote, mas nao autentica um script adulterado.

## Homologacao

- [x] Build portatil abriu, apresentou ID/Pronto e passou em conexao fim a fim, sem \`custom.txt\`
- [ ] Certificado de assinatura de codigo DRGinfo verificado
- [ ] Build portatil assinado (EXE + DLL), validado e empacotado
- [ ] VPS publica release HTTPS com hash oficial confirmado
- [ ] Instalador executou \`-ValidateOnly\` na pasta definitiva
- [ ] Instalacao com servico Windows testada em VM
- [ ] Reboot e acesso remoto sem login interativo comprovados
- [ ] Desinstalacao, rollback e convivencia com outras instalacoes confirmados
- [ ] Assinatura do instalador PowerShell e publicacao comercial revisadas

## Rollback / desinstalacao

O script de instalacao **nao sobrescreve** instalacoes existentes. Em falha apos instalacao, tenta remover somente servico e pasta criados; mantem cache persistente para auditoria. O desinstalador fica em \`Desinstalar-DRGinfo-AcessoRemoto.ps1\` e exige \`-ConfirmRemoval\`.

## Direitos e suporte

Conservar avisos AGPL-3.0/atribuicoes RustDesk e disponibilizar o codigo-fonte correspondente quando exigido pela licenca. Nenhum instalador foi homologado ate a conclusao dos testes acima.
