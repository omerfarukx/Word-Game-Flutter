"""Renders several app-logo concepts onto one contact sheet for review.
Output: store/assets/logo_options.png
Run: python tool/gen_logo_options.py
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "store", "assets")
os.makedirs(OUT, exist_ok=True)

VIOLET_HI, VIOLET_LO = (165, 133, 255), (109, 84, 240)
CYAN_HI, CYAN_LO = (82, 229, 245), (31, 168, 214)
AMBER_HI, AMBER_LO = (255, 206, 115), (245, 158, 11)
INK = (13, 19, 34)
INK2 = (8, 12, 23)
TILE = (244, 240, 250)
TILE_SH = (210, 202, 226)
WHITE = (240, 243, 250)

BOLD = ["C:/Windows/Fonts/segoeuib.ttf", "C:/Windows/Fonts/arialbd.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"]


def font(size):
    for p in BOLD:
        try:
            return ImageFont.truetype(p, size)
        except Exception:
            pass
    return ImageFont.load_default()


def vgrad(w, h, top, bot):
    col = Image.new("RGB", (1, h))
    for y in range(h):
        t = y / (h - 1)
        col.putpixel((0, y), tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)))
    return col.resize((w, h))


def rounded(img, rad):
    img = img.convert("RGBA")
    m = Image.new("L", img.size, 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, img.size[0], img.size[1]], rad, fill=255)
    img.putalpha(m)
    return img


def ctext(d, xy, t, f, fill, anchor="mm"):
    d.text(xy, t, font=f, fill=fill, anchor=anchor)


def bg_icon(s, top, bot):
    return rounded(vgrad(s, s, top, bot), int(s * 0.235))


def tile(size, face, letter, lcol, pt=None, ptcol=(120, 110, 140)):
    """A single word-game letter tile."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    # drop shadow
    sh = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle([int(size*0.08), int(size*0.12), int(size*0.96), int(size*0.98)],
                                         int(size*0.18), fill=(0, 0, 0, 90))
    sh = sh.filter(ImageFilter.GaussianBlur(size*0.04))
    img.alpha_composite(sh)
    d = ImageDraw.Draw(img)
    r = int(size * 0.18)
    d.rounded_rectangle([int(size*0.06), int(size*0.06), int(size*0.92), int(size*0.92)], r, fill=face)
    # top highlight
    d.rounded_rectangle([int(size*0.06), int(size*0.06), int(size*0.92), int(size*0.5)], r, fill=tuple(min(255, c+10) for c in face[:3]))
    d.rounded_rectangle([int(size*0.06), int(size*0.5), int(size*0.92), int(size*0.92)], 4, fill=face)
    ctext(d, (size*0.49, size*0.52), letter, font(int(size*0.5)), lcol)
    if pt:
        ctext(d, (size*0.8, size*0.82), pt, font(int(size*0.17)), ptcol)
    return img


# ── Concepts ────────────────────────────────────────────────────────────────
def concept_tile(s):
    """1 — Word tile: violet bg + a cream letter tile 'K'."""
    img = bg_icon(s, VIOLET_HI, VIOLET_LO)
    t = tile(int(s*0.62), TILE, "K", (60, 48, 110), pt="5")
    img.alpha_composite(t, ((s-t.width)//2, (s-t.height)//2))
    return img


def concept_fan(s):
    """2 — Fanned tiles: a cyan 'A' behind, white 'K' in front."""
    img = bg_icon(s, VIOLET_HI, VIOLET_LO)
    back = tile(int(s*0.5), (TILE[0], TILE[1], TILE[2]), "A", (31, 130, 150)).rotate(14, expand=True, resample=Image.BICUBIC)
    front = tile(int(s*0.52), WHITE, "K", (90, 60, 200)).rotate(-10, expand=True, resample=Image.BICUBIC)
    img.alpha_composite(back, (int(s*0.46-back.width//2), (s-back.height)//2))
    img.alpha_composite(front, (int(s*0.40-front.width//2)+int(s*0.06), (s-front.height)//2))
    return img


def concept_cross(s):
    """3 — Crossword cells: 3 squares, accent 'K' cell + faint letters."""
    img = bg_icon(s, INK, INK2)
    d = ImageDraw.Draw(img)
    cell = int(s*0.2)
    gap = int(s*0.045)
    total = cell*3 + gap*2
    ox = (s-total)//2
    oy = (s-total)//2
    letters = [["", "E", ""], ["K", "E", "L"], ["", "İ", ""]]
    accents = {(1, 0)}
    for r in range(3):
        for c in range(3):
            x = ox + c*(cell+gap)
            y = oy + r*(cell+gap)
            ch = letters[r][c]
            if not ch:
                d.rounded_rectangle([x, y, x+cell, y+cell], int(cell*0.18),
                                    fill=(255, 255, 255, 16))
                continue
            if (c, r) in accents or ch == "K":
                grad = rounded(vgrad(cell, cell, VIOLET_HI, VIOLET_LO), int(cell*0.18))
                img.alpha_composite(grad, (x, y))
                dd = ImageDraw.Draw(img)
                ctext(dd, (x+cell/2, y+cell/2), ch, font(int(cell*0.62)), WHITE)
            else:
                d.rounded_rectangle([x, y, x+cell, y+cell], int(cell*0.18), fill=(255, 255, 255, 28))
                ctext(d, (x+cell/2, y+cell/2), ch, font(int(cell*0.55)), (150, 160, 190))
    return img


def concept_mono(s):
    """4 — Bold 'KA' monogram, violet bg."""
    img = bg_icon(s, VIOLET_HI, VIOLET_LO)
    d = ImageDraw.Draw(img)
    ctext(d, (s*0.5, s*0.5), "KA", font(int(s*0.46)), WHITE)
    return img


CONCEPTS = [
    ("1 · Kelime tasi", concept_tile),
    ("2 · Yelpaze tas", concept_fan),
    ("3 · Bulmaca", concept_cross),
    ("4 · KA monogram", concept_mono),
]


def export_individual():
    cand = os.path.join(OUT, "logo_candidates")
    os.makedirs(cand, exist_ok=True)
    names = ["01_tile", "02_fan", "03_cross", "04_mono"]
    for (label, fn), nm in zip(CONCEPTS, names):
        fn(512).convert("RGB").save(os.path.join(cand, nm + ".png"))
    print("wrote 512 candidates ->", cand)


def main():
    export_individual()
    icon = 360
    pad = 40
    label_h = 50
    cols = 2
    rows = 2
    cw = icon + pad
    ch = icon + label_h + pad
    sheet = Image.new("RGB", (cols*cw + pad, rows*ch + pad), (20, 26, 42))
    d = ImageDraw.Draw(sheet)
    for i, (label, fn) in enumerate(CONCEPTS):
        r, c = divmod(i, cols)
        x = pad + c*cw
        y = pad + r*ch
        sheet.paste(fn(icon).convert("RGB"), (x, y))
        d.text((x + icon/2, y + icon + 24), label, font=font(26), fill=(220, 226, 240), anchor="mm")
    sheet.save(os.path.join(OUT, "logo_options.png"))
    print("wrote", os.path.join(OUT, "logo_options.png"))


if __name__ == "__main__":
    main()
