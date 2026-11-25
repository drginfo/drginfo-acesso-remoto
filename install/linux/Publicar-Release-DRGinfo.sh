#!/usr/bin/env bash
# DRGinfo Acesso Remoto — publicar ZIP imutavel na VPS.
# Bash/coreutils/OpenSSH; nao sobrescreve release; nenhum segredo no log.
set -Eeuo pipefail
umask 077

usage() {
  echo "Uso: $0 <ZIP_LOCAL> <VERSAO>"
  echo "Ex.: $0 ~/Downloads/DRGinfo-Software-1.5.3-drginfo.2/DRGinfo-AcessoRemoto-windows-x64.zip 1.5.3-drginfo.2"
  exit 2
}
[[ $# -eq 2 ]] || usage
ZIP=$1
VERSION=$2
[[ -f "$ZIP" && ! -L "$ZIP" ]] || { echo "ZIP local nao encontrado/nao regular"; exit 1; }
[[ "$VERSION" =~ ^[0-9A-Za-z][0-9A-Za-z._-]{0,63}$ ]] || { echo "Versao invalida"; exit 1; }
[[ "$(basename -- "$ZIP")" == "DRGinfo-AcessoRemoto-windows-x64.zip" ]] || { echo "Nome do ZIP inesperado"; exit 1; }

SHA=$(sha256sum -- "$ZIP" | awk '{print $1}')
HOST='vpsdrg'
REMOTE_DIR='/srv/drginfo-downloads/rustdesk/drginfo-acesso-remoto'
DEST="$REMOTE_DIR/$VERSION/DRGinfo-AcessoRemoto-windows-x64.zip"
URL="https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/$VERSION/DRGinfo-AcessoRemoto-windows-x64.zip"

echo "RELEASE=$VERSION"
echo "LOCAL_SHA256=$SHA"
echo "DESTINO=$DEST"
echo "URL=$URL"
echo "Publicacao imutavel; interrompa se os dados divergirem."
read -r -p "Digite PUBLICAR DRGINFO para prosseguir: " CONFIRM
[[ "$CONFIRM" == 'PUBLICAR DRGINFO' ]] || { echo "Cancelado"; exit 1; }

# Evitar sobrescrita de release existente ANTES do upload.
if ssh "$HOST" bash -s -- "$DEST" <<'CHECK'
set -euo pipefail
[[ ! -e "$1" && ! -L "$1" ]] || { echo "Release ja existe: $1"; exit 4; }
CHECK
then :; else echo "Publicacao cancelada: destino ocupado/SSH falhou"; exit 1; fi

REMOTE_TMP=$(ssh "$HOST" 'mktemp /tmp/drginfo-release.XXXXXXXX.zip') || exit 1
[[ "$REMOTE_TMP" =~ ^/tmp/drginfo-release[.]([A-Za-z0-9]+)[.]zip$ ]] || { echo "Caminho temporario invalido"; exit 1; }
cleanup() { ssh "$HOST" rm -f -- "$REMOTE_TMP" >/dev/null 2>&1 || true; }
trap cleanup EXIT
scp -q -- "$ZIP" "$HOST:$REMOTE_TMP"

# Verificacao remota, criacao atomica sem -f; pressupoe permissao adequada
# na webroot da DRGinfo. Nao utiliza sudo silenciosamente.
ssh "$HOST" bash -s -- "$REMOTE_TMP" "$SHA" "$DEST" <<'PUBLISH'
set -Eeuo pipefail
umask 022
temp=$1
expected=$2
dest=$3
[[ -f "$temp" && ! -L "$temp" ]] || { echo 'Upload temporario invalido'; exit 2; }
actual=$(sha256sum -- "$temp" | awk '{print $1}')
[[ "$actual" == "$expected" ]] || { echo "SHA no servidor divergente: $actual"; exit 3; }
[[ ! -e "$dest" && ! -L "$dest" ]] || { echo 'Release ja existe'; exit 4; }
mkdir -p -- "$(dirname "$dest")"
# Criacao exclusiva: evita sobrescrita; cp --no-clobber requer GNU coreutils.
# Cria um hardlink dentro do diretorio para evitar gravacao parcial publicada.
stage="$(dirname "$dest")/.drginfo-$(basename "$dest").$$"
trap 'rm -f -- "$stage"' EXIT
install -m 0644 -- "$temp" "$stage"
[[ "$(sha256sum -- "$stage" | awk '{print $1}')" == "$expected" ]] || exit 5
ln -- "$stage" "$dest"
rm -f -- "$stage"
trap - EXIT
echo "PUBLISHED=$dest"
PUBLISH

# Verifica a copia servida publicamente; sem redirecionamentos.
FILE_SHA=$(curl --fail --silent --show-error --location --proto '=https' --proto-redir '=https' --max-time 180 "$URL" | sha256sum | awk '{print $1}')
[[ "$FILE_SHA" == "$SHA" ]] || { echo "ERRO: SHA publico divergente: $FILE_SHA"; exit 6; }
echo "PUBLICADO_E_VALIDADO=$URL"
echo "SOFTWARE_SHA256=$SHA"
echo "SOFTWARE_VERSION=$VERSION"
