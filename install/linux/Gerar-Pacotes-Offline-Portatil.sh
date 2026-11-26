#!/usr/bin/env bash
# DRGinfo - offline e portatil para pendrive, preparados no Debian.
set -Eeuo pipefail
[[ $# == 2 ]] || { echo "Uso: $0 ZIP_RELEASE DIRETORIO_SAIDA_EXISTENTE"; exit 2; }
SRC=$(realpath -- "$1")
ROOT=$(realpath -- "$2")
[[ -f "$SRC" && -d "$ROOT" ]] || exit 2
for cmd in curl unzip zip sha256sum python3; do command -v "$cmd" >/dev/null || { echo "Falta: $cmd"; exit 2; }; done
EXPECTED='7770f8d6b61217568124bbb2fb96d482621ba52fbf1c8ceff2cd31a2ef776525'
COMMIT='716b7de3985bdc8a2738129eaadc56b21b07e99f'
OUT="$ROOT/DRGinfo-Pacotes-1.0.0-gui6-offline"
[[ ! -e "$OUT" ]] || { echo "Release ja existe: $OUT"; exit 3; }
echo "$EXPECTED  $SRC" | sha256sum -c - >/dev/null
unzip -tqq "$SRC" >/dev/null
python3 - "$SRC" <<'PY'
import zipfile,sys,stat
with zipfile.ZipFile(sys.argv[1]) as z:
 if len(z.infolist())>10000: raise ValueError("Entradas demais")
 total=0
 names=set()
 for e in z.infolist():
  n=e.filename.replace("\\","/")
  if n.startswith("/") or ":" in n or ".." in n.split("/") or n in names: raise ValueError("ZIP inseguro: "+n)
  names.add(n)
  if stat.S_ISLNK(e.external_attr>>16): raise ValueError("Link no ZIP")
  total+=e.file_size
  if total>1073741824: raise ValueError("ZIP grande demais")
PY
OFF="$OUT/offline"; POR="$OUT/portatil"
mkdir -p -- "$OFF" "$POR"
OK=0
cleanup(){ [[ "$OK" == 1 ]] || rm -rf -- "$OUT"; }
trap cleanup EXIT
BASE="https://raw.githubusercontent.com/drginfo/drginfo-acesso-remoto/$COMMIT"
download(){ curl --fail --silent --show-error --location --proto '=https' --proto-redir '=https' "$BASE/$2" -o "$OFF/$1"; test -s "$OFF/$1"; }
download instalador-drginfo.cmd install/windows/instalador-drginfo.cmd
download Interface-DRGinfo-AcessoRemoto.ps1 install/windows/Interface-DRGinfo-AcessoRemoto.ps1
download Instalar-DRGinfo-AcessoRemoto.ps1 install/windows/Instalar-DRGinfo-AcessoRemoto.ps1
download Desinstalar-DRGinfo-AcessoRemoto.ps1 install/windows/Desinstalar-DRGinfo-AcessoRemoto.ps1
download logo-drginfo.png flutter/assets/drginfo-logo.png
cp -- "$SRC" "$OFF/DRGinfo-AcessoRemoto-windows-x64.zip"
cat > "$OFF/release-config.psd1" <<'EOF'
@{
  Offline = $true
  SoftwareUrl = 'https://downloads.drginfo.com.br/rustdesk/drginfo-acesso-remoto/1.5.3-drginfo.2/DRGinfo-AcessoRemoto-windows-x64.zip'
  SoftwareSha256 = '7770F8D6B61217568124BBB2FB96D482621BA52FBF1C8CEFF2CD31A2EF776525'
  SoftwareVersion = '1.5.3-drginfo.2'
}
EOF
unzip -q "$SRC" -d "$POR"
for part in 'DRGinfo Acesso Remoto.exe' 'librustdesk.dll' 'flutter_windows.dll' 'LICENCE' 'manifesto-sha256.csv' 'data/app.so' 'data/icudtl.dat'; do
  test -f "$POR/$part" || { echo "Falta no portatil: $part"; exit 4; }
done
test -d "$POR/data/flutter_assets"
test ! -e "$POR/rustdesk.exe"
cat > "$POR/Abrir-DRGinfo-Portatil.cmd" <<'EOF'
@echo off
setlocal
set "BASE=%~dp0"
if not exist "%BASE%DRGinfo Acesso Remoto.exe" exit /b 1
start "" /D "%BASE%" "%BASE%DRGinfo Acesso Remoto.exe"
exit /b 0
EOF
cat > "$OFF/LEIA-ME-OFFLINE.txt" <<'EOF'
DRGinfo Acesso Remoto - instalador OFFLINE Windows 10/11 x64
Extraia TODO o ZIP para uma pasta local e execute instalador-drginfo.cmd.
UAC sera solicitado; criara servico Automatic, atalhos e entrada em Aplicativos.
Nao ha download do SOFTWARE durante a instalacao.
Conectividade e obrigatoria para sessao remota (ID/Relay).
Software nao assinado Authenticode: nunca desabilite antivirus/SmartScreen/UAC.
Licenca AGPL-3.0 no ZIP de software e fontes em github.com/drginfo/drginfo-acesso-remoto
EOF
cat > "$POR/LEIA-ME-PORTATIL.txt" <<'EOF'
DRGinfo Acesso Remoto - portatil Windows 10/11 x64
Extraia TODO o ZIP e execute Abrir-DRGinfo-Portatil.cmd.
Launcher nao instala servico, nao cria atalhos e nao pede UAC.
A aplicacao pode gravar configuracoes/logs no perfil de usuario Windows.
Nao executar simultaneamente com servico DRGinfo Acesso Remoto instalado.
Suporte remoto requer conectividade ID/Relay e autorizacao.
Licenca AGPL-3.0: LICENCE; fontes: github.com/drginfo/drginfo-acesso-remoto
EOF
for d in "$OFF" "$POR"; do
 (cd "$d"; find . -type f ! -name 'manifesto-distribuicao-sha256.txt' -print0 | sort -z | xargs -0 sha256sum > manifesto-distribuicao-sha256.txt)
done
(cd "$OFF" && zip -q -r -X "$OUT/DRGinfo-Instalador-Offline-Windows-x64.zip" .)
(cd "$POR" && zip -q -r -X "$OUT/DRGinfo-Portatil-Windows-x64.zip" .)
for z in "$OUT"/*.zip; do unzip -tqq "$z" >/dev/null; done
(cd "$OUT"; sha256sum ./*.zip) > "$OUT/release.txt"
echo "SOURCE_COMMIT=$COMMIT" >> "$OUT/release.txt"
echo 'STATUS=PREPARADO_NAO_HOMOLOGADO' >> "$OUT/release.txt"
cat "$OUT/release.txt"
ls -lh "$OUT"/*.zip
echo "DIRETORIO=$OUT"
OK=1
