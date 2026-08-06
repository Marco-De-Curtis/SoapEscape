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

## Shot list

Ordered as they should appear in the listing.

| # | Screen | What to capture | Suggested caption overlay |
|---|---|---|---|
| 1 | In-game, Level 5 | Soap mid-lean between two obstacles, wet zone visible ahead with the "WET ZONE AHEAD" pill | Lean left. Lean right. Try not to melt. |
| 2 | In-game, low health | Soap at panicked orange or critical red, size meter clearly low, obstacle close | Your face is the health bar |
| 3 | Win screen | Three stars awarded, victory face with star eyes | Three stars means you barely lost a crumb |
| 4 | Level map | Several levels complete with stars, later ones locked | Ten levels. They get meaner |
| 5 | Home screen | Logo with the mascot, star progress line | (no caption, let the logo carry it) |
| 6 | Fail screen | The "dissolved" variant | Or don't |

Six is a good number. Do not pad to ten with near-duplicates.

Captions are optional. If you add them, keep them in the game's own fonts
(Fredoka for headlines, Nunito for body) and the brand pink `#d63384` on the
off-white `#fdf2f8`, so the store page and the game read as one thing.

---

## How to capture

### Option A: on device (best quality, needs the app installed)

Once you have a TestFlight build, take screenshots on an iPhone 17 Pro Max, 16
Pro Max or 15 Pro Max. Those produce 1320 x 2868 natively with no scaling and no
post-processing. This is the least fiddly route and the one to use if you have
access to any of those handsets.

Trim the status bar only if it shows something distracting. Apple permits the
real status bar.

### Option B: iOS Simulator (needs a Mac or a cloud Mac session)

Boot the iPhone 17 Pro Max simulator and use `Device > Screenshot`, or:

```
xcrun simctl io booted screenshot --type=png shot1.png
```

Output is already 1320 x 2868.

### Option C: desktop build (no Mac needed)

The project's stretch mode is `canvas_items` with `expand`, so the UI reflows
correctly at any resolution rather than letterboxing. That means the Windows or
Linux export can render true 1320 x 2868 frames.

1. Export the desktop preset.
2. Launch with the target resolution forced:

   ```
   SoapEscape.exe --resolution 1320x2868
   ```

   The window will be taller than your monitor. That is fine. The framebuffer is
   the full size and that is what gets captured.

3. Capture with the helper below rather than an OS screenshot tool, because an OS
   tool only captures the visible portion of an oversized window.

**Helper script** — `store/_screenshot_helper.gd` in this repo saves a full
framebuffer PNG to the user data folder when you press F12.

To use it, temporarily add it as an autoload in `project.godot`:

```
[autoload]
ScreenshotHelper="*res://store/_screenshot_helper.gd"
```

Play to the frame you want, press F12, then find the PNG in the Godot user data
directory (`%APPDATA%\Godot\app_userdata\Soap Escape\` on Windows).

**Remove the autoload line before doing an iOS release build.** The file is named
with a leading underscore so the export preset's `_*.gd` exclude filter drops it
from the package, which means an autoload pointing at it would fail at runtime in
a shipped build.

The one caveat with this route: desktop rendering is not pixel-identical to iOS
Metal rendering. For this game, which draws everything with flat-coloured
polygons and no shaders, the difference is not visible. Verify on device once you
have TestFlight, and reshoot if anything looks off.

---

## Before uploading

- [ ] Every file is exactly 1320 x 2868
- [ ] No alpha channel (`sips -s format png` or any flattening export)
- [ ] No placeholder or debug text visible
- [ ] Star counts and level states look like real progress, not an empty save
- [ ] Ordered so shots 1 and 2 are the strongest
