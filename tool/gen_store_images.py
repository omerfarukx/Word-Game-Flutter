"""Generates Google Play store assets from raw app screenshots.

Inputs : store/raw/01.png .. 08.png  (real 1080x2400 app screenshots)
Outputs: store/screenshots/01.png .. 08.png  (1080x1920 marketing images)
         store/assets/feature_graphic.png     (1024x500)
         store/assets/icon_512.png            (512x512)

Each marketing image = brand gradient + violet glow + a Turkish headline +
the screenshot inside a rounded, glowing phone frame. Run:  python tool/gen_store_images.py
Requires Pillow.
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, "store", "raw")
OUT_SHOTS = os.path.join(ROOT, "store", "screenshots")
OUT_ASSETS = os.path.join(ROOT, "store", "assets")
os.makedirs(OUT_SHOTS, exist_ok=True)
os.makedirs(OUT_ASSETS, exist_ok=True)

W, H = 1080, 1920
BG_TOP, BG_BOT = (13, 19, 34), (8, 12, 23)
VIOLET = (139, 92, 246)
VIOLET_HI = (165, 133, 255)
VIOLET_LO = (109, 84, 240)
VIOLET_LT = (183, 164, 251)
WHITE = (236, 240, 250)

BOLD = ["C:/Windows/Fonts/segoeuib.ttf", "C:/Windows/Fonts/arialbd.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"]
REG = ["C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf",
       "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"]


def font(opts, size):
    for p in opts:
        try:
            return ImageFont.truetype(p, size)
        except Exception:
            pass
    return ImageFont.load_default()


def vgradient(w, h, top, bot):
    col = Image.new("RGB", (1, h))
    for y in range(h):
        t = y / (h - 1)
        col.putpixel((0, y), tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)))
    return col.resize((w, h))


def brand_bg(w, h, glow_xy=None, glow_r=420, glow_a=95):
    bg = vgradient(w, h, BG_TOP, BG_BOT).convert("RGBA")
    gx, gy = glow_xy or (w // 2, int(h * 0.16))
    glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse(
        [gx - glow_r, gy - glow_r, gx + glow_r, gy + glow_r],
        fill=(VIOLET[0], VIOLET[1], VIOLET[2], glow_a))
    glow = glow.filter(ImageFilter.GaussianBlur(150))
    # a teal kiss at bottom for depth
    teal = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(teal).ellipse(
        [w // 2 - 360, h - 260, w // 2 + 360, h + 360], fill=(34, 211, 238, 36))
    teal = teal.filter(ImageFilter.GaussianBlur(160))
    bg = Image.alpha_composite(bg, glow)
    bg = Image.alpha_composite(bg, teal)
    return bg


def rounded(img, rad):
    img = img.convert("RGBA")
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, img.size[0], img.size[1]], rad, fill=255)
    img.putalpha(mask)
    return img


def centered(draw, text, y, fnt, fill):
    w = draw.textlength(text, font=fnt)
    draw.text(((W - w) / 2, y), text, font=fnt, fill=fill)


# (raw file, line1, line2)
SHOTS = [
    ("01.png", "10 oyun,", "tek uygulamada"),
    ("02.png", "Karışık harflerden", "kelime kur"),
    ("03.png", "Farklı çiftleri", "yakala"),
    ("04.png", "Eş & zıt anlam,", "kelime ailesi"),
    ("05.png", "Hayatta Kalma:", "canınla yarış"),
    ("06.png", "Rekor kır,", "rozet topla"),
    ("07.png", "Kombolarla", "puanı patlat"),
    ("08.png", "Kelimelerle", "zihnini çalıştır"),
]


def make_shot(raw, l1, l2, out):
    bg = brand_bg(W, H)
    d = ImageDraw.Draw(bg)
    fb = font(BOLD, 76)
    centered(d, l1, 132, fb, WHITE)
    centered(d, l2, 224, fb, VIOLET_LT)

    sc = Image.open(os.path.join(RAW, raw)).convert("RGB")
    pw = 600
    ph = int(pw * sc.height / sc.width)
    sc = sc.resize((pw, ph))
    px, py = (W - pw) // 2, 392

    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(glow).rounded_rectangle(
        [px - 14, py - 14, px + pw + 14, py + ph + 14], 60,
        fill=(VIOLET[0], VIOLET[1], VIOLET[2], 130))
    glow = glow.filter(ImageFilter.GaussianBlur(46))
    bg = Image.alpha_composite(bg, glow)

    sh = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle(
        [px, py + 22, px + pw, py + ph + 22], 50, fill=(0, 0, 0, 170))
    sh = sh.filter(ImageFilter.GaussianBlur(34))
    bg = Image.alpha_composite(bg, sh)

    bg.alpha_composite(rounded(sc, 44), (px, py))
    ImageDraw.Draw(bg).rounded_rectangle(
        [px, py, px + pw, py + ph], 44, outline=(60, 74, 110, 255), width=4)
    bg.convert("RGB").save(out, quality=95)


def mark(size):
    """The violet rounded-square 'K' app mark."""
    img = vgradient(size, size, VIOLET_HI, VIOLET_LO).convert("RGBA")
    img = rounded(img, int(size * 0.28))
    d = ImageDraw.Draw(img)
    f = font(BOLD, int(size * 0.62))
    t = "K"
    w = d.textlength(t, font=f)
    bbox = f.getbbox(t)
    th = bbox[3] - bbox[1]
    d.text(((size - w) / 2, (size - th) / 2 - bbox[1]), t, font=f, fill=WHITE)
    return img


def make_icon():
    s = 512
    canvas = Image.new("RGBA", (s, s), (8, 12, 23, 255))
    canvas.alpha_composite(mark(s), (0, 0))
    canvas.convert("RGB").save(os.path.join(OUT_ASSETS, "icon_512.png"))


def make_feature():
    fw, fh = 1024, 500
    bg = brand_bg(fw, fh, glow_xy=(250, 250), glow_r=320, glow_a=110)
    m = mark(190)
    bg.alpha_composite(m, (90, (fh - 190) // 2))
    d = ImageDraw.Draw(bg)
    d.text((330, 188), "Kelime Atölyesi", font=font(BOLD, 76), fill=WHITE)
    d.text((332, 280), "Kelimelerle zihnini çalıştır", font=font(REG, 36), fill=VIOLET_LT)
    bg.convert("RGB").save(os.path.join(OUT_ASSETS, "feature_graphic.png"))


def main():
    for i, (raw, l1, l2) in enumerate(SHOTS, 1):
        out = os.path.join(OUT_SHOTS, f"{i:02d}.png")
        make_shot(raw, l1, l2, out)
        print("screenshot", out)
    make_icon()
    make_feature()
    print("icon + feature graphic done")


if __name__ == "__main__":
    main()
