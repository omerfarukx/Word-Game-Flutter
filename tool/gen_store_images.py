"""Vibrant Google Play marketing graphics (reference-style) for Kelime Atölyesi.

Each 1080x1920 panel = bright violet gradient + decorative blobs/sparkles +
a BIG bold Turkish headline + colourful feature badges + the real app screen
shown in a tilted phone mockup. Plus feature graphic (1024x500) & 512 icon.

Inputs : store/raw/01..08.png  (real app screenshots)
Run    : python tool/gen_store_images.py   (needs Pillow)
"""
import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, "store", "raw")
OUT_SHOTS = os.path.join(ROOT, "store", "screenshots")
OUT_ASSETS = os.path.join(ROOT, "store", "assets")
LOGO = os.path.join(OUT_ASSETS, "logo_candidates", "cross_A.png")
os.makedirs(OUT_SHOTS, exist_ok=True)

W, H = 1080, 1920
# Bright marketing gradient (top -> bottom)
G_TOP = (138, 92, 246)     # vivid violet
G_BOT = (67, 32, 138)      # deep violet
MAGENTA = (217, 70, 239)
WHITE = (255, 255, 255)
AMBER = (251, 191, 36)
CYAN = (45, 212, 238)
INK = (40, 22, 84)

BOLD = ["C:/Windows/Fonts/segoeuib.ttf", "C:/Windows/Fonts/arialbd.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"]
XBOLD = ["C:/Windows/Fonts/seguibl.ttf", "C:/Windows/Fonts/segoeuib.ttf",
         "C:/Windows/Fonts/arialbd.ttf"]


def font(opts, size):
    for p in opts:
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
    return col.resize((w, h)).convert("RGBA")


def blob(size_wh, xy, r, color, alpha, blur):
    layer = Image.new("RGBA", size_wh, (0, 0, 0, 0))
    ImageDraw.Draw(layer).ellipse([xy[0]-r, xy[1]-r, xy[0]+r, xy[1]+r],
                                  fill=(color[0], color[1], color[2], alpha))
    return layer.filter(ImageFilter.GaussianBlur(blur))


def rounded(img, rad):
    img = img.convert("RGBA")
    m = Image.new("L", img.size, 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, img.size[0], img.size[1]], rad, fill=255)
    img.putalpha(m)
    return img


def fit_font(draw, text, opts, start, max_w):
    sz = start
    while sz > 28:
        f = font(opts, sz)
        if draw.textlength(text, font=f) <= max_w:
            return f
        sz -= 3
    return font(opts, sz)


def bg_panel():
    bg = vgrad(W, H, G_TOP, G_BOT)
    bg = Image.alpha_composite(bg, blob((W, H), (W*0.85, H*0.08), 520, MAGENTA, 120, 200))
    bg = Image.alpha_composite(bg, blob((W, H), (W*0.12, H*0.30), 420, (167, 139, 250), 90, 200))
    bg = Image.alpha_composite(bg, blob((W, H), (W*0.5, H*1.02), 620, (50, 20, 110), 150, 220))
    # sparkles
    spark = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(spark)
    pts = [(140, 360, 7), (980, 520, 6), (120, 1180, 6), (960, 1280, 8),
           (220, 1500, 5), (860, 1620, 6), (520, 250, 5)]
    for x, y, r in pts:
        sd.ellipse([x-r, y-r, x+r, y+r], fill=(255, 255, 255, 150))
    bg = Image.alpha_composite(bg, spark)
    return bg


def badge(text, fg, bg_col, fsize=34):
    f = font(BOLD, fsize)
    tw = int(ImageDraw.Draw(Image.new("RGB", (10, 10))).textlength(text, font=f))
    padx, pady = 26, 16
    w, h = tw + padx*2, fsize + pady*2
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, w, h], h//2, fill=bg_col)
    d.text((w/2, h/2), text, font=f, fill=fg, anchor="mm")
    return img


def phone(raw, target_w, tilt):
    sc = Image.open(os.path.join(RAW, raw)).convert("RGB")
    pw = target_w
    ph = int(pw * sc.height / sc.width)
    sc = sc.resize((pw, ph))
    frame = Image.new("RGBA", (pw + 24, ph + 24), (0, 0, 0, 0))
    ImageDraw.Draw(frame).rounded_rectangle([0, 0, pw+24, ph+24], 60, fill=(15, 18, 30, 255))
    frame.alpha_composite(rounded(sc, 44), (12, 12))
    frame = rounded(frame, 60)
    if tilt:
        frame = frame.rotate(tilt, expand=True, resample=Image.BICUBIC)
    return frame


# (raw, line1, line2, [(badge_text, fg, bg)], tilt)
PANELS = [
    ("01.png", "10 OYUN", "TEK UYGULAMADA",
     [("ÇEVRİMDIŞI", INK, AMBER), ("ÜCRETSİZ", WHITE, MAGENTA)], -5),
    ("02.png", "KARIŞIK HARFLERDEN", "KELİME KUR",
     [("ANAGRAM", INK, AMBER)], 5),
    ("03.png", "FARKLI ÇİFTLERİ", "YAKALA",
     [("DİKKAT & HIZ", INK, CYAN)], -5),
    ("04.png", "EŞ & ZIT ANLAM", "KELİME AİLESİ",
     [("KELİME BİLGİSİ", WHITE, MAGENTA)], 5),
    ("05.png", "SÜRE YOK,", "CANINLA YARIŞ",
     [("HAYATTA KALMA", INK, AMBER)], -5),
    ("06.png", "REKOR KIR,", "ROZET TOPLA",
     [("SEVİYE & BAŞARIM", INK, CYAN)], 5),
    ("07.png", "KOMBO YAP,", "PUANI PATLAT",
     [("JUICE!", INK, AMBER)], -5),
    ("08.png", "KELİMELERLE", "ZİHNİNİ ÇALIŞTIR",
     [("HEMEN İNDİR", INK, AMBER)], 0),
]


def make_panel(raw, l1, l2, badges, tilt, out):
    bg = bg_panel()
    d = ImageDraw.Draw(bg)
    # headline
    f1 = fit_font(d, l1, BOLD, 70, W - 150)
    f2 = fit_font(d, l2, XBOLD, 92, W - 130)
    d.text((W/2, 150), l1, font=f1, fill=(255, 255, 255, 235), anchor="mm")
    y2 = 150 + f1.size//2 + f2.size//2 + 14
    # accent underline glow behind line2
    d.text((W/2, y2), l2, font=f2, fill=AMBER, anchor="mm")

    # phone
    ph = phone(raw, 560, tilt)
    px = (W - ph.width)//2
    py = 470
    # shadow
    sh = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle([px+20, py+34, px+ph.width-20, py+ph.height-10], 60, fill=(0, 0, 0, 150))
    sh = sh.filter(ImageFilter.GaussianBlur(40))
    bg = Image.alpha_composite(bg, sh)
    bg.alpha_composite(ph, (px, py))

    # badges (bottom area)
    bx = 70
    by = H - 150
    badge_imgs = [badge(t, fg, bgc) for (t, fg, bgc) in badges]
    total = sum(b.width for b in badge_imgs) + 20*(len(badge_imgs)-1)
    bx = (W - total)//2
    for b in badge_imgs:
        bg.alpha_composite(b, (bx, by - b.height//2))
        bx += b.width + 20

    bg.convert("RGB").save(out, quality=95)


def make_feature():
    fw, fh = 1024, 500
    bg = vgrad(fw, fh, G_TOP, G_BOT)
    bg = Image.alpha_composite(bg, blob((fw, fh), (fw*0.85, fh*0.1), 320, MAGENTA, 130, 130))
    bg = Image.alpha_composite(bg, blob((fw, fh), (fw*0.1, fh*0.9), 300, (167, 139, 250), 90, 140))
    logo = rounded(Image.open(LOGO).convert("RGBA").resize((210, 210)), 60)
    bg.alpha_composite(logo, (90, (fh-210)//2))
    d = ImageDraw.Draw(bg)
    d.text((340, 178), "Kelime Atölyesi", font=font(XBOLD, 82), fill=WHITE)
    d.text((344, 284), "10 oyun · kelime & zekâ", font=font(BOLD, 38), fill=AMBER)
    bg.convert("RGB").save(os.path.join(OUT_ASSETS, "feature_graphic.png"))


def main():
    for i, (raw, l1, l2, badges, tilt) in enumerate(PANELS, 1):
        out = os.path.join(OUT_SHOTS, f"{i:02d}.png")
        make_panel(raw, l1, l2, badges, tilt, out)
        print("panel", out)
    make_feature()
    print("feature graphic done")


if __name__ == "__main__":
    main()
