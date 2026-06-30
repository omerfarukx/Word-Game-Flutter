"""Refined 'crossword' logo for Kelime Atölyesi — premium tiles, glow hero cell.
Outputs store/assets/logo_candidates/cross_A/B/C.png (512) + cross_sheet.png.
Run: python tool/gen_logo_cross.py
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "store", "assets", "logo_candidates")
os.makedirs(OUT, exist_ok=True)

VIOLET_HI, VIOLET_LO = (171, 140, 255), (109, 84, 240)
CYAN_HI, CYAN_LO = (94, 232, 247), (31, 168, 214)
INK_TOP, INK_BOT = (16, 22, 38), (7, 10, 20)
WHITE_TOP, WHITE_BOT = (255, 255, 255), (226, 223, 236)
LETTER_INK = (47, 38, 86)

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


def soft_shadow(size, box, rad, blur, alpha):
    sh = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle(box, rad, fill=(0, 0, 0, alpha))
    return sh.filter(ImageFilter.GaussianBlur(blur))


def glow(size, box, rad, blur, color, alpha):
    g = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(g).rounded_rectangle(box, rad, fill=(color[0], color[1], color[2], alpha))
    return g.filter(ImageFilter.GaussianBlur(blur))


def tile_white(cell, rad, letter, f):
    """A premium white letter tile (gradient gives the top-lit depth)."""
    t = rounded(vgrad(cell, cell, WHITE_TOP, WHITE_BOT), rad)
    if letter:
        ImageDraw.Draw(t).text((cell/2, cell/2 + cell*0.02), letter, font=f,
                               fill=LETTER_INK, anchor="mm")
    return t


def tile_accent(cell, rad, letter, f, top, bot):
    t = rounded(vgrad(cell, cell, top, bot), rad)
    if letter:
        ImageDraw.Draw(t).text((cell/2, cell/2 + cell*0.02), letter, font=f,
                               fill=(255, 255, 255), anchor="mm")
    return t


def cross_icon(s, variant="A"):
    bg = rounded(vgrad(s, s, INK_TOP, INK_BOT), int(s*0.235))
    # central violet bloom
    bg = Image.alpha_composite(bg, glow(s, [s*0.2, s*0.2, s*0.8, s*0.8], int(s*0.3),
                                        int(s*0.16), VIOLET_HI, 70))

    layout = [["", "E", ""], ["K", "E", "L"], ["", "İ", ""]]
    cell = int(s * 0.235)
    gap = int(s * 0.045)
    total = cell * 3 + gap * 2
    ox = (s - total) // 2
    oy = (s - total) // 2
    rad = int(cell * 0.26)
    f = font(int(cell * 0.6))

    for r in range(3):
        for c in range(3):
            x = ox + c * (cell + gap)
            y = oy + r * (cell + gap)
            ch = layout[r][c]
            hero = (ch == "K")
            accent2 = (variant == "B" and r == 0 and c == 1)  # top E cyan

            if not ch:
                if variant == "C":
                    # filled dark "blank" squares (crossword feel)
                    d = ImageDraw.Draw(bg)
                    d.rounded_rectangle([x, y, x+cell, y+cell], rad, fill=(255, 255, 255, 14))
                else:
                    d = ImageDraw.Draw(bg)
                    d.rounded_rectangle([x, y, x+cell, y+cell], rad,
                                        outline=(255, 255, 255, 40), width=max(2, s//220))
                continue

            # shadow under tile
            bg.alpha_composite(soft_shadow(s, [x, y+int(cell*0.06), x+cell, y+cell+int(cell*0.06)],
                                           rad, int(cell*0.10), 110))
            if hero:
                bg.alpha_composite(glow(s, [x-int(cell*0.12), y-int(cell*0.12),
                                            x+cell+int(cell*0.12), y+cell+int(cell*0.12)],
                                        rad, int(cell*0.22), VIOLET_HI, 150))
                bg.alpha_composite(tile_accent(cell, rad, ch, f, VIOLET_HI, VIOLET_LO), (x, y))
            elif accent2:
                bg.alpha_composite(tile_accent(cell, rad, ch, f, CYAN_HI, CYAN_LO), (x, y))
            else:
                bg.alpha_composite(tile_white(cell, rad, ch, f), (x, y))
    return bg


def main():
    for v in ("A", "B", "C"):
        cross_icon(512, v).convert("RGB").save(os.path.join(OUT, f"cross_{v}.png"))
    # contact sheet
    icon = 360
    pad = 44
    labels = {"A": "A · tek mor K", "B": "B · K mor + E cyan", "C": "C · dolu-boş"}
    sheet = Image.new("RGB", (3*icon + 4*pad, icon + 2*pad + 40), (20, 26, 42))
    d = ImageDraw.Draw(sheet)
    for i, v in enumerate(("A", "B", "C")):
        x = pad + i*(icon+pad)
        sheet.paste(cross_icon(icon, v).convert("RGB"), (x, pad))
        d.text((x+icon/2, pad+icon+22), labels[v], font=font(26), fill=(220, 226, 240), anchor="mm")
    sheet.save(os.path.join(OUT, "cross_sheet.png"))
    print("wrote cross_A/B/C.png + cross_sheet.png ->", OUT)


if __name__ == "__main__":
    main()
