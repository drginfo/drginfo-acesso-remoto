#!/usr/bin/env bash
# DRGinfo | Validação estática P4, sem downloads, compilações ou mudanças.
# Executar da raiz do clone: bash tools/validar-p4-release.sh
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
falhas=0
bloqueios=0
ok() { printf '[OK] %s\n' "$*"; }
erro() { printf '[FALHA] %s\n' "$*" >&2; falhas=$((falhas+1)); }
bloqueio() { printf '[BLOQUEADO] %s\n' "$*" >&2; bloqueios=$((bloqueios+1)); }
exige() {
  local path="$1" literal="$2" desc="$3"
  if [[ ! -f "$path" ]]; then erro "$desc: arquivo ausente $path"
  elif grep -Fq -- "$literal" "$path"; then ok "$desc"
  else erro "$desc: marcador ausente em $path"; fi
}
printf 'DRGinfo | pré-validação estática P4 | commit=%s\n' "$(git rev-parse --short HEAD)"
exige flutter/lib/desktop/pages/desktop_setting_page.dart 'https://drginfo.com.br/acesso-remoto/' 'Website corporativo em Sobre'
exige flutter/lib/desktop/pages/desktop_setting_page.dart 'https://drginfo.com.br/privacidade-acesso-remoto/' 'Privacidade corporativa em Sobre'
exige flutter/lib/desktop/pages/install_page.dart 'https://drginfo.com.br/privacidade-acesso-remoto/' 'Privacidade no fluxo de instalação'
exige flutter/lib/desktop/pages/connection_page.dart 'if (bind.isCustomClient()) return;' 'Bloqueio do guia de preços upstream'
for f in DOCUMENTACAO-TECNICA-DRGINFO.md MANUAL-USUARIO-DRGINFO.md MANUAL-INSTALACAO-DRGINFO.md DRGINFO-P4-PLANO-RELEASE.md CHANGELOG-P4.md CONTROLE-WORDPRESS-PAGINAS-DRGINFO.md; do
  [[ -s "docs/releases/$f" ]] && ok "Documento $f" || erro "Documento ausente/vazio $f"
done
if [[ -f '.github/workflows/drginfo-diagnostico-windows-x64.yml' ]] && grep -Fq 'workflow_dispatch:' '.github/workflows/drginfo-diagnostico-windows-x64.yml'; then
  ok 'Workflow manual presente; este script não o dispara'
else
  erro 'Workflow manual não identificado'
fi
# Confirmar que a nova revisão recebe dados de release explicitos.
exige install/windows/Gerar-Pacote-Instalador.ps1 '[string]$SourceCommit,' 'Online: commit de origem obrigatorio'
exige install/windows/Gerar-Pacote-Instalador.ps1 '[string]$SoftwareSha256,' 'Online: hash obrigatorio'
exige install/windows/Gerar-Pacote-Instalador.ps1 '[switch]$UnsignedLab,' 'Online: excecao de laboratorio explicita'
exige install/windows/Gerar-Pacotes-Offline-Portatil.ps1 '[string]$ExpectedHash,' 'Offline/portatil: SHA obrigatorio'
exige install/windows/Gerar-Pacotes-Offline-Portatil.ps1 '[string]$SourceCommit,' 'Offline/portatil: commit obrigatorio'
exige install/windows/Interface-DRGinfo-AcessoRemoto.ps1 "ReleaseChannel -eq 'producao'" 'GUI: modo producao com protecao de assinatura'
exige install/windows/Interface-DRGinfo-AcessoRemoto.ps1 'Manifesto sem commit de origem valido' 'GUI: recusa manifesto sem commit'
for f in install/windows/Gerar-Pacote-Instalador.ps1 install/windows/Gerar-Pacotes-Offline-Portatil.ps1 install/windows/Interface-DRGinfo-AcessoRemoto.ps1; do
  if grep -Eq '1[.]5[.]3-drginfo[.]2|7770F8D6B61217568124BBB2FB96D482621BA52FBF1C8CEFF2CD31A2EF776525' "$f"; then
    erro "Referencias legadas remanescentes no gerador: $f"
  fi
done
if ((falhas)); then
  printf 'RESULTADO: FALHA_ESTÁTICA (%d achados)\n' "$falhas" >&2
  exit 1
fi
if ((bloqueios)); then
  printf 'RESULTADO: CÓDIGO_P4_PREVALIDADO; RELEASE_NÃO_APTA (%d bloqueios de empacotamento)\n' "$bloqueios" >&2
  exit 2
fi
printf 'RESULTADO: PREVALIDACAO_ESTÁTICA_OK (ainda requer build, testes e auditoria de pacotes).\n'
