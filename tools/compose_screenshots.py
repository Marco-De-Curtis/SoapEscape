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

# Frame geometry. Widened from 1104 to 1224 (48px margins instead of 108):
# for a game whose whole legibility problem is scale, giving away 16% of
# linear size to decorative margin is a bad trade.
FRAME_W = 1224
FRAME_X = (W - FRAME_W) // 2
FRAME_Y = 560                 # band raised from 420 to fit 2 headline lines + sub
FRAME_MAX_H = H - FRAME_Y - 48
CORNER = 56

# The game draws its own simulated Dynamic Island: a black pill at the top of
# every scene, inherited from the HTML design mockups. On a real iPhone the
# hardware island already occupies that space, so it is redundant there and
# it is dead pixels here. Cropped out of every capture, stopping short of the
# HUD bar at y=190.
CROP_TOP = 176

# Slot 1 must answer "what is this?", not "how do I control it?" Controls are
# a later concern. Slot 2 is the win screen because it is the highest-contrast
# frame in the set and the only one that reads at search-thumbnail size.
CAPTIONS = {
    "01_steer":    ("You are the soap.\nDo not melt.",
                    "Lean left, lean right, stay in one piece."),
    "03_win":      ("Three stars.\nOne perfect run.",
                    "Cross the line with 70% of yourself left."),
    "04_map":      ("Ten levels.\nThey get meaner.",
                    "Narrower, faster, hungrier."),
    "02_nearmiss": ("Ducks. Grates.\nSponges. Combs.",
                    "Everything in this bathroom wants a piece."),
    "05_home":     ("No ads. No purchases.\nNo accounts.",
                    "Works on a plane. Collects nothing."),
}

# The fail screen is deliberately absent. A red error modal with two greyed-out
# rows is indistinguishable from a crash dialog at thumbnail size.
ORDER = ["01_steer", "03_win", "04_map", "02_nearmiss", "05_home"]


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


def trim(im):
    """Drop the simulated Dynamic Island, then any flat dead space at the
    bottom. The win screen wasted a third of its height on empty pink below
    the buttons, shrinking everything above it for nothing."""
    im = im.crop((0, CROP_TOP, im.width, im.height))
    px = im.load()
    last = im.height - 1
    for y in range(im.height - 1, -1, -1):
        ref = px[4, y]
        if any(sum(abs(a - b) for a, b in zip(px[x, y], ref)) > 24
               for x in range(0, im.width, 7)):
            last = y
            break
    bottom = min(im.height, last + 70)
    return im.crop((0, 0, im.width, bottom))


def fit(size):
    """Largest frame that respects both the width and the height budget."""
    w, h = size
    fw = FRAME_W
    fh = round(fw * h / w)
    if fh > FRAME_MAX_H:
        fh = FRAME_MAX_H
        fw = round(fh * w / h)
    return fw, fh


def compose(raw_path, headline, sub):
    canvas = background()
    draw = ImageDraw.Draw(canvas)

    head_f = font(FREDOKA, 84, "SemiBold")
    sub_f = font(NUNITO, 52, "SemiBold")

    y = draw_centred(draw, headline, head_f, 150, PINK, line_gap=28)
    draw_centred(draw, sub, sub_f, y + 34, PURPLE)

    shot = trim(Image.open(raw_path).convert("RGB"))
    fw, fh = fit(shot.size)
    fx = (W - fw) // 2
    shot = shot.resize((fw, fh), Image.LANCZOS)
    mask = rounded_mask((fw, fh), CORNER)

    # Soft drop shadow so the frame lifts off the background.
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = Image.new("RGBA", (fw, fh), (124, 58, 237, 60))
    shadow.paste(sd, (fx, FRAME_Y + 18), mask)
    shadow = shadow.filter(ImageFilter.GaussianBlur(26))
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow).convert("RGB")

    canvas.paste(shot, (fx, FRAME_Y), mask)
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
