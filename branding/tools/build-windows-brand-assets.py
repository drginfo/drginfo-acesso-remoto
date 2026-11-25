#!/usr/bin/env python3
"""DRGinfo - recursos de identidade Windows/Flutter.
Executar no checkout antes do build. Fonte oficial quadrada em base64
compactado, versionada em branding/. Gera arquivos graficos derivados.

Nao altera protocolos, nomes de bibliotecas ou servidores.
"""
import base64
import hashlib
import io
from pathlib import Path

try:
    from PIL import Image
except ImportError as exc:
    raise SystemExit("Dependencia ausente: Pillow (python -m pip install pillow)") from exc

ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / "branding/drginfo-square-icon.png.base64"
MANIFEST = ROOT / "branding/GENERATED-SHA256.txt"

def main():
    raw = base64.b64decode(MASTER.read_text(encoding="ascii").strip(), validate=True)
    if not raw.startswith(b"\x89PNG\r\n\x1a\n"):
        raise SystemExit("Fonte quadrada nao e PNG.")
    image = Image.open(io.BytesIO(raw)).convert("RGBA")
    if image.width != image.height or image.width < 64:
        raise SystemExit("Logotipo mestre deve ser quadrado (minimo 64 px).")
    print("DRGinfo square source:", image.size, hashlib.sha256(raw).hexdigest())
    written = []
    def png(rel, size):
        dest = ROOT / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        image.resize((size,size),Image.Resampling.LANCZOS).save(dest,format="PNG",optimize=True)
        written.append(dest)
    def ico(rel):
        dest = ROOT / rel
        dest.parent.mkdir(parents=True,exist_ok=True)
        base = image.resize((256,256),Image.Resampling.LANCZOS)
        base.save(dest,format="ICO",sizes=[(16,16),(24,24),(32,32),(48,48),(64,64),(128,128),(256,256)])
        written.append(dest)

    for rel in (
        "flutter/windows/runner/resources/app_icon.ico",
        "flutter/assets/icon.ico",
        "res/icon.ico",
        "res/tray-icon.ico",
    ):
        ico(rel)
    for rel,size in (
        ("res/icon.png",512),
        ("res/32x32.png",32),
        ("res/128x128.png",128),
        ("res/128x128@2x.png",256),
        ("res/tray-icon.png",64),
        ("flutter/assets/icon.png",512),
        ("flutter/assets/drginfo-icon-square.png",512),
    ):
        png(rel,size)

    # Para refs SVG legadas: pixel-runs gerados do logotipo quadrado.
    # Somente rect/path, sem link externo e sem elementos nao suportados por flutter_svg.
    samples = image.resize((96,96),Image.Resampling.LANCZOS).convert("RGB")
    rows = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96">']
    for y in range(96):
        x=0
        while x < 96:
            rgb = samples.getpixel((x,y))
            x2=x+1
            while x2<96 and samples.getpixel((x2,y)) == rgb:
                x2 += 1
            fill = "#{:02x}{:02x}{:02x}".format(*rgb)
            rows.append(f'<path fill="{fill}" d="M{x} {y}h{x2-x}v1H{x}z"/>')
            x=x2
    rows.append("</svg>")
    svg = ROOT / "flutter/assets/icon.svg"
    svg.write_text("\n".join(rows)+"\n",encoding="utf-8")
    written.append(svg)
    info = [f"source_sha256 {hashlib.sha256(raw).hexdigest()} branding/drginfo-square-icon.png.base64"]
    info.extend(f"{hashlib.sha256(p.read_bytes()).hexdigest()} {p.relative_to(ROOT).as_posix()}" for p in written)
    MANIFEST.write_text("\n".join(info)+"\n",encoding="utf-8")
    print("\n".join(info))

if __name__ == "__main__":
    main()
