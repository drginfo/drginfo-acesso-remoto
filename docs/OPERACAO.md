# Operação — Windows DRGinfo

1. Trabalhar sempre na branch Windows identificada; conservar histórico e backups.
2. Revisar `docs/DECISOES.md`, `docs/SEGURANCA.md` e `docs/ESTADO_ATUAL.md` antes de publicar.
3. O workflow valida presença da marca/configuração e gera ícones antes do build x64.
4. Artefato de entrega: `DRGinfo-Acesso-Remoto-Windows-x64`, distinto de `rustdesk-unsigned-windows-x86_64` (técnico).
5. Validar manifesto SHA256 e conteúdos; registrar evidências em `docs/TESTES.md`.
6. Instalação em VM somente com aprovação; não substituir instalador v1.1.2 homologado até conclusão.
7. Para rollback, manter release anterior intacta, restaurar artefato e configurações somente por procedimento autorizado.

Nenhum comando de publicação de Linux/Android integra esta etapa.
