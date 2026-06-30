"""Regenerates Android launcher icons + store 512 + a Flutter splash asset
from the crossword logo (variant A). Run: python tool/gen_launcher_icons.py
"""
import os
import sys
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import gen_logo_cross as L  # noqa: E402

ROOT = os.path.dirname(HERE)
RES = os.path.join(ROOT, "android", "app", "src", "main", "res")
ASSET_IMG = os.path.join(ROOT, "assets", "images")
STORE_ASSETS = os.path.join(ROOT, "store", "assets")
os.makedirs(ASSET_IMG, exist_ok=True)

DENSITIES = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
BG = (8, 12, 23, 255)


def fullbleed(size):
    """Opaque square icon (corners filled with the dark bg)."""
    base = Image.new("RGBA", (size, size), BG)
    base.alpha_composite(L.cross_icon(size, "A"))
    return base


def circle(img):
    s = img.size[0]
    m = Image.new("L", (s, s), 0)
    ImageDraw.Draw(m).ellipse([0, 0, s, s], fill=255)
    out = img.copy()
    out.putalpha(m)
    return out


def main():
    for d, sz in DENSITIES.items():
        icon = fullbleed(sz)
        path = os.path.join(RES, f"mipmap-{d}")
        os.makedirs(path, exist_ok=True)
        icon.convert("RGB").save(os.path.join(path, "ic_launcher.png"))
        circle(icon).save(os.path.join(path, "ic_launcher_round.png"))
        print("icons", d, sz)

    # Store 512 (full-bleed square)
    fullbleed(512).convert("RGB").save(os.path.join(STORE_ASSETS, "icon_512.png"))
    # Flutter splash asset (rounded, transparent corners — floats on aurora)
    L.cross_icon(512, "A").save(os.path.join(ASSET_IMG, "logo.png"))
    print("store icon + splash asset done")


if __name__ == "__main__":
    main()
