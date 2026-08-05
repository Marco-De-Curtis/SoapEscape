# Assets Setup

All game content is code-driven — no assets are required to run the game.
Missing audio files are silently skipped. Missing sprites use programmatic shapes.

## Audio — place CC0 .wav or .ogg files in assets/audio/sfx/

Filename (no extension) → trigger

| File | Trigger |
|---|---|
| enter_wet | Enter a wet zone |
| shrink_loop | Looping while in wet zone (enable Loop in import settings) |
| pickup_shield | Bubble shield collected |
| pickup_sliver | Soap sliver collected |
| shield_break | Shield absorbs obstacle hit |
| obstacle_hit | Obstacle death |
| dissolved | Soap dissolves to 0 |
| level_win | Win screen |
| star_ding | Played once per star earned |
| level_fail | Fail screen |

Recommended CC0 source: https://kenney.nl/assets/game-audio-starter-pack

## Fonts
Place in assets/fonts/:
- Fredoka-Regular.ttf (display text)
- Nunito-Regular.ttf (body/UI)

Both available free from Google Fonts.

## Sprites
The game renders procedurally — no sprite sheets required.
Optional texture overlays can be added to Polygon2D nodes in scene files.
