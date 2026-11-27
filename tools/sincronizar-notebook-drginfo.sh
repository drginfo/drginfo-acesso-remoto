#!/usr/bin/env bash
# DRGinfo | Sincronizar repositorio completo no notebook (sem force/reset).
# Versao 2026-11-27. Requer git, ssh/https ja autenticado e rede.
set -Eeuo pipefail
umask 077

REPO_URL="https://github.com/drginfo/drginfo-acesso-remoto.git"
BRANCH="release/drginfo-windows-p4-links-docs"
DEST="${1:-$HOME/projetos/Drginfo/drginfo-acesso-remoto}"
mkdir -p "$(dirname "$DEST")"

if [[ ! -d "$DEST/.git" ]]; then
  if [[ -e "$DEST" ]]; then
    echo "ERRO: caminho existente nao e repositorio Git: $DEST" >&2
    exit 1
  fi
  git clone --branch "$BRANCH" --single-branch --recurse-submodules "$REPO_URL" "$DEST"
fi

cd "$DEST"
if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERRO: alteracoes locais nao commitadas. Salve/commit/stash manualmente antes de sincronizar." >&2
  exit 1
fi
if [[ "$(git config --get remote.origin.url)" != "$REPO_URL" ]]; then
  echo "AVISO: remote.origin diferente do endereco de referencia:"
  git remote -v
  echo "Verifique a origem manualmente. Nenhuma alteracao feita."
  exit 1
fi

git fetch --tags origin "$BRANCH"
if git show-ref --quiet --verify "refs/heads/$BRANCH"; then
  git switch "$BRANCH"
else
  git switch --track -c "$BRANCH" "origin/$BRANCH"
fi
git pull --ff-only origin "$BRANCH"
git submodule sync --recursive
git submodule update --init --recursive

echo "DRGINFO_SYNC_OK"
echo "PASTA=$DEST"
echo "BRANCH=$(git branch --show-current)"
echo "COMMIT=$(git rev-parse HEAD)"
git status --short
git submodule status --recursive
# Saida em arquivo fora do Git para evitar dirty worktree:
printf '%s\n' "branch=$BRANCH" "commit=$(git rev-parse HEAD)" > "$(dirname "$DEST")/drginfo-sync-ultimo.txt"
