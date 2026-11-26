# DRGinfo Acesso Remoto — Estado atual

Data: 2026-11-26. Escopo: Windows x64, branch `fix/drginfo-windows-startup-diagnostics`.

## Evidências e limites
- A compilação diagnóstica do commit `8a00dd145` concluiu no GitHub Actions; ela não continha o empacotador comercial nem a configuração Windows embarcada da branch comercial.
- O commit `a604dc104` restaurou o empacotador corporativo; a execução automática ainda não representa homologação.
- Esta reconciliação restabelece fontes Windows do histórico comercial e inclui bloqueio de atualizações do commit `8a00dd145`.
- A marca, o nome, os scripts, as ACLs, os serviços, o funcionamento de conexão e o bloqueio no executável novo **não estão homologados** por esta alteração de código.
- O instalador v1.1.2 já homologado não foi substituído.
- Linux e Android: não iniciar builds antes de encerrar e homologar Windows.

## Caminho de entrega
O workflow `.github/workflows/drginfo-diagnostico-windows-x64.yml` precisa publicar `DRGinfo-Acesso-Remoto-Windows-x64`; pacote contém `DRGinfo Acesso Remoto.exe`, bibliotecas internas originais, LICENCE, LEIA-ME e manifesto SHA256. Os artefatos `rustdesk-unsigned-*` são técnicos, não destinados à distribuição.

## Pendências de aprovação
- Revisão e homologação do executável Windows, ícones, metadados, servidor/relay, conexão, atualizações e instalação/desinstalação.
- Auditoria efetiva de ACL de Program Files e ProgramData em VM; sem evidências, **não declarar seguro/homologado**.
- Autenticode: artefato unsigned. Publicação para clientes condicionada à decisão de assinatura e registro dos hashes.

## Correção visual 26/11/2026
- Captura de homologação mostrou interface Pronto e ID, mas logotipo da DRGinfo ausente; causa: `flutter/lib/common.dart` continuava selecionando os assets RustDesk padrão.
- A interface Windows personalizada passa a carregar `flutter/assets/drginfo-logo.png` no painel e `drginfo-icon.png` gerado do mesmo arquivo aprovado no ícone de UI.
- A compilação anterior **não está aprovada** como identidade visual final; esta revisão requer novo artefato e conferência visual, sem substituir instalações existentes.
