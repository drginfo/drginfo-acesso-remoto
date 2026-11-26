#!/usr/bin/env python3
"""Generate Windows icon assets from the approved DRGinfo logo.

Build-only utility. Never changes the original brand image.
Requires Pillow; run from repository root with Python 3.
"""
from pathlib import Path
from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[1]
LOGO = ROOT / "flutter/assets/drginfo-logo.png"
if not LOGO.is_file():
    raise SystemExit(f"Official DRGinfo logo not found: {LOGO}")

with Image.open(LOGO) as opened:
    logo = opened.convert("RGBA")

# Use the DRG symbol portion of the approved wordmark for small Windows icons.
# Keep the complete official logo unchanged in the Flutter interface.
# Crop proportionally so this remains valid for source logo resolutions.
w, h = logo.size
symbol = logo.crop((0, int(h * 0.04), int(w * 0.51), int(h * 0.73)))
icon = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
scaled = ImageOps.contain(symbol, (236, 236), Image.Resampling.LANCZOS)
icon.alpha_composite(scaled, ((256 - scaled.width) // 2, (256 - scaled.height) // 2))
sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
for relative in (
    "flutter/windows/runner/resources/app_icon.ico",
    "res/icon.ico",
    "res/tray-icon.ico",
):
    target = ROOT / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    icon.save(target, format="ICO", sizes=sizes)
    print(f"[DRGinfo] icon generated: {relative}")

# Generate package PNG icons from the same logo, retaining transparency.
for relative, size in (
    ("res/32x32.png", 32),
    ("res/128x128.png", 128),
    ("res/128x128@2x.png", 256),
):
    target = ROOT / relative
    icon.resize((size, size), Image.Resampling.LANCZOS).save(target, format="PNG")
    print(f"[DRGinfo] png generated: {relative}")
