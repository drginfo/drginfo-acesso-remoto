# DRGinfo Acesso Remoto — Windows x64 white-label

## Arquitetura aprovada

- Produto exibido: **DRGinfo Acesso Remoto**
- Interface: Flutter com logotipo **DRGinfo Consultoria & Suporte**, asset local `flutter/assets/drginfo-logo.png`
- Núcleo Rust: nome, rendezvous, relay e chave **pública** do servidor incorporados em `src/common.rs`
- Entrada Windows: `src/core_main.rs` aplica parâmetros embarcados em lugar de ler `custom.txt`
- Servidor/relay: `drgvps.drginfo.com.br`
- Assinatura do `custom.txt`: mecanismo legado preservado no código para outras plataformas, não exigido no Windows DRGinfo
- Direitos de terceiros: atribuição e avisos originais do RustDesk preservados. Distribuição deve observar AGPL-3.0

## Marca, ícones e metadados

O arquivo-fonte de referência é `flutter/assets/drginfo-logo.png`. Não editar a imagem original.

`tools/generate_drginfo_icons.py` gera a partir dele:

- `flutter/windows/runner/resources/app_icon.ico` — executável Windows
- `res/icon.ico` e `res/tray-icon.ico`
- `res/32x32.png`, `res/128x128.png`, `res/128x128@2x.png`

O gerador requer Pillow e roda **antes** do build no workflow de diagnóstico x64. Isso evita armazenar ícones duplicados alterados manualmente e mantém a marca reproduzível. Para ícones pequenos, o gerador extrai a parte DRG do logotipo oficial sem distorção e a enquadra num canvas transparente. A interface Flutter continua exibindo o logotipo completo. Ícones pequenos devem ser inspecionados visualmente na homologação.

`flutter/windows/runner/Runner.rc` define metadados corporativos e mantém copyright do fornecedor original; não representa a DRGinfo como autora original do RustDesk.

## Política de build (custo/tempo)

1. Alterações em `feat/drginfo-embedded-config` **não** acionam automaticamente o workflow de diagnóstico.
2. Executar validações estáticas e revisar o diff antes do build.
3. Gerar **um** artefato Windows x64 de homologação pela execução manual do workflow, ao concluir a revisão.
4. Não trocar o instalador Windows atualmente homologado enquanto esta variante não passar por testes essenciais.
5. Sem limpeza de perfis e sem testes repetidos de configuração por tentativa e erro.

## Checklist de homologação

- [ ] Build Windows x64 concluído e artefatos preservados
- [ ] Versão do executável, DLLs e assets verificados
- [ ] Ícone DRGinfo no executável e bandeja verificado
- [ ] Janela inicial mostra logotipo oficial e título DRGinfo Acesso Remoto
- [ ] Cliente abre **sem** `custom.txt`
- [ ] Verificar servidor configurado sem expor chave pública em logs detalhados
- [ ] Cliente apresenta estado `Pronto`
- [ ] Conexão remota e relay funcionais, teste fim a fim
- [ ] Identidade do cliente e licenças verificadas
- [ ] Documentar log, commit, resultado e rollback

## Limitações e critérios

Código publicado **não equivale a compilação ou homologação**. Um eventual estado `Não está pronto` deve ser investigado separadamente da inicialização da interface. Preservar logs sem segredos e evitar alterar a VPS durante a validação do cliente.
