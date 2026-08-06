#!/usr/bin/env python3
"""Render the App Store icon from the game's own art definitions.

This is a faithful port of LogoArt.paint_icon() plus the SoapArt geometry it
calls, so the icon and the in-game character cannot drift apart. If you change
SoapArt.gd or LogoArt.paint_icon(), re-run this and commit the result.

    pip install Pillow
    python3 tools/generate_app_icon.py

Output: SoapEscape_AppIcon_1024.png, 1024x1024 RGB with no alpha channel,
square corners. Apple applies the rounded mask itself and rejects icons that
carry an alpha channel, so both of those are deliberate.

Rendered at 4x and downsampled with Lanczos, because Godot antialiases polygon
edges at draw time and Pillow does not.
"""

import math
from PIL import Image, ImageDraw

SS = 4                      # supersampling factor
SIZE = 1024
CANVAS = SIZE * SS
OUT = "SoapEscape_AppIcon_1024.png"

# ── Palette, from LogoArt.gd and SoapArt.gd ────────────────────────────────
SKY = (224, 242, 254)       # #e0f2fe
WATER = (125, 211, 252)     # #7dd3fc
OUTLINE = (26, 26, 46)      # #1a1a2e
FILL_CALM = (196, 181, 253) # #c4b5fd
SHEEN = (255, 255, 255, 87)   # white 0.34
SHINE = (255, 255, 255, 230)  # white 0.90
SPARK = (255, 255, 255, 191)  # white 0.75
CHEEK = (242, 143, 179, 184)  # (0.95,0.56,0.70) at 0.72
BAND = (255, 255, 255, 41)    # white 0.16
BUBBLE = (255, 255, 255, 191) # white 0.75

# ── SoapArt geometry ──────────────────────────────────────────────────────
BASE_WIDTH = 36.0
BASE_HEIGHT = 20.0


def rounded_rect(hw, hh, r, steps=8):
    r = min(r, min(hw, hh) * 0.99)
    ccx = (-hw + r, hw - r, hw - r, -hw + r)
    ccy = (-hh + r, -hh + r, hh - r, hh - r)
    ca0 = (math.pi, -math.pi * 0.5, 0.0, math.pi * 0.5)
    pts = []
    for i in range(4):
        for j in range(steps):
            a = ca0[i] + math.pi * 0.5 * j / (steps - 1)
            pts.append((ccx[i] + math.cos(a) * r, ccy[i] + math.sin(a) * r))
    return pts


def circle(cx, cy, radius, steps):
    return [(cx + math.cos(math.tau * i / steps) * radius,
             cy + math.sin(math.tau * i / steps) * radius) for i in range(steps)]


def quad(p0, p1, p2, n=9):
    pts = []
    for i in range(n):
        t = i / (n - 1)
        u = 1.0 - t
        pts.append((p0[0] * u * u + p1[0] * 2 * u * t + p2[0] * t * t,
                    p0[1] * u * u + p1[1] * 2 * u * t + p2[1] * t * t))
    return pts


def offset(pts, dx, dy):
    return [(x + dx, y + dy) for x, y in pts]


def scaled(pts):
    return [(x * SS, y * SS) for x, y in pts]


def blend_polygon(img, pts, colour):
    """Draw a translucent polygon with correct alpha blending.

    ImageDraw.Draw(img, "RGBA") does not reliably blend polygon fills, so a
    16%-white band came out pure white. Compositing a scratch layer is slower
    but actually respects the alpha.
    """
    if colour[3] == 255:
        ImageDraw.Draw(img).polygon(pts, fill=colour)
        return
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).polygon(pts, fill=colour)
    img.alpha_composite(layer)


def blend_ellipse(img, box, colour, width):
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).ellipse(box, outline=colour, width=width)
    img.alpha_composite(layer)


def thick_polyline(img, pts, width, colour):
    """Round joints and caps, matching Godot's antialiased draw_polyline
    closely enough at icon resolution."""
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.line(scaled(pts), fill=colour, width=int(width * SS), joint="curve")
    r = width * SS / 2.0
    for x, y in (pts[0], pts[-1]):
        d.ellipse([x * SS - r, y * SS - r, x * SS + r, y * SS + r], fill=colour)
    img.alpha_composite(layer)


def paint_soap(img, cx, cy, scale):
    """Port of SoapArt.paint(..., CALM)."""
    w, h = BASE_WIDTH * scale, BASE_HEIGHT * scale
    hw, hh = w * 0.5, h * 0.5
    body_r = min(hw, hh) * 0.80

    # Body: dark outline polygon, inset lavender fill, specular streak
    blend_polygon(img, scaled(offset(rounded_rect(hw, hh, body_r), cx, cy)), OUTLINE + (255,))
    blend_polygon(img, scaled(offset(rounded_rect(hw * 0.91, hh * 0.90, body_r * 0.88), cx, cy)),
                  FILL_CALM + (255,))
    streak = rounded_rect(hw * 0.50, max(0.6, hh * 0.11), max(0.6, hh * 0.11))
    blend_polygon(img, scaled(offset(streak, cx - hw * 0.12, cy - hh * 0.60)), SHEEN)

    # Cheeks sit behind the eyes
    ccx, ccy = w * 0.335, h * 0.24
    cr = w * 0.098
    for sx in (-1, 1):
        blend_polygon(img, scaled(offset(circle(sx * ccx, ccy, cr, 10), cx, cy)), CHEEK)

    # Eyes, with the two kawaii highlights
    eox, eoy = w * 0.255, -h * 0.09
    er = w * 0.128
    for sx in (-1, 1):
        ex, ey = sx * eox, eoy
        blend_polygon(img, scaled(offset(circle(ex, ey, er, 16), cx, cy)), OUTLINE + (255,))
        so = er * 0.34
        blend_polygon(img, scaled(offset(circle(ex + so, ey - so, er * 0.38, 10), cx, cy)), SHINE)
        blend_polygon(img, scaled(offset(circle(ex - er * 0.36, ey + er * 0.40, er * 0.17, 8),
                                         cx, cy)), SPARK)

    # Smile
    my, hx = h * 0.22, w * 0.125
    smile = quad((-hx, my), (0.0, my + h * 0.24), (hx, my))
    thick_polyline(img, offset(smile, cx, cy), max(0.6, w * 0.060), OUTLINE + (255,))


# ── Composition ───────────────────────────────────────────────────────────
# Mirrored in LogoArt.paint_icon(). Keep the two in step.
#
# The character carries the whole icon, so it is scaled to fill roughly 70% of
# the canvas width and straddles the waterline, which reads as "floating in the
# bath". The original 15.6 left the top third of the frame empty sky and the
# soap unreadably small once Apple scales the icon to ~60px on a home screen.
SOAP_SCALE = 20.0
SOAP_CENTRE = (512.0, 470.0)
WATER_LINE = 0.635


def main():
    img = Image.new("RGBA", (CANVAS, CANVAS), SKY + (255,))

    # Water fills the lower third behind a wavy surface, so the scene reads as
    # "soap in a bath" without needing a single prop.
    surface = SIZE * WATER_LINE
    wave = [(SIZE * (i / 64), surface + math.sin((i / 64) * math.pi * 2.6) * 26.0)
            for i in range(65)]
    blend_polygon(img, scaled(wave + [(SIZE, SIZE), (0, SIZE)]), WATER + (255,))

    # Lighter band just under the surface gives the water some depth
    band = wave + [(x, y + 62.0) for x, y in reversed(wave)]
    blend_polygon(img, scaled(band), BAND)

    # Bubbles: few and large, so they survive being scaled to a home screen
    for (bx, by), br in (((150, 820), 46.0), ((296, 928), 30.0),
                         ((884, 852), 38.0), ((742, 952), 24.0)):
        blend_ellipse(img, [(bx - br) * SS, (by - br) * SS, (bx + br) * SS, (by + br) * SS],
                      BUBBLE, int(7.0 * SS))

    # The character, big enough to be the whole story
    paint_soap(img, SOAP_CENTRE[0], SOAP_CENTRE[1], SOAP_SCALE)

    img = img.resize((SIZE, SIZE), Image.LANCZOS).convert("RGB")
    img.save(OUT, "PNG", optimize=True)
    print(f"wrote {OUT}: {img.size[0]}x{img.size[1]} {img.mode} (no alpha channel)")


if __name__ == "__main__":
    main()
