# DRGinfo Acesso Remoto — Entrega Windows P4 (1.5.3-drginfo.p4)

Data: 2026-11-27. **Estado: Windows P4 homologado funcionalmente para piloto controlado; distribuição comercial irrestrita condicionada a autorização de suporte, licenças, privacidade e publicação de release formal.**

**Padrão de nomenclatura:** usar `DRGinfo-Acesso-Remoto-Windows-x64.zip` como nome canônico da próxima release. Na VPS o mesmo conteúdo está publicado como `DRGinfo-AcessoRemoto-windows-x64.zip`; preservar a URL antiga até migração controlada. O hash, não o nome, identifica os bytes do pacote.

## Produtos de entrega previamente preparados e auditados
| Produto | SHA-256 ZIP | Situação |
|---|---|---|
| Binário Windows x64 ZIP | `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a` | Baixado da VPS, hash confirmado na VM |
| GUI offline ZIP | `A64327D732CA7C81736242CB995BD26626DBF23A8B059D5DFDF8ED910F35E49B` | 8/8 itens do manifesto; teste novo sem rede aprovado |
| GUI online ZIP | `0C55846BD82AC030FB51BC7A65478696385F9E281A66E2E2244F1E8C6A6CEDDB` | Download real da VPS e nova instalação aprovados |
| Portátil ZIP | `46DEDF2D9497E940D2A35FFB81A142EAA6CAACFC57361500AB5505BBD1CFFC2D` | 111/111 itens; acesso remoto fim a fim aprovado |

**Cautela:** hashes acima refletem os ZIPs auditados na homologação; verificar novamente cada arquivo antes de publicação/entrega e registrar local exato de hospedagem. Não publicar URL inventada para os ZIPs das GUIs ou portátil.

## Instalação/remoção
- Plataforma homologada: Windows 11 x64; instalador indica Windows 10/11 x64. Compatibilidade em versões não testadas não é garantia de homologação.
- GUI online: pacote gráfico com `instalador-drginfo.cmd`, solicita UAC, obtém ZIP da VPS oficial e valida SHA-256 antes de executar/copy.
- GUI offline: pacote inclui ZIP local validado; testado com adaptador da VM desconectado, sem cache de hash ativo. O acesso remoto exige reconexão de rede para ficar `Pronto`.
- Portátil: ZIP extraído em pasta local, sem instalação de serviço; homologação fim a fim realizada separadamente.
- A instalação do serviço registra `DRGinfo Acesso Remoto` (Automatic, LocalSystem), atalhos no desktop público/Menu Iniciar e entrada em Aplicativos instalados.
- Remoção: Aplicativos instalados > DRGinfo Acesso Remoto > Desinstalar; script oficial preserva logs e dados do usuário. **Não apagar ProgramData nem perfis indiscriminadamente.**

## Evidências finais
- 2026-11-27 13:14:21: download real da VPS. 13:14:38: hash validado. 13:14:47: instalação concluída.
- 2026-11-27 13:37:45: GUI offline funcional instalada usando cache presente (teste intermediário).
- 2026-11-27 13:48:26: instalação offline definitiva em VM com adaptador desconectado e cache antigo isolado; serviço, ARP e atalhos criados.
- Após reconexão: UI mostra `Pronto` automaticamente; instalação reconhecida como existente. Portátil e sessão fim a fim anteriormente aprovados.
- Integridade do pacote principal: SHA-256 `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a`.

## Critérios comerciais e de suporte
1. Divulgação a clientes **somente com aviso de binário não assinado** e orientação de hash/HTTPS, evitando prometer publisher verificado.
2. Entregar avisos AGPL e acesso ao Corresponding Source **da build correspondente** — correlação agora comprovada: commit `5bbef89a64c707a67a8ff4b5de9c228eb732dc79`, GitHub Actions #45929565631, artefato 15169411324, SHA-256 coincidente. Preservar fontes completas e conferir licenças de dependências (ver `P4-RASTREABILIDADE-BINARIO.md`).
3. Publicar e confirmar política de privacidade e página Sobre com atribuição RustDesk; registrar URL final antes da divulgação.
4. Contrato/termo de suporte deve definir autorização expressa para acesso remoto, responsabilidades e canal para revogação do acesso.
5. Controles mínimos de distribuição: hashes por pacote, changelog, registros das versões, backup dos artefatos, validação dos links e testes de download com máquina limpa; não bloquear exigências de segurança do cliente.
6. Assinatura Authenticode: **ADIADA POR DECISÃO DE CUSTO**, não incluída nesta release. Revisitar quando a comercialização financiar aquisição.
7. Não misturar builds futuras Linux/Android nem alterar branch padrão do GitHub sem homologação independente.

## Pré-release futura
Nenhuma GitHub Release existia na consulta de 27/11. Proposta: pré-release com tag no commit imutável `5bbef89a64c707a67a8ff4b5de9c228eb732dc79`, contendo quatro ZIPs originais com hashes; **ainda não criada** porque não foi validada a disponibilidade dos três ZIPs adicionais como arquivos acessíveis ao publicador. Previamente definir termo de autorização de acesso remoto e fazer revisão de LGPD. Consulte `P4-RECONCILIACAO-E-CRITERIOS-DE-LIBERACAO.md`.

## Registro final de decisão
Homologação funcional encerrada. A comercialização de **serviços de suporte com software livre** é tecnicamente viável, mas a DRGinfo **não deve descrever o pacote como integralmente liberado para distribuição irrestrita** antes de disponibilizar os avisos de licença, verificar disponibilidade do código-fonte completo correspondente e comprovar a publicação das informações de privacidade. **A revisão exata e a integridade do artefato já estão comprovadas.** Não é necessário recompilar para produzir essas evidências, salvo se o artefato original não puder ser vinculado ao código existente.
