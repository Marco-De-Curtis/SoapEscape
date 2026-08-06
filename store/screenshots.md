# Screenshots — Soap Escape

## Specification

| Requirement | Value |
|---|---|
| Device class needed | iPhone 6.9" only |
| Dimensions | **1320 x 2868** portrait (preferred) |
| Also accepted | 1290 x 2796, or 1260 x 2736 |
| Format | PNG or JPEG, sRGB |
| Transparency | Not allowed. Flatten any alpha before uploading |
| Count | 3 minimum, 10 maximum |

Apple downscales the 6.9" set automatically to populate every smaller iPhone
listing, so this is the only size you need. The game is iPhone only
(`targeted_device_family=1`), so no iPad set is required.

App Store Connect rejects files that are off by a single pixel. Check dimensions
before uploading, not after.

The first two screenshots are the ones that appear in search results. Put your
strongest frames there.

---

## The set

Generated, not hand-made. `_shots.gd` drives the real game into each state and
captures the framebuffer; `tools/compose_screenshots.py` adds the caption band.
To regenerate after a game change, see "How to capture" below.

Committed in `store/screenshots/`:
- `final/` — captioned, upload these
- `raw/` — the untouched captures, if you want a plain set instead

| Slot | File | Caption | Why it is here |
|---|---|---|---|
| 1 | `1_steer.png` | You are the soap. Do not melt. | Answers "what is this?" Slot 1 must not be about controls |
| 2 | `2_win.png` | Three stars. One perfect run. | Highest-contrast frame in the set, the only one that reads at search-thumbnail size. Deliberately placed second, since slots 1-2 are all that show in search results |
| 3 | `3_map.png` | Ten levels. They get meaner. | Proof of content volume |
| 4 | `4_nearmiss.png` | Ducks. Grates. Sponges. Combs. | Obstacle variety plus the finish line |
| 5 | `5_home.png` | No ads. No purchases. No accounts. | The pitch, and the last objection answered |

The fail screen was captured and then cut. A red error modal with two greyed-out
rows is indistinguishable from a crash dialog at thumbnail size. It stays in
`raw/06_fail.png` if you disagree.

## Known limitation

The soap is about 8% of the frame width and the obstacles are physically larger
than it, so the gameplay shots will never punch as hard as the win screen. Two
game-side changes would fix it, both of which change the shipping product and
so are decisions rather than tasks:

1. **Pull the camera in.** The play channel is only ~56% of screen width; the
   rest is decorative tiling. Zooming ~1.5x would take the soap to ~12% of the
   frame. It also reduces how far ahead the player can see, which makes the
   game harder, so it is a difficulty change as much as a visual one.
2. **Raise the soap's contrast.** `Soap.gd:285` lerps the body fill toward light
   blue while inside a wet zone, dropping it to roughly 1.2:1 against the blue
   tint. The soap camouflages exactly when the player most needs to see it.
   The screenshots dodge this by staying on the dry lane, but the readability
   problem is real during play.

## How to capture

The committed set was produced on Linux with Xvfb:

```
godot --path . --resolution 1320x2868 --rendering-driver opengl3 \
      --audio-driver Dummy _shots.tscn
python3 tools/compose_screenshots.py <captures> store/screenshots/final
```

Captures land in the Godot user data directory. On a machine with a display,
drop the `xvfb-run` wrapper.

