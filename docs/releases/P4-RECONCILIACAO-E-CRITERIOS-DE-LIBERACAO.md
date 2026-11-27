# P4 — Reconciliação de evidências e critérios de liberação

**Data:** 2026-11-27. **Decisão:** Windows P4 **homologado funcionalmente para piloto controlado**; distribuição comercial irrestrita **não liberada**.

## Diferença entre mapa anterior e testes posteriores
O mapa de alterações anterior foi elaborado antes dos ensaios finais e, por isso, registra pendências então existentes. Não substitui o registro cronológico de evidências posteriores em `CHANGELOG-P4.md`. **Não rebaixar testes realmente executados a "não testado" sem analisar suas evidências.**

| Teste | Evidência de 27/11/2026 | Resultado |
|---|---|---|
| Desinstalação da P4 | Log `2026-11-27 13:07:51 Concluido. Logs e dados de usuarios preservados.`; serviço/pasta/ARP/atalho `False` | Aprovado na VM |
| GUI online, instalação nova | Cache isolado; log `13:14:21 Baixando release da VPS`, SHA-256 validado `13:14:38`, instalação `13:14:47`; operador confirmou acesso fim a fim, branding, atalhos e ARP | Aprovado na VM |
| Desinstalação após online | Serviço/pasta/ARP `False`, pelo Windows | Aprovado na VM |
| GUI offline, instalação nova | Log `13:37:45 INSTALACAO CONCLUIDA`; nessa primeira execução podia utilizar cache | Aprovado funcionalmente; isolamento não atestado nessa primeira rodada |
| Desinstalação após offline | Serviço e pasta `False` | Aprovado na VM |
| GUI offline SEM rede/SEM cache ativo | Cache ativo isolado; adaptador virtual desconectado, conexão HTTPS `False`; captura mostra instalação concluída `13:48:26`, serviço e atalhos; após reconectar UI voltou a `Pronto` | Aprovado no ensaio isolado |
| Portátil | Manifesto 111/111 e sessão remota fim a fim anteriormente confirmada | Aprovado |
| UAC em usuário comum | Orientado nos procedimentos; confirmação **explícita** do diálogo de elevação não consta no último relatório enviado | Evidência específica não registrada |

**Escopo dos resultados:** VM Windows 11 x64 e pacotes específicos identificados pelos hashes de homologação. Não afirmar cobertura de todos os endpoints ou ambientes corporativos.

## Proveniência imutável
- GitHub Actions run `45929565631`, commit `5bbef89a64c707a67a8ff4b5de9c228eb732dc79`.
- Comparação GitHub com pai `18c15907e63a263d0ee9ae35904e85f7778766fd`: **1 commit à frente, 0 atrás, apenas `docs/releases/DRGINFO-P4-PLANO-RELEASE.md` modificado**; código de execução equivalente nessa comparação.
- Artefato `DRGinfo-Acesso-Remoto-Windows-x64`, ID `15169411324`, tamanho 35.565.328 bytes.
- SHA-256 do artefato GitHub e do ZIP recebido na VM: `926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a`. **A identidade SHA, e não só igualdade de tamanho**, comprova a correspondência.

## Nomenclatura canônica adotada para a futura release
- Artefato principal **canônico**: `DRGinfo-Acesso-Remoto-Windows-x64.zip` (mesma denominação da compilação GitHub Actions).
- Arquivo **atual** hospedado na VPS, compatível com clientes existentes: `DRGinfo-AcessoRemoto-windows-x64.zip` (mantê-lo acessível até plano de migração; não renomear unilateralmente).
- Pacotes de homologação restantes: `DRGinfo-Instalador-Windows-x64.zip`, `DRGinfo-Instalador-Offline-Windows-x64.zip`, `DRGinfo-Portatil-Windows-x64.zip`.
- Uma mudança **somente de nome** mantém SHA-256 do conteúdo do arquivo ZIP se os bytes não forem modificados; verificar hash antes de publicar o alias.
- **Nenhuma GitHub Release encontrada** na consulta de 2026-11-27; não inventar link de download dos três ZIPs não hospedados.

## Página Sobre e material local
- Operador enviou captura com endereço público corrigido para `.../tree/5bbef89a64c707a67a8ff4b5de9c228eb732dc79`, com copyright RustDesk e AGPL-3.0.
- O HTML **local antigo** pode continuar apontando a `fdd7525...`; deve ser corrigido e sincronizado como arquivo-fonte da publicação. Não afirmar que qualquer arquivo HTML local foi alterado sem evidência de sua gravação.
- Arquivo canônico no GitHub: `CODIGO-FONTE-P4-PAGINA-SOBRE.md` (texto já atualizado).
- A publicação da política de privacidade foi informada pelo operador; auditoria de conteúdo LGPD independente ainda não foi realizada.

## Gatilhos da distribuição
1. **Piloto controlado:** permitido como decisão operacional, com suporte autorizado, aviso de ausência de assinatura, política adequada, cliente informado e direitos AGPL preservados.
2. **Pré-release no GitHub:** preparar tag no commit `5bbef89...` e anexar os **quatro ZIPs originais**, com SHA-256, changelog e licença, **somente quando os arquivos puderem ser acessados, revalidados e enviados**. Não criar uma pré-release vazia ou com pacotes hipotéticos.
3. **Comercialização/distribuição irrestrita:** termo/modelo de autorização de acesso remoto, nome/links padronizados, materiais de licença e fontes correspondentes disponíveis, revisão de privacidade e release publicada.
4. **Authenticode:** aquisição adiada; avisar que o editor não é digitalmente identificado e não pedir desativação de proteções do Windows.

## Escopo
O encerramento técnico da P4 mantém-se válido. Não recompilar nem reexecutar testes aprovados apenas para mudar palavras do relatório. Novas plataformas Linux/Android serão tratadas em projetos/releases independentes.
