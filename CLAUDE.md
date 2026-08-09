# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

**Soapy Escape** — a portrait iOS game in Godot 4.7 / GDScript. A soap bar
auto-scrolls down a bathroom drain channel across 10 levels; the player only
controls its lateral position. Wet zones shrink the soap, obstacles chip it,
and the goal is to reach the finish line above a per-level minimum size.

The App Store listing name is "Soapy Escape" (plain "Soap Escape" was taken).
The bundle identifier still reads `soapescape` and cannot change — it is
permanent once an app record exists.

## Commands

There is no test suite, linter, or build script. Verification is done by
booting scenes headless and by simulating formulas in Python.

```bash
# Boot a scene headless to catch parse/runtime errors (the standard check
# before committing). --quit-after N runs N physics frames.
xvfb-run -a godot --headless --path . --quit-after 15 res://scenes/Game.tscn

# Booting Game.tscn specifically also exercises Game.start_level() and the
# real input/physics path; booting only Main.tscn does not.

# Export the iOS Xcode project locally (needs a placeholder team ID first —
# revert export_presets.cfg afterwards, CI injects the real one).
godot --headless --path . --export-release "iOS" build/ios/SoapEscape.xcodeproj

# Regenerate App Store screenshots (see store/screenshots.md).
godot --path . --resolution 1320x2868 --rendering-driver opengl3 \
      --audio-driver Dummy _shots.tscn
python3 tools/compose_screenshots.py <captures> store/screenshots/final
```

`godot --script res://foo.gd` does **not** work for exercising game scripts:
script mode boots before autoloads exist, so anything referencing
`AudioManager` / `GameData` / `SaveData` fails to compile. Use a full scene
boot, or port the formula to Python and simulate it.

## Architecture

### Everything is drawn in code

There are no sprite, texture, or image assets — all artwork is generated
procedurally at runtime. The only binary assets are two fonts and ten `.ogg`
sound effects. This is load-bearing for the App Store originality claim (see
`THIRD_PARTY_NOTICES.md`), so do not introduce bundled image assets casually.

Art lives in `RefCounted` "single source of truth" classes with static
methods, consumed two ways: `Soap.gd` feeds the returned shapes into
persistent `Polygon2D`/`Line2D` nodes, while UI screens call them from
`_draw()` in immediate mode.

| Class | Owns |
|---|---|
| `SoapArt` | The soap character: body, face states, colours, metrics |
| `LogoArt` | Logo lockups and the app icon (`paint_icon`) |
| `ObstacleArt` | Ducks, grates, sponges, combs, hair |
| `BathroomArt` | Per-level backdrop, one country theme each |
| `TutorialArt` | The four onboarding slide illustrations |
| `Fonts` | Typography |

Change a number in one of these and every screen follows. Duplicating a shape
by hand is how the gameplay soap and menu soap previously drifted apart.

`tools/generate_app_icon.py` is a **Pillow port of `LogoArt.paint_icon()`**.
Its `SOAP_SCALE` / `SOAP_CENTRE` / `WATER_LINE` constants mirror the GDScript
ones — change the icon in `LogoArt.gd` and re-run the tool.

### Two gotchas that have caused real bugs

**`Fonts`**: `FontVariation.variation_opentype` needs the OpenType axis as an
integer tag. The obvious `{"wght": 700}` string form is silently ignored and
everything renders at the font's default weight. Always go through
`Fonts.fredoka()` / `Fonts.nunito(weight)`.

**`SafeArea`**: deliberately **not** a `class_name` global. Global classes
resolve through `.godot/global_script_class_cache.cfg`, which is gitignored
except for one tracked copy, so a fresh CI checkout can carry a stale cache
and the identifier fails to resolve at export time. Consumers do
`const SafeArea = preload("res://scripts/SafeArea.gd")`. Prefer preload-by-path
for any new shared script.

### Game flow

`Main.tscn` immediately redirects to `HomeScreen.tscn`. From there:
Home → Map → Game → Win/Fail → Map. Each is a full scene swap via
`change_scene_to_file`, so **all cross-scene state goes through the
`GameData` autoload** (`current_level_index`, `fail_reason`, `last_stars`,
`prev_stars`, `last_soap_pct`, `level_accent`).

Autoloads: `GameData` (transient run state + haptics), `SaveData`
(`user://save.cfg` — stars, completion, onboarding/tutorial flags),
`AudioManager` (`play`, `play_loop`, `stop_loop`, `stop_all`).

`Game.gd` owns a level's lifetime: `start_level()` resets every mutable field
on the `Soap` node by hand, then `Spawner.build_level()` constructs the world.
**When adding state to `Soap.gd`, add it to that reset block too** — stale
state surviving a retry has been a recurring bug source.

### Levels

`LevelData.LEVELS` is the single source for all 10. Levels 1–3 are
hand-authored (explicit `wet_zones`, `obstacles`, `pickups` arrays); levels
4–10 set `procedural: true` and `Spawner` generates content from `proc_seed`.
Lane half-width tapers 125 → 92 across the ten.

Physics layers: 1 `soap_body`, 2 `walls`, 4 `wet_zones`, 5 `pickups`,
6 `finish_line` (3 unused).

### Steering

`Soap.gd` has two input paths, and this code has an unusually painful bug
history — read the comments before changing it:

- **Drag** (`_dragging`): 1:1 finger tracking. `InputEventScreenDrag.relative.x`
  accumulates into `_drag_dx`, converted to exactly the velocity needed to
  cover that distance this tick. Soap speed equals thumb speed. This exists
  because the previous model only read swipe *direction* and accelerated to a
  fixed 252 units/s cap — with a 250-unit lane, that meant a gentle nudge and
  a violent flick moved identically.
- **Tap-and-hold / desktop keys**: the older lean model, `move_toward` with
  ramp/ease times in real seconds.

`lean_direction` and `lean_magnitude` drive **only** the squash and speed-line
visuals while dragging. `_shots.gd` sets them directly while forcing velocity
to zero, so they must stay independently settable, never derived from motion.

## iOS build

CI is `codemagic.yaml` (workflow `ios-testflight`, macOS runner). Godot cannot
produce an IPA on its own here: the preset sets `export_project_only=true`, so
Godot emits only an Xcode project and `xcode-project build-ipa` does the
signing and archiving. Letting Godot run `xcodebuild` itself fails with
conflicting provisioning settings.

The repo is public, so `APPLE_TEAM_ID` and `IOS_BUNDLE_ID` are injected at
build time by `tools/configure_ios_build.py`. That script also **guards
settings whose committed value looks right in English but means something else
to the engine**, and each guard exists because that exact value shipped a
broken build:

- `window/handheld/orientation` must be integer `1`. A leftover Godot 3
  `"portrait"` string converts to `0`, which is `SCREEN_LANDSCAPE`.
- `application/targeted_device_family` must be `0`. Godot's enum is
  0=iPhone, 1=iPad, 2=both — *not* the UIDeviceFamily numbering it resembles.
- `boot_splash/image` must be non-empty, or Godot bundles **its own logo** as
  the native iOS launch screen. `boot_splash/show_image` does not gate this.

Also required in `project.godot`: `textures/vram_compression/import_etc2_astc=true`,
without which the iOS export fails with an empty error list. Note
`project.godot` uses `;` for comments, not `#`.

`export_presets.cfg` `exclude_filter` keeps `store/`, `tools/`, `designs/`,
`design_handoff/` and `_*.gd` / `_*.tscn` out of shipped builds — that is why
the screenshot rig is underscore-prefixed.

## Store submission

`store/` holds the whole App Store kit: `metadata.md` (every ASC text field
ready to paste, including review notes), `screenshots.md`, `SECRETS.md` (what
is and isn't a credential, and where each CI value goes),
`BUILD_WITHOUT_A_MAC.md`. Screenshots are committed at two sizes in
`store/screenshots/final` (6.9", 1320x2868) and `final_65` (6.5", 1284x2778).
The privacy and support pages GitHub Pages serves live in `docs/`.

## Known issues, not yet fixed

- **Soap contrast in wet zones** (`Soap.gd`, `_update_body`): the body fill
  lerps toward light blue inside a wet zone, dropping to roughly 1.2:1 against
  the water tint — the soap camouflages exactly when it most needs to be seen.
- **Camera zoom**: the play channel is only ~56% of screen width; the rest is
  decorative tiling. Pulling the camera in would help legibility but changes
  difficulty.
- **Difficulty vs. 1:1 steering**: the ten levels were balanced against the old
  252 units/s lateral cap. Direct finger tracking makes dodging materially
  easier and may warrant a rebalance.
