# Recuperação e rollback — Windows DRGinfo

- Não atualizar instalações existentes automaticamente a partir de uma build não homologada.
- Preservar instalador v1.1.2, ZIP e SHA256 da release operacional, sem sobrescrever.
- Guardar relatório do estado de serviços, registros, permissões, arquivos e hashes antes de intervenções.
- Em caso de falha, interromper distribuição, identificar revisão e artefato envolvidos, voltar à versão previamente homologada conforme aprovação do operador.
- Não executar limpeza de ProgramData, perfis de usuário ou chaves de registro sem inventário, backup e autorização.
