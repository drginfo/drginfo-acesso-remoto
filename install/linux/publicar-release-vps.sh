#!/usr/bin/env bash
# DRGinfo Acesso Remoto: deploy versionado, atomico e sem sobrescrever releases.
set -euo pipefail
if (($# != 5)); then
  echo 'Uso: publicar-release-vps.sh usuario@vps /caminho/docroot versao pacote.zip SHA256' >&2
  exit 2
fi
host="$1"; docroot="$2"; version="$3"; archive="$4"; expected="$5"
[[ "$docroot" == '/srv/drginfo-downloads' ]] || { echo 'Docroot invalido: esperado /srv/drginfo-downloads' >&2; exit 2; }
[[ "$version" =~ ^[a-zA-Z0-9._-]{1,60}$ ]] || exit 2
[[ "$expected" =~ ^[a-fA-F0-9]{64}$ ]] || exit 2
[[ -f "$archive" ]] || exit 2
echo "$expected  $archive" | sha256sum -c -
remote_dir="$docroot/rustdesk/drginfo-acesso-remoto/$version"
dest="DRGinfo-AcessoRemoto-windows-x64.zip"
# SSH BatchMode so no password input is requested or stored in scripts.
ssh -o BatchMode=yes "$host" "test ! -e '$remote_dir/$dest' && mkdir -p '$remote_dir' && test ! -e '$remote_dir/.upload.zip'"
scp -B "$archive" "$host:$remote_dir/.upload.zip"
ssh -o BatchMode=yes "$host" "cd '$remote_dir'; echo '$expected  .upload.zip' | sha256sum -c -; chmod 644 .upload.zip; mv -n .upload.zip '$dest'; test -s '$dest'"
echo "URL esperada: https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/$version/$dest"
echo "Confirme externamente HTTPS/200 e SHA256 antes de distribuir."
