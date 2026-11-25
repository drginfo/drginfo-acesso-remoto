## Implementacao da identidade DRGinfo — 2026-11-25

- Fonte quadrada derivada da logo enviada e aprovada pelo usuario, armazenada em `branding/drginfo-square-icon.png.base64` (PNG quadrado compacto de 96x96 px). Para iconografia de alta resolucao, manter tambem original 514x511 fora da build; nao afirmar que esta miniatura substitui o mestre.
- Gerador reproduzivel: `branding/tools/build-windows-brand-assets.py`, requer Pillow; gera ICO do Runner Windows, ICO Flutter, ICO Rust core/tray, PNGs em `res/` e `flutter/assets/` e SVG Flutter derivado da mesma marca. Registra hashes em `branding/GENERATED-SHA256.txt`.
- Workflow: `.github/workflows/drginfo-build-windows.yml`, etapa anterior ao build Rust/Flutter, em runner Windows x64; push manual controlado por `branding/BUILD_TRIGGER.md`, publica somente GitHub Actions artifacts.
- `flutter/windows/runner/main.cpp`: titulo de fallback DRGinfo; `flutter/windows/runner/Runner.rc`: FileDescription DRGinfo.
- Limites: nenhum hash publicado na VPS foi alterado; e necessario testar artefatos compilados para Windows Explorer, taskbar, Alt-Tab, tray, janelas, notificacoes e acessos fim a fim. A marca e referencias RustDesk exigidas para copyright/AGPL continuam em documentos legais.
- Mascote: versao com fundo transparente preparada separadamente; nao incorporada ao executavel como icone (a logo quadrada e mais legivel em 16x16/32x32).
- Estado: NOVO BUILD de validacao solicitado; aguardar verificacao efetiva de job e artefato antes de declarar compilado e homologado.

---

# DRGinfo Acesso Remoto — plano de identidade visual integral

Data: 2026-11-25
Estado: EM IMPLEMENTACAO; NAO HOMOLOGADO; nenhuma release aprovada foi substituida.

## Objetivo

Todas as superficies **voltadas ao cliente** devem exibir **DRGinfo Acesso Remoto** e os icones da DRGinfo, sem logos, titulos ou atalhos com a marca RustDesk. Preservar creditos, avisos de copyright, licencas e oferta do codigo-fonte modificado nos locais legalmente apropriados (ex.: Sobre / Licencas / documentacao).

A identidade final usa a **arte quadrada oficial DRGinfo**, sem laço de luto e sem distorcao, ainda a localizar ou fornecer como arquivo mestre. Nao usar automaticamente a imagem horizontal do cabeçalho para criar icones: miniaturas 16/24/32 px precisam de simbolo legivel, com transparencia apropriada.

## Fontes e pontos tecnicos confirmados no fork

| Area | Caminho ou configuracao | Verificacao |
|---|---|---|
| Icone do executavel Windows / Explorer | `flutter/windows/runner/resources/app_icon.ico` em `flutter/windows/runner/Runner.rc` | Substituir ICO multiresolucao antes do build |
| Icone dinamico na janela | `flutter/windows/runner/win32_window.cpp` busca `data/flutter_assets/assets/icon.ico` | Substituir asset, verificar fallback para recurso Windows |
| Logo/icone UI Flutter | `flutter/assets/icon.svg`, outros assets | Auditar referencias no Flutter, nao substituir indiscriminadamente |
| Recursos nativos e bandeja | `res/icon.ico`, `res/tray-icon.ico`, `res/icon.png` e tamanhos | Verificar chamadas no codigo e substituir cada recurso grafico efetivamente usado |
| Metadados PE | `flutter/windows/runner/Runner.rc` | FileDescription DRGinfo atualizado; manter LegalCopyright upstream |
| Build e identificadores internos | `flutter/windows/CMakeLists.txt` ainda usa `rustdesk` como target | Nao renomear bibliotecas, packages, protocolos ou modulos sem analise de dependencias |
| Instalavel e registro Windows | `install/windows/Instalar-DRGinfo-AcessoRemoto.ps1` | ja usa nome e DisplayIcon DRGinfo, mas icone dentro de EXE precisa de novo build |
| Portatil | `install/windows/Gerar-Pacote-Portable.ps1` | refazer somente depois da nova build homologada |
| Instalador grafico | `install/windows/Interface-DRGinfo-AcessoRemoto.ps1` | logo do instalador ja aprovado |
| Identidade por perfil/atalhos | Flutter e Windows | testar usuarios distintos; nao referenciar AppData de outra conta |

## Ordem de execucao

1. Conferir arte **quadrada aprovada** e registrar SHA256 do mestre em `branding/` ou `assets/`. Confirmar licenca/uso da arte e fundo transparente.
2. Gerar PNG e ICO multirresolucao de forma deterministica; armazenar fonte, script e inventario (nao alterar apenas binarios compilados).
3. Substituir recursos visuais nativos, Flutter, bandeja, telas, notificacoes e metadados do Windows; executar auditoria de strings visiveis versus identificadores internos.
4. Revisar creditos/licencas: RustDesk OSS AGPL-3.0, autorias e oferta do codigo-fonte correspondente de cada binario distribuido. A marca DRGinfo pode ser a fachada, mas nao ocultar autoria ou licenca obrigatoria.
5. Build CI Windows x64 de NOVA versao — manter intactos ZIPs e SHA256 homologados `1.5.3-drginfo.1`, `gui2` e `portable1`.
6. Validacao: Explorer/propriedades, UAC/SmartScreen, barra de tarefas, Alt+Tab, icone da janela, bandeja, notificacoes, tela Sobre, atalhos, program list/uninstall e dois perfis Windows (usuario comum + administrador).
7. Homologacao fim a fim: ID, servidor DRGinfo, acesso assistido e desassistido, reinstalacao gui3 e portatil; nova release e novos hashes.

## Notas de seguranca e engenharia

- Nao aplicar replace global de `rustdesk` em codigo ou diretorios: ha bibliotecas, protocolos, nomes de projeto e identificadores tecnicos com dependencias cruzadas.
- Alteracao de icones exige rebuild Windows x64 e nova verificacao de hashes; publicar nova release, nunca sobrescrever a atual.
- Um ICO correto nao garante que todo icone do app mude: Runner.rc e icone dinamico Flutter precisam coincidir.
- Sem certificado de assinatura Authenticode confiavel, a nova build pode exibir alerta do Windows; HTTPS/SHA256 nao substituem assinatura.
- O uso comercial da implementacao open source e possivel, condicionado a cumprir a licenca e os avisos legais pertinentes; esta nota nao substitui revisao juridica.
