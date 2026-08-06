# Screenshots — Soap Escape

## Specification

| Requirement | Value |
|---|---|
| Device class | Pick the size selector in App Store Connect to match the files |
| 6.9" iPhone | **1320 x 2868** — `store/screenshots/final/` |
| 6.5" iPhone | **1284 x 2778** — `store/screenshots/final_65/` |
| Also accepted at 6.9" | 1290 x 2796, or 1260 x 2736 |
| Also accepted at 6.5" | 1242 x 2688 |
| Format | PNG or JPEG, sRGB |
| Transparency | Not allowed. Flatten any alpha before uploading |
| Count | 1 minimum, 10 maximum (Apple requires at least one per supported device type) |

Apple downscales the 6.9" set automatically to populate every smaller iPhone
listing, so 6.9" alone is normally enough.

**If App Store Connect rejects the dimensions**, you are on the wrong device tab.
The upload area has a size selector above it, and each class validates exactly:
drop a 1320x2868 file into the 6.5" slot and it refuses. Either switch the
selector to iPhone 6.9" Display, or upload `final_65/` instead. Both sets are
committed because the two classes are different aspect ratios (0.4603 against
0.4622), so one cannot simply be resized into the other without distorting the
art. The game is iPhone only
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

App previews are the other thing that upload box accepts. They are 15-30 second
videos, up to three, and Apple states they are optional. Skipped for v1.0: they
must be real device screen recordings, Apple is strict about their dimensions
and frame rate, and they are a common source of metadata rejections for
something that is not required.

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

