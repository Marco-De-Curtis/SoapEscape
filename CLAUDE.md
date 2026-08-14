# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

**Soapy Escape** is a portrait iOS arcade game built in **Godot 4.7 / GDScript**. A soap bar slides down a bathroom drain channel across 10 levels; the player steers left/right by dragging, wet zones shrink the soap, obstacles damage it, and reaching the finish line above a per-level `min_soap` threshold wins.

The App Store listing name is "Soapy Escape". Only the bundle identifier still reads `soapescape` (permanent once the app record exists).

## Commands

There is **no test suite and no linter configured**. Verification is manual: run the game, or run the screenshot rig.

```bash
# Open in the editor
godot --path .

# Regenerate the import cache. .godot/ is gitignored, so a fresh checkout has
# no imported textures/fonts and an export would ship without them.
# Exits non-zero on harmless warnings.
godot --headless --path . --import || true

# Export the Xcode project (produces a project, not an app; see below)
godot --headless --path . --export-release "iOS" build/ios/SoapEscape.xcodeproj

# Capture App Store screenshots by driving the real game into posed states
godot --path . --resolution 1320x2868 _shots.tscn
```

**Shipping:** push a `v*` tag. `codemagic.yaml` triggers on tag only (not on push to main) because TestFlight build numbers are finite. The pipeline downloads Godot + export templates, runs `tools/configure_ios_build.py` to inject the bundle ID / team ID that are deliberately blank in the committed `export_presets.cfg`, exports the Xcode project, then signs and archives it on a hosted Mac. Godot's iOS export **only produces an Xcode project** (`export_project_only=true`); letting Godot run `xcodebuild` itself breaks signing.

## Architecture

### Screen flow

Every screen is a separate scene, swapped with `get_tree().change_scene_to_file()`. There is no persistent screen manager.

```
Main -> HomeScreen -> MapScreen -> Game -> WinScreen  -> Game (next) | GameCompleteScreen | MapScreen
                                        -> FailScreen -> Game (retry) | MapScreen
```

Because retry and next-level both reload `Game.tscn`, **`Game.start_level()` only ever runs once per scene instance** (from `_ready`). Anything that looks like inter-level reset state is effectively dead.

`Tutorial.tscn` isn't part of the scene-swap chain above: `Game._maybe_show_tutorial()` preloads and `add_child()`s it as an overlay on top of the running level (levels 1-3 only, once per level per save file). `SkinsScreen.tscn` is a standalone gallery scene with no gameplay wiring — nothing in the codebase navigates to it, per its own header comment.

### UI is built in code, not in scenes

The `.tscn` files are near-empty shells (200-600 bytes). Every label, button, panel, and anchor is constructed imperatively in `_ready()` in the matching script. When changing a screen's layout, edit the `.gd` file, not the scene.

Screens draw their own vector art via `_draw()` plus `Polygon2D`/`Line2D` children. There are no sprite assets; the game is entirely procedural rendering.

### Autoloads (`project.godot` `[autoload]`)

- **`GameData`** — volatile cross-scene handoff (current level index, last run's stars/size, fail reason, accent color). Not persisted. Also wraps haptics.
- **`SaveData`** — `ConfigFile` at `user://save.cfg`. Stars, completion, tutorial-shown flags, onboarding flag. Writes on every change.
- **`AudioManager`** — 8-player pool for one-shots plus a separate dict of looping players keyed by name. Silently no-ops when a sound file is missing, so audio is always optional.

### Single-source-of-truth modules

These exist specifically to stop duplication that has already caused drift. Prefer extending them over adding local copies:

- **`SoapArt.gd`** — every dimension, color, and polygon for the soap character. `Soap.gd` feeds its output into persistent nodes; UI screens call the same statics for immediate-mode `_draw()`. Also owns the face-state enum (`CALM`/`WORRIED`/`PANICKED`/`CRITICAL`/`VICTORY`), which `Soap.get_face_state()` picks by remaining size.
- **`Fonts.gd`** — the only correct way to build a `FontVariation`. `variation_opentype` needs an **integer** OpenType axis tag; the obvious `{"wght": 700}` string form is silently ignored and every label falls back to the font's default weight (Fredoka 300 Light, Nunito 200 ExtraLight). Cached per weight/width.
- **`LevelData.gd`** — all 10 level definitions plus per-level themes.
- **`SafeArea.gd`** — real device inset from `DisplayServer.get_display_safe_area()`, converted to viewport units. Deliberately **not** a `class_name` global (a stale `global_script_class_cache.cfg` in CI can fail to resolve it at export time); consumers `preload()` it into a `const` instead.

### Gameplay loop

`Game.gd` orchestrates: it owns the HUD, camera shake, damage flash, wet vignette, win/fail transitions, and the tutorial overlay. `Soap.gd` (a `CharacterBody2D`) owns movement, size, and its own visuals. `Spawner.gd` builds the level world (walls, wet zones, obstacles, pickups, finish line) into the `$World` node.

Communication is via signals from Soap (`died`, `size_changed`, `wet_zone_changed`) up to Game, then to the HUD.

**Level dictionary schema** (`LevelData.LEVELS`, index is 0-based, `id` is 1-based):
- Shared: `id`, `name`, `min_soap`, `obstacle_damage`, `channel_half`, `level_length`, `forward_speed`
- Authored (levels 1-3): `wet_zones: [{y, height}]`, `obstacles: [{x, y, radius}]`, `pickups: [{type, x, y}]`
- Procedural (levels 4-10): `procedural: true` plus `proc_seed` and `proc_*_count`/`_min`/`_max` bounds, generated deterministically from the seed in `Spawner._build_procedural()`

**Collision layers** (named in `project.godot` `[layer_names]`): 1 soap body, 2 walls, 4 wet zones, 5 pickups, 6 finish line. Obstacles are `StaticBody2D` with no collision at all; damage comes from a child `Area2D` kill zone.

### Steering model

Two input paths coexist in `Soap.gd` and this is intentional:
- **Drag** (`_apply_drag_tracking`) — 1:1 finger tracking. Banked `e.relative.x` is converted to exactly the velocity needed to cover that distance this tick, so swipe *speed* controls the soap. This is the primary path.
- **Tap-and-hold / desktop keys** (`_apply_lateral_physics`) — `move_toward` ramp to a size-blended top speed, tuned in real seconds.

The constants block at the top of `Soap.gd` documents the reasoning and the specific bugs each value fixes. Read it before retuning anything. `lean_magnitude` and `lean_direction` are also poked directly by `_shots.gd` to pose the soap for screenshots, so they must stay independently settable rather than derived from velocity.

## Conventions and gotchas

- **Underscore-prefixed files are dev tools.** `_shots.gd`, `_shots.tscn`, `store/_screenshot_helper.gd`. The iOS preset's `exclude_filter` drops `_*.gd`, `_*.tscn`, plus `store/`, `tools/`, `designs/`, `design_handoff/`, and `*.zip`.
- **Fonts live in `fonts/` at the repo root**, not `assets/fonts/` as `assets/ASSETS_SETUP.md` claims.
- **`window/handheld/orientation=1` must stay an integer.** A string like `"portrait"` parses to 0, which is *landscape*. The iOS preset's `orientation/*` keys do not override this. See the comment in `project.godot`.
- **`designs/design-tokens.md` and `design_handoff/` are stale on level content.** They list old levels 1-2 that were removed and shift every level name/theme by two. The color and typography tokens are still accurate. `LevelData.gd` is authoritative for levels.
- **`export_presets.cfg` is committed with signing fields blank** because the repository is public. `tools/configure_ios_build.py` fills them at build time from env vars. Never commit real values; see `store/SECRETS.md`.
- **`docs/` is served by GitHub Pages** and holds the two pages Apple requires (privacy policy, support). They must be on `main` to be live.
- Design token colors are currently pasted as hex literals throughout the screens rather than defined once. If you touch several screens, consider a `Tokens.gd` alongside `Fonts.gd` and `SoapArt.gd`.
