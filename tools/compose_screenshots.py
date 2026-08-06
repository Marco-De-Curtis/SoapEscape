#!/usr/bin/env python3
"""Compose App Store screenshots: real game frames plus a caption band.

The raw captures from _shots.gd are the unmodified running game. This adds a
headline above each one and sets it on the brand background, which is what
polished listings do and what makes shots 1 and 2 work in search results.

The game frame itself is never retouched, only scaled and rounded, so the
listing still shows exactly what the app looks like.

    python3 tools/compose_screenshots.py <raw_dir> <out_dir>

Output: 1320 x 2868 sRGB PNG, no alpha, which is what App Store Connect wants
for the 6.9" iPhone class.
"""

import sys
import pathlib
from PIL import Image, ImageDraw, ImageFont, ImageFilter

W, H = 1320, 2868

# Brand palette, from designs/design-tokens.md
PINK = (214, 51, 132)
PURPLE = (124, 58, 237)
BG_TOP = (253, 242, 248)      # #fdf2f8
BG_BOTTOM = (243, 232, 255)   # #f3e8ff

FREDOKA = "fonts/Fredoka-VariableFont.ttf.ttf"
NUNITO = "fonts/Nunito-VariableFont_wght.ttf"

# Frame geometry. The caption needs roughly the top sixth; the rest is the
# game at its true aspect ratio.
FRAME_W = 1104
FRAME_H = round(FRAME_W * H / W)      # 2399, aspect preserved
FRAME_X = (W - FRAME_W) // 2
FRAME_Y = 420
CORNER = 52

CAPTIONS = {
    "01_steer":  ("One thumb.\nTwo directions.", "That is the entire control scheme."),
    "02_shield": ("One shield.\nOne free mistake.", "Spend it carefully. They are rare."),
    "03_win":    ("Three stars means you\nbarely lost a crumb.", "Good luck with that on level ten."),
    "04_map":    ("Ten levels.\nThey get meaner.", "Narrower, faster, hungrier."),
    "05_home":   ("No ads. No purchases.\nNo internet.", "Just a bar of soap and some bad luck."),
    "06_fail":   ("Or melt trying.", "The drain is not going anywhere."),
}

ORDER = ["01_steer", "02_shield", "03_win", "04_map", "05_home", "06_fail"]


def font(path, size, variation):
    f = ImageFont.truetype(path, size)
    f.set_variation_by_name(variation)
    return f


def background():
    """Vertical brand gradient. One palette across all six so the listing reads
    as a set rather than six unrelated pictures."""
    bg = Image.new("RGB", (1, H))
    px = bg.load()
    for y in range(H):
        t = y / (H - 1)
        px[0, y] = tuple(round(a + (b - a) * t) for a, b in zip(BG_TOP, BG_BOTTOM))
    return bg.resize((W, H), Image.BILINEAR)


def rounded_mask(size, radius):
    m = Image.new("L", (size[0] * 2, size[1] * 2), 0)
    ImageDraw.Draw(m).rounded_rectangle(
        [0, 0, size[0] * 2 - 1, size[1] * 2 - 1], radius=radius * 2, fill=255)
    return m.resize(size, Image.LANCZOS)


def draw_centred(draw, text, f, y, fill, line_gap=14):
    """Centre each line horizontally, return the y below the block."""
    for line in text.split("\n"):
        bbox = draw.textbbox((0, 0), line, font=f)
        w = bbox[2] - bbox[0]
        draw.text(((W - w) // 2 - bbox[0], y - bbox[1]), line, font=f, fill=fill)
        y += (bbox[3] - bbox[1]) + line_gap
    return y


def compose(raw_path, headline, sub):
    canvas = background()
    draw = ImageDraw.Draw(canvas)

    head_f = font(FREDOKA, 84, "SemiBold")
    sub_f = font(NUNITO, 40, "SemiBold")

    y = draw_centred(draw, headline, head_f, 132, PINK, line_gap=26)
    draw_centred(draw, sub, sub_f, y + 26, PURPLE)

    shot = Image.open(raw_path).convert("RGB").resize((FRAME_W, FRAME_H), Image.LANCZOS)
    mask = rounded_mask((FRAME_W, FRAME_H), CORNER)

    # Soft drop shadow so the frame lifts off the background.
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = Image.new("RGBA", (FRAME_W, FRAME_H), (124, 58, 237, 60))
    shadow.paste(sd, (FRAME_X, FRAME_Y + 18), mask)
    shadow = shadow.filter(ImageFilter.GaussianBlur(26))
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow).convert("RGB")

    canvas.paste(shot, (FRAME_X, FRAME_Y), mask)
    return canvas


def main():
    raw_dir = pathlib.Path(sys.argv[1])
    out_dir = pathlib.Path(sys.argv[2])
    out_dir.mkdir(parents=True, exist_ok=True)

    for i, key in enumerate(ORDER, start=1):
        src = raw_dir / f"{key}.png"
        if not src.exists():
            print(f"  missing {src}, skipped")
            continue
        headline, sub = CAPTIONS[key]
        img = compose(src, headline, sub)
        dst = out_dir / f"{i}_{key.split('_', 1)[1]}.png"
        img.save(dst, "PNG", optimize=True)
        print(f"  {dst.name}: {img.size[0]}x{img.size[1]} {img.mode}")


if __name__ == "__main__":
    main()
