#!/usr/bin/env bash
# DRGinfo: publicacao do ZIP do instalador grafico, sem sobrescrever releases.
# Usage: bash publicar-instalador-vps.sh pacote.zip SHA256 [usuario@servidor]
set -euo pipefail
if (( $# < 2 || $# > 3 )); then
  echo 'Uso: publicar-instalador-vps.sh pacote.zip HASH_SHA256 [vpsdrg]' >&2
  exit 2
fi
archive="$1"
sha="$2"
host="${3:-vpsdrg}"
[[ -f "$archive" ]] || { echo 'Arquivo nao encontrado.' >&2; exit 2; }
[[ "$sha" =~ ^[A-Fa-f0-9]{64}$ ]] || { echo 'Hash invalido.' >&2; exit 2; }
echo "$sha  $archive" | sha256sum -c -
destdir='/srv/drginfo-downloads/rustdesk/drginfo-acesso-remoto/instalador/1.0.0-gui1'
name='DRGinfo-Instalador-Windows-x64.zip'
ssh -o BatchMode=yes "$host" "test ! -e '$destdir/$name' && mkdir -p '$destdir' && test ! -e '$destdir/.upload.zip'"
scp -B "$archive" "$host:$destdir/.upload.zip"
ssh -o BatchMode=yes "$host" "cd '$destdir' && echo '$sha  .upload.zip' | sha256sum -c - && chmod 0644 .upload.zip && mv -n .upload.zip '$name' && test -s '$name'"
echo "URL prevista: https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/instalador/1.0.0-gui1/$name"
echo 'Validar HEAD/GET HTTPS e comparar SHA256 apos publicacao.'
