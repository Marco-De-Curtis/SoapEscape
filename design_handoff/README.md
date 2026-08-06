# Handoff: Soap Escape — iOS Game UI

## Overview
Soap Escape is a kawaii iOS mobile game. A soap bar with a face slides down a bathroom drain channel across 10 levels. The player steers it left and right by tilting. Wet zones shrink the soap. The goal is to reach the finish line with enough soap remaining.

## About the Design Files
The `.dc.html` files in this bundle are **high-fidelity design references built in HTML** — they show the intended look, layout, animations, and interactions. They are prototypes, not production code. Your task is to **recreate these designs in the target codebase** (Godot, React Native, SwiftUI, or whatever stack is chosen) using its established patterns and libraries. Do not ship the HTML directly.

Open each file in a browser to interact with all screens. The onboarding carousel in Phase 1 is fully interactive (tap the dots or buttons).

## Fidelity
**High-fidelity.** Pixel-perfect mockups with final colors, typography, spacing, animations, and copy. Recreate exactly — these are signed-off designs.

---

## Design Tokens

### Colors — Global
| Token | Hex | Use |
|---|---|---|
| Primary pink | `#d63384` | Headings, primary buttons, key accents |
| Purple | `#7c3aed` | Secondary text, level numbers, gradient end |
| Star gold | `#f59e0b` | Stars, celebrations, pickups |
| Success green | `#15803d` | Win state, restore pickup label |
| Danger red | `#e11d48` | Fail state, obstacle |
| White | `#ffffff` | Card backgrounds, HUD panels |
| Off-white (app bg) | `#fdf2f8` | App background |
| Lane bg | `#fce7f3` | Lane / home screen bg |

### Colors — Per Level
Each level has its own tile background and accent. The accent applies to lane borders, HUD top bar border, and UI accents for that level.

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

### Typography
Two fonts only — both available on Google Fonts.

| Font | Role | Sizes used |
|---|---|---|
| **Fredoka One** (weight 400) | Display, scores, level names, win/fail headlines, buttons | 14–66px |
| **Nunito** (weights 400, 600, 700, 800) | Body, labels, HUD, instructions | 9–17px |

Typographic specs:
| Element | Font | Size | Weight | Color |
|---|---|---|---|---|
| App title "Soap Escape" | Fredoka One | 52px | 400 | `#d63384` + `#7c3aed` for "!" |
| Level name on map | Nunito | 9px | 600 | `#7c3aed` |
| Level number in node | system sans | 15px | 700 | `#ffffff` |
| In-game level name | Nunito | 13px | 700 | `#d63384` |
| Score / progress % | Nunito | 13px | 700 | `#7c3aed` |
| Soap % label | Fredoka One | 13px | 400 | `#d63384` |
| Win headline | Fredoka One | 32px | 400 | `#d63384` |
| Fail headline | Fredoka One | 30px | 400 | `#e11d48` |
| Onboarding titles | Fredoka One | 26px | 400 | `#d63384` |
| Body / instructions | Nunito | 14px | 400 | `#6b7280` |
| Button labels (Fredoka) | Fredoka One | 18–22px | 400 | white |
| Button labels (Nunito) | Nunito | 17px | 700 | white |

Text treatment on large display text (logo, home title):
```css
-webkit-text-stroke: 1.5px white;
text-shadow: 2px 3px 0 rgba(181,45,112,0.45);  /* pink shadow */
/* purple "!" gets: */
text-shadow: 2px 3px 0 rgba(91,33,182,0.45);
```

### Spacing & Layout
- Canvas: 390×844pt (iPhone 14, portrait)
- Dynamic Island: 126×37px, top: 12px, centered
- Top HUD bar: height 48px, top: 56px (below DI)
- Bottom soap bar: height ~48px, bottom: 20px
- Home safe area: bottom home indicator 34px from bottom
- Card border-radius: 28–32px (bottom sheets), 12–16px (small cards)
- Button border-radius: pill (height/2)

### Shadows & Borders
- Phone frames (design reference): `box-shadow: 0 0 0 1px rgba(255,255,255,.1), 0 24px 64px rgba(0,0,0,.3)`
- Primary button: `box-shadow: 0 6px 24px rgba(214,51,132,.4)`
- HUD top bar: `border-bottom: 2px solid [level-accent]`
- Logo sticker: `border: 3px solid #1a1a2e; box-shadow: 5px 5px 0 #1a1a2e`

### Animations
- Float/bob: `translateY(-8 to -10px) rotate(±1.5deg)` over 2.5–3.2s ease-in-out infinite
- Button pulse: `box-shadow` grows from `rgba(214,51,132,.35)` to `.6` over 2s
- Bubble rise: `translateY(-90px) scale(0.15)`, opacity 0.65→0, ~4s
- Star pop: `scale(0)→scale(1.3)→scale(1)`, 0.5s ease-out, staggered 200ms per star
- Twinkle: `scale(1)→scale(0.55) rotate(22deg)`, opacity 1→0.2, 2.5–4s

---

## Screens

### Screen 1: Home Screen (Phase 1 — options 1c & 1d)
**Purpose:** App entry point. Shows the soap character and launches directly into play.

**Layout (390×844):**
- Background: `radial-gradient(ellipse at 50% 35%, #fdf2f8 0%, #fce7f3 100%)`
- Dynamic Island overlay (always present)
- Title area (y: 82–160): "Soap Escape" Fredoka One 52px centered, tagline below
- Soap character (y: ~295): 240×133px, floating animation, centered
- Floating background bubbles: 5–6 small circles, pink/lavender, rising animation
- Sparkle decorations: 3 ✦ glyphs at various positions, twinkle animation
- Play button (bottom: 88–152px): full-width minus 64px margins, 64px height, pill, `#d63384` bg
- "How to play?" link below button: Nunito 14px 600 `#7c3aed`
- Home indicator: bottom 10px

**Option 1c** is the preferred direction (cleaner, more breathing room).
**Option 1d** is an alternative — tilted title, soap rotated 7deg with motion trails.

---

### Screen 2: Onboarding Carousel (Phase 1 — option 1e)
**Purpose:** 3-slide tutorial shown on first launch.

**Structure:** Each slide = full-screen (390×844). Bottom sheet card ~280px. Illustration fills the rest.

**Navigation:** Three equal-size dots (10×10px circles). Active dot: `#d63384`. Inactive: `#f9a8d4`. All identical size (no pill shape for active). "Skip" top-right, "Next →" / "Let's Go! 🎮" bottom CTA.

**Slide 1 — Tilt to Steer**
- Illustration: bathroom tile floor, vertical drain lane, soap (lavender/calm) centered in lane, two phone silhouettes outside lane (tilted ±18deg) with "← TILT" / "TILT →" labels, large curved arrow paths sweeping left/right with polygon arrowheads (`#d63384`, 6px stroke)
- Motion speed lines left/right of soap (3 horizontal lines, purple, decreasing opacity)
- Drain circle at bottom of lane
- Title: "Tilt your phone to steer."
- Body: "Your soap bar follows the tilt. Left, right, straight — you're in control. The drain is waiting."

**Slide 2 — Wet Zones**
- Illustration: lane split — top 45% safe (white), bottom 55% wet zone (`rgba(96,165,250,0.18)`) with animated bubbles; wave SVG at transition; soap (yellow/worried) approaching wet zone; bubble shield pickup (🫧, 68×68px gold orb) in wet zone with "GRAB → blocks water!" tooltip
- Two annotation badges: "✓ SAFE ZONE" (green) and "💧 WET ZONE" (blue) on right edge
- Before/after size panel at bottom: full soap → shrunken soap with "−35%" label
- Title: "Water dissolves you."
- Body: "Wet zones shrink your soap fast. Grab a bubble shield to block them — or sprint through. Your choice."

**Slide 3 — Power-Ups**
- Not included in final carousel (replaced by Reach the Finish). See below.

**Slide 3 — Reach the Finish**
- Illustration: tile floor, lane with large checkered finish line strip (18×18px checker, pink + white), victory soap (star eyes) above line; 3 stars appearing below; confetti; soap % requirement panel at bottom showing HUD bar + "Minimum 30% needed to pass · 3 stars = 70%+"
- Title: "Reach the finish line."
- Body: "Get there with enough soap left. 3 stars if you barely dissolved. 10 levels of increasing chaos."
- CTA: "Let's Go! 🎮" gradient button

---

### Screen 3: Level Map (Phase 2 — option 2a)
**Purpose:** Level selection. Shows progression across 10 levels on a winding path.

**Layout:**
- Background: `#fdf2f8` + tile grid overlay (`background-image` grid, `rgba(249,168,212,0.1)`, 22×22px)
- Top bar (y: 58px): white 88% opacity, pink bottom border `#f9a8d4`, "Soap Escape" Fredoka One 22px left, status right
- Winding pink dashed path connecting all 10 nodes (stroke `#f9a8d4`, width 5px, dasharray 13,9)

**Level node states (44px outer diameter):**
| State | Fill | Border | Label |
|---|---|---|---|
| Completed | `#86efac` (mint green) | white 3px | White number, stars below |
| Current / unlocked | Level accent color | 3.5px accent, outer pulse ring | White number, soap character alongside |
| Locked | `#e5e7eb` | `#d1d5db` 2px | 🔒 icon |

**Stars below completed nodes:** 1–3 ⭐ emoji, 10px font, centered below node.
**Level name labels:** Nunito 9px 600 `#7c3aed`, white/80% bg pill, appear above (for left nodes) or above (for right nodes).
**Current level:** Outer pulsing ring (`rgba(accent, 0.3)`), soap character next to node in floating animation.
**Decorative bubbles:** Small circles with pink/lavender stroke scattered around path.

**Node path coordinates (cx, cy in a 390×740 map content area below header):**
L1(90,676) → L2(280,612) → L3(110,547) → L4(276,488) → L5(105,425) → L6(268,364) → L7(105,302) → L8(268,240) → L9(110,178) → L10(260,118)

---

### Screen 4: In-Game HUD (Phase 2 — option 2b)
**Purpose:** The game screen the player sees while playing.

**Structure (top to bottom):**
```
[Dynamic Island — always overlaid]
[TOP HUD BAR — 48px]
[GAME CANVAS — flex:1]
[BOTTOM SOAP BAR — ~48px]
[Home indicator]
```

**Top HUD bar:**
- Background: `rgba(255,255,255,0.88)`
- Bottom border: 2px solid `[level-accent-color]`
- Left: "Level N — [Level Name]" Nunito 13px 700 `#d63384`
- Right: mini progress bar (80×7px, level bg track, gradient fill) + "45%" Nunito 13px 700 `#7c3aed`

**Game canvas:**
- Background: level tile color with bathroom tile SVG grid pattern
- Vertical lane (white, ~222px wide, rounded 24px corners, level accent stroke 1.5px), centered
- Center dashed line (level accent, opacity 0.4)
- Wet zone: `rgba(96,165,250,0.18)–0.22` fill inside lane, dashed border, wave SVG at top edge, animated bubbles, "💧 WET ZONE AHEAD" label pill
- Speed lines: 3 horizontal lines left+right of soap, purple at decreasing opacity
- Soap character: see character spec below
- Obstacles: in the lane above the soap
- Pickups: in the lane, glowing orb treatment

**Bottom soap bar:**
- White 92% bg, rounded 20px, level accent border 1.5px
- 🧼 emoji left | progress bar (flex:1, 10px height, rounded, fill: gradient based on state) | "48%" Fredoka One 13px `#d63384` right
- Bar fill states:
  - Healthy (>60%): `linear-gradient(90deg, #d63384, #7c3aed)`
  - Mid (30–60%): `linear-gradient(90deg, #f59e0b, #fde68a)` (orange→yellow)
  - Critical (<30%): `linear-gradient(90deg, #e11d48, #fb923c)` (red→orange)
- Track: level tile bg color
- Bar track border: 1px level accent color

---

### Screen 5: Win Screen (Phase 2 — option 2c)
**Purpose:** Post-level victory. Celebrates completion and shows star rating.

**Layout (390×844, full-screen):**
- Background: level tile color (Level 3 example: `#e0f2fe`)
- Dynamic Island overlay
- Confetti: 7–8 floating ★ and ✦ glyphs in pink/gold/lavender, `confettiDrop` animation
- Victory soap (180×100px, star eyes, floating): centered, ~240px from top
- "New record! ✨" badge: gold gradient pill above headline (conditional — only if new best)
- "Level Complete!" Fredoka One 32px `#d63384`, text-stroke + shadow treatment
- Level name: Nunito 16px 700, level accent color
- Soap remaining panel: white 75%, border level accent, 🧼 + progress bar + "68%" Fredoka One 20px
- Stars: ⭐⭐⭐ at 44/56/44px, staggered `starPop` animation (0.1s/0.3s/0.5s delays)
- Buttons row: [Map] white outlined 58px pill | [Next Level →] gradient pink→purple 58px pill (2× width)

**Star award thresholds (example, adjust per level):**
- 1 star: reached finish at any soap amount above minimum
- 2 stars: ≥50% soap remaining
- 3 stars: ≥70% soap remaining

---

### Screen 6: Fail Screen (Phase 2 — option 2d)
**Purpose:** Post-fail state. Warm, encouraging, never punishing.

**Layout (390×844):**
- Background: `#fff1f2` + two soft `rgba(254,202,202,0.25–0.3)` circles (top-right and bottom-left corners)
- Dynamic Island overlay
- Dissolved soap (critical state, 120×67px): centered, floating animation
- "Oops! Try again." Fredoka One 30px `#e11d48`
- Cause cards (3 variants, only the applicable one is "active" — others shown at 70% opacity):
  - Dissolved: 💧 "Dissolved!" + "Your soap bar melted completely in the water."
  - Obstacle: 🚫 "Hit an obstacle!" + "That rubber duck really doesn't like you."
  - Too small: 📏 "Too small at the finish!" + "You needed at least 30% soap to pass."
  - Active card: white bg, `border: 2px solid #fecaca`
  - Inactive cards: white 60% bg, `border: 1.5px solid #fde8e8`, opacity 0.7
- Encouragement text: Nunito 14px `#9ca3af` centered, 2 lines max
- Buttons: [Map] grey outlined | [Try Again] `#d63384` solid (2× width)

---

## The Soap Character

### Shape
- Rounded rectangle, aspect ratio 9:5 (width:height)
- Corner radius: ~35% of height (very round)
- **Black outline** (not pink): `fill: #1a1a2e` rect slightly larger underneath, then soap body rect on top — creates a solid 3px black border. This is the LINE Friends / Japanese sticker aesthetic.
- Body fill changes with size (smooth CSS transition/tween):
  - >60%: `#f0e6ff` (lavender)
  - 30–60%: `#fde68a` (yellow)
  - <30%: `#fecaca` (pink-red)
- Highlight: white rounded rect, top-left of body, 50% opacity

### Face Elements
| Part | Description |
|---|---|
| Cheeks | Two ellipses, `rgba(251,113,133,0.35–0.65)`, lower-third, scale with body |
| Eyes (calm) | Circles r=8, `#4c1d95`, with white shine circle r=2.5 offset top-right |
| Eyes (worried) | Larger r=9.5, `#92400e`, shine shifted up |
| Eyes (panicked) | White sclera r=13, iris r=10 `#991b1b`, pupil top-left offset r=4 |
| Eyes (critical) | X marks — two crossed lines at each eye, `#991b1b` sw=5 |
| Eyes (victory) | ★ text elements, `#f59e0b`, font-size 22 |
| Eyebrows (worried) | Curved path, inner corners raised |
| Eyebrows (panicked) | Straight lines angled to V-shape, sw=4 |
| Smile (calm) | `M 56 61 Q 90 79 124 61` — upward arc |
| Mouth (worried) | Shallow downward arc |
| Frown (panicked) | `M 57 70 Q 90 56 123 70` — inverted arc |
| Wobble (critical) | Wavy path with 5 control points |
| Smile (victory) | `M 50 64 Q 90 86 130 64` — wide deep arc |
| Tears (critical) | Two ellipses below X-eyes, `rgba(96,165,250,0.72)` |
| Sweat drop (worried) | Teardrop path, `rgba(96,165,250,0.75)`, top-right corner |

### Expression state thresholds
| State | Soap % |
|---|---|
| Calm | >60% |
| Worried | 40–60% |
| Panicked | 20–40% |
| Critical | <20% |
| Victory | Finish line crossed |

### Body size scaling
As soap decreases, the body shrinks physically (not just color change). At <20%, the corner radius increases toward circular ("melting" effect).

---

## Obstacles

| Obstacle | Shape | Fill | Stroke | Notes |
|---|---|---|---|---|
| Rubber duck | Oval body + smaller head | `#fde047` | `#1a1a2e` 3px | Grumpy face (angled brow, offset eye). First appears level 1. |
| Drain grate | Rectangle, grid lines | `#6b7280` | — | No face. |
| Sponge | Rectangle, textured | `#fb923c` | — | Determined face. Level 2+. |
| Clumped hair | Irregular blob | `#92400e` | — | No face. Level 2+. |

All obstacles: 2px black outline, readable at 40×20px.

---

## Pickups

| Pickup | Visual | Orb color | Effect |
|---|---|---|---|
| Bubble shield 🫧 | 68×68px circle, `rgba(240,192,64,0.35–0.45)` fill, `rgba(240,192,64,0.8)` border, emoji centered, glow `box-shadow: 0 0 20–36px rgba(240,192,64,0.5)` | Gold | Blocks next water contact for 3 seconds |
| Soap sliver ✨ | Same structure, green: `rgba(134,239,172,0.35–0.38)` | Mint green | Restores 12% soap size |

On collect: burst particle + popup label floats up from soap position.

---

## Finish Line

- Full lane width bar across the channel
- Checkered SVG pattern: 18×18px tiles alternating pink `#d63384` / white
- "🏁 FINISH LINE" pill label centered on strip, dark bg `rgba(0,0,0,0.4)`
- Drop shadow below strip: `rgba(0,0,0,0.1)` 6px height
- When soap crosses: white flash + star burst particles + victory soap expression

---

## Wet Zones

- Blue tint overlay: `rgba(96,165,250,0.18–0.22)` over lane color
- Dashed border: `rgba(96,165,250,0.45–0.6)` 1.5px dashed
- Wave SVG at entry edge (top of zone)
- Animated bubbles: small circles `rgba(147,197,253,0.5–0.65)`, rise animation
- Entry label: "💧 WET ZONE AHEAD" pill, `rgba(219,234,254,0.9)` bg
- Advance warning: ripple strip 200 world units before zone entry

---

## Logo

Two treatments are designed (see Phase 1, option 1b). **Preferred: B — Sticker シール**.

**Logo B spec:**
- Container: white bg, `border-radius: 16px`, `border: 3px solid #1a1a2e`, `box-shadow: 5px 5px 0 #1a1a2e`
- Tilt: `transform: rotate(-2deg)`
- Soap mascot (80×44px) with black outline (see soap spec above), centered top, floating animation
- Horizontal rule: `1.5px solid #1a1a2e`
- "Soap Escape" Fredoka One 42px: "Soap" `#d63384`, "Escape" `#7c3aed`, text-stroke 1.5px white, dark shadow
- Subtitle rule row: "SLIDE · DODGE · SURVIVE" Nunito 8px 700 `#9ca3af` letter-spacing 0.18em, flanked by lines
- Red hanko dot (bottom-right, partially overlapping border): 22px circle `#e11d48` with "No.1" text

---

## State Management (per screen)

**Level Map:**
- `completedLevels: number[]` — which levels have been completed
- `starCounts: Record<number, 1|2|3>` — stars per completed level
- `currentLevel: number` — the next playable level

**In-Game:**
- `soapPercent: number` (0–100) — drives bar width, body color, expression state, size
- `levelProgress: number` (0–100) — top bar progress
- `hasShield: boolean` — bubble shield active state
- `inWetZone: boolean` — triggers shrink timer

**Win Screen:**
- `soapRemaining: number`
- `starsEarned: 1|2|3`
- `isNewRecord: boolean`

**Fail Screen:**
- `failCause: 'dissolved' | 'obstacle' | 'too_small'`
- `minimumRequired: number` (for "too small" message)

---

## Assets Required

All assets @2× (Retina). Godot imports @1× automatically.

| Asset | Format | Size | Notes |
|---|---|---|---|
| Soap body (per skin) | PNG transparent | 128×80px | 6 skins: Classic, Citrus, Rose, Charcoal, Marble, Rainbow |
| Soap face sprite sheet | PNG transparent | 512×80px | 4 frames: Calm, Worried, Panicked, Critical |
| Soap face (Victory) | PNG transparent | 128×80px | Star eyes, single frame |
| Rubber duck obstacle | PNG transparent | 96×48px | Grumpy face |
| Sponge obstacle | PNG transparent | 96×48px | — |
| Bubble shield pickup | PNG transparent | 64×64px | Glowing treatment |
| Soap sliver pickup | PNG transparent | 64×64px | — |
| Finish line strip | PNG transparent | 440×48px | Checkered |
| Level map nodes | PNG transparent | 3 states × 88×88px | Completed, current, locked |
| App icon | PNG | 1024×1024px | Soap face, star eyes, pink bg, bubbles |
| Fredoka One | TTF | — | Google Fonts |
| Nunito Regular + Bold | TTF | — | Google Fonts |

---

## Files in this Package

| File | Contents |
|---|---|
| `SoapEscape Phase 1.dc.html` | Logo (2 treatments), soap character sheet (5 states), home screen (2 options), onboarding carousel (3 interactive slides) |
| `SoapEscape Phase 2.dc.html` | Level map, in-game HUD (Level 3), win screen (Level 3, 3 stars), fail screen (3 cause variants) |
| `README.md` | This document |

Open files in any modern browser. The onboarding carousel is interactive — tap the nav dots to switch slides.

---

## Implementation Notes for Claude Code

1. **Font loading**: Load Fredoka One and Nunito from Google Fonts or bundle the TTFs. No substitutions.
2. **Soap body color tween**: Use a smooth interpolation (e.g. lerp or CSS transition) between the three body color states — not a hard switch.
3. **Black outline on soap**: Achieved by drawing a slightly-larger dark rect behind the body rect, or using `paint-order: stroke fill` with a dark stroke in SVG. NOT using filter or shadow — the outline should be crisp.
4. **Per-level color theming**: All level-specific colors should be driven by a single `levelTheme` config object, not hardcoded per screen.
5. **HUD soap bar**: Update the bar color in real-time as `soapPercent` changes.
6. **Wet zone entry animation**: Brief blue ripple flash on the soap body (tint to blue and back, ~10 frames / 167ms at 60fps).
7. **Star animation on win screen**: Each star animates independently — scale 0→1.3→1 with rotation, 8-frame delay between each (133ms at 60fps).
8. **Level map node unlock**: Animate the transition from locked to unlocked when a new level becomes available.
9. **Particle budget**: Max 80 simultaneous particles. Use CPUParticles2D for iOS compatibility.
