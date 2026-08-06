# Soap Escape — Design Tokens (Godot Reference)

Extracted and verified against the actual rendered HTML (computed styles checked, not just source CSS). Use these values exactly. No substitutions, no "close enough" colors or fonts.

---

## Colors — Global

| Token name | Hex | Godot use |
|---|---|---|
| `color_primary_pink` | `#d63384` | Headings, primary buttons, key accents |
| `color_secondary_purple` | `#7c3aed` | Secondary text, level numbers, gradient end |
| `color_star_gold` | `#f59e0b` | Stars, celebrations, pickups |
| `color_success_green` | `#15803d` | Win state, restore pickup label |
| `color_danger_red` | `#e11d48` | Fail state, obstacle |
| `color_white` | `#ffffff` | Card backgrounds, HUD panels |
| `color_bg_app` | `#fdf2f8` | App background |
| `color_bg_lane` | `#fce7f3` | Lane / home screen bg |
| `color_outline_dark` | `#1a1a2e` | Soap black outline, logo border |

## Colors — Per Level (drive from one `LevelTheme` resource, not hardcoded)

| Level | Name | Tile bg | Accent |
|---|---|---|---|
| 1 | Primo Scivolone | `#fce7f3` | `#f9a8d4` |
| 2 | Watch the Grates | `#ede9fe` | `#c4b5fd` |
| 3 | Light Rain | `#e0f2fe` | `#7dd3fc` |
| 4 | The Drain | `#fef9c3` | `#fde047` |
| 5 | Steam Mist | `#f0fdf4` | `#86efac` |
| 6 | Current | `#fff7ed` | `#fdba74` |
| 7 | The Tunnel | `#fdf4ff` | `#e879f9` |
| 8 | Waterfall | `#ecfeff` | `#22d3ee` |
| 9 | Deep Drain | `#f0f9ff` | `#38bdf8` |
| 10 | End of the Pipe | `#fdf2f8` | `#f0abfc` |

## Typography

Two fonts only. Bundle the TTFs, do not substitute system fonts.

| Font | Weight(s) | Role |
|---|---|---|
| Fredoka One | 400 | Display, scores, level names, win/fail headlines, buttons |
| Nunito | 400, 600, 700, 800 | Body, labels, HUD, instructions |

| Element | Font | Size | Weight | Color |
|---|---|---|---|---|
| App title "Soap Escape" | Fredoka One | 52px | 400 | `#d63384` ("Soap") + `#7c3aed` ("Escape") |
| Level name on map | Nunito | 9px | 600 | `#7c3aed` |
| Level number in node | system sans | 15px | 700 | `#ffffff` |
| In-game level name | Nunito | 13px | 700 | `#d63384` |
| Score / progress % | Nunito | 13px | 700 | `#7c3aed` |
| Soap % label | Fredoka One | 13px | 400 | `#d63384` |
| Win headline | Fredoka One | 32px | 400 | `#d63384` |
| Fail headline | Fredoka One | 30px | 400 | `#e11d48` |
| Onboarding titles | Fredoka One | 26px | 400 | `#d63384` |
| Body / instructions | Nunito | 14px | 400 | `#6b7280` |
| Button labels (Fredoka) | Fredoka One | 18-22px | 400 | white |
| Button labels (Nunito) | Nunito | 17px | 700 | white |

**Large display text treatment** (logo, home title) — replicate in Godot via a Label with outline settings + drop shadow, not a filter:
- Text stroke: 1.5px white
- Text shadow: 2px 3px 0, pink at 45% opacity (`rgba(181,45,112,0.45)`)
- The "!" gets a purple shadow instead: `rgba(91,33,182,0.45)`

## Spacing & Layout

- Canvas: 390×844pt (iPhone 14 portrait) — set as your base Godot viewport/reference resolution
- Dynamic Island: 126×37px, top 12px, centered
- Top HUD bar: height 48px, starts at top 56px (below Dynamic Island)
- Bottom soap bar: height ~48px, bottom 20px
- Bottom safe area: 34px (home indicator)
- Card corner radius: 28-32px (bottom sheets), 12-16px (small cards)
- Button corner radius: pill (height / 2)

## Shadows & Borders

- Primary button glow: `0 6px 24px rgba(214,51,132,0.4)`
- HUD top bar: 2px solid bottom border, color = current level's accent
- Logo sticker: `border: 3px solid #1a1a2e`, offset shadow `5px 5px 0 #1a1a2e` (hard-edge, not blurred — recreate as a second panel offset behind, not a blur shader)

## Animations (timing reference for Godot Tween/AnimationPlayer)

| Animation | Values | Duration |
|---|---|---|
| Float/bob | translateY -8 to -10px, rotate ±1.5deg | 2.5-3.2s ease-in-out, loop |
| Button pulse | shadow opacity 0.35 → 0.6 | 2s loop |
| Bubble rise | translateY -90px, scale 0.15, opacity 0.65→0 | ~4s |
| Star pop | scale 0→1.3→1 | 0.5s ease-out, 200ms stagger per star (README specifies 8-frame/133ms delay at 60fps in implementation notes — use that for the actual build) |
| Twinkle | scale 1→0.55, rotate 22deg, opacity 1→0.2 | 2.5-4s |

---

## Godot-specific notes (from the README's "Implementation Notes for Claude Code" section — keep these front and center in every prompt)

1. Load Fredoka One and Nunito as bundled `.ttf` resources. No fallback fonts.
2. Soap body color changes must be a tween/lerp between the 3 body states, never a hard cut.
3. The black outline on the soap is a second, slightly larger dark rect drawn behind the body — not a shader, not a blur/glow filter. Needs to stay crisp.
4. All per-level colors come from one `LevelTheme` resource/config, referenced by level index. Never hardcode a level's colors into a specific scene.
5. HUD soap bar color updates live as `soapPercent` changes (see gradient thresholds in main spec).
6. Wet zone entry: soap tints blue and back, ~10 frames / 167ms at 60fps.
7. Win screen stars: each animates independently, scale 0→1.3→1 with rotation, 8-frame (133ms) stagger between stars.
8. Level map node unlock: animate the locked→unlocked transition, don't just swap instantly.
9. Particle cap: 80 simultaneous max. Use `CPUParticles2D` for iOS.

---

*Full behavioral spec (screen layouts, character states, obstacles, pickups) lives in the original README.md — this file is the condensed token reference to paste alongside screenshots.*
