class_name LevelData
extends Node

# Single source of truth for all 10 levels.
# Old levels 1-2 removed (too easy). Old level 3 is now level 1.
# The playfield tapers gently, 125 -> 92 across the ten levels. The original
# 125 -> 55 was so extreme that late levels felt like a different game; this
# ramp still tightens the squeeze while keeping the lane recognisable, and
# the space it frees widens the tiled walls so each bathroom reads better.
# Wet zones: {y, height} in world coords (y increases downward, soap starts at y=0).
# Obstacles: {x, y, radius} relative to channel centre (x=0).
# Pickups: {type, x, y} — "soap_sliver" or "bubble_shield".
# Procedural levels (4-10): Spawner generates zones/obstacles from proc_seed.

const LEVEL_THEMES: Array[Dictionary] = [
	{"tile_bg": Color("#e0f2fe"), "accent": Color("#7dd3fc")},  # 1 Aegean Rain (Greece)
	{"tile_bg": Color("#fef9c3"), "accent": Color("#fde047")},  # 2 Bogota Drain (Colombia)
	{"tile_bg": Color("#f0fdf4"), "accent": Color("#86efac")},  # 3 Tuscan Mist (Italy)
	{"tile_bg": Color("#fff7ed"), "accent": Color("#fdba74")},  # 4 Dutch Current (Netherlands)
	{"tile_bg": Color("#fdf4ff"), "accent": Color("#e879f9")},  # 5 Sisserou Tunnel (Dominica)
	{"tile_bg": Color("#ecfeff"), "accent": Color("#22d3ee")},  # 6 Pula Falls (Botswana)
	{"tile_bg": Color("#f0f9ff"), "accent": Color("#38bdf8")},  # 7 Sauna Deep Drain (Finland)
	{"tile_bg": Color("#fdf2f8"), "accent": Color("#f0abfc")},  # 8 Sakura Pipe (Japan)
	{"tile_bg": Color("#dbeafe"), "accent": Color("#3b82f6")},  # 9 Argentine Flood (Argentina)
	{"tile_bg": Color("#f1f5f9"), "accent": Color("#64748b")},  # 10 Thames Edge (United Kingdom)
]

const LEVELS: Array = [
	# ---- Level 1 — first real challenge: 2 wet zones, 2 obstacles ----
	{
		"id": 1,
		"name": "Aegean Rain",
		"flag": "🇬🇷",
		"min_soap": 0.55,
		"obstacle_damage": 0.22,
		"channel_half": 125.0,
		"level_length": 2450.0,
		"forward_speed": 188.0,
		"procedural": false,
		"tutorial": true,
		"wet_zones": [
			{"y": 450.0,  "height": 255.0},
			{"y": 1500.0, "height": 270.0}
		],
		"obstacles": [
			{"x": -58.0, "y":  920.0, "radius": 21.0},
			{"x":  62.0, "y": 1600.0, "radius": 21.0}
		],
		"pickups": [
			{"type": "soap_sliver", "x": 0.0, "y": 1280.0}
		]
	},
	# ---- Level 2 — 3 wet zones, 7 obstacles, tighter ----
	{
		"id": 2,
		"name": "Bogota Drain",
		"flag": "🇨🇴",
		"min_soap": 0.45,
		"obstacle_damage": 0.24,
		"channel_half": 121.0,
		"level_length": 2850.0,
		"forward_speed": 206.0,
		"procedural": false,
		"tutorial": false,
		"wet_zones": [
			{"y": 310.0,  "height": 370.0},
			{"y": 1120.0, "height": 390.0},
			{"y": 2000.0, "height": 360.0}
		],
		"obstacles": [
			{"x": -52.0, "y":  760.0, "radius": 24.0},
			{"x":  65.0, "y":  900.0, "radius": 24.0},
			{"x":   0.0, "y": 1580.0, "radius": 27.0},
			{"x": -65.0, "y": 2200.0, "radius": 25.0},
			{"x":  55.0, "y": 2330.0, "radius": 25.0},
			{"x": -30.0, "y": 2530.0, "radius": 24.0},
			{"x":  40.0, "y": 2660.0, "radius": 24.0}
		],
		"pickups": [
			{"type": "bubble_shield", "x": 10.0, "y": 1340.0}
		]
	},
	# ---- Level 3 — 4 wet zones, 9 obstacles ----
	{
		"id": 3,
		"name": "Tuscan Mist",
		"flag": "🇮🇹",
		"min_soap": 0.46,
		"obstacle_damage": 0.26,
		"channel_half": 117.0,
		"level_length": 3100.0,
		"forward_speed": 215.0,
		"procedural": false,
		"tutorial": false,
		"wet_zones": [
			{"y": 280.0,  "height": 330.0},
			{"y": 980.0,  "height": 370.0},
			{"y": 1820.0, "height": 345.0},
			{"y": 2650.0, "height": 285.0}
		],
		"obstacles": [
			{"x": -64.0, "y":  640.0, "radius": 26.0},
			{"x":  68.0, "y":  762.0, "radius": 26.0},
			{"x": -32.0, "y": 1460.0, "radius": 28.0},
			{"x":  44.0, "y": 1600.0, "radius": 26.0},
			{"x": -68.0, "y": 2290.0, "radius": 27.0},
			{"x":  62.0, "y": 2430.0, "radius": 27.0},
			{"x":  -5.0, "y": 2740.0, "radius": 29.0},
			{"x": -52.0, "y": 2880.0, "radius": 26.0},
			{"x":  55.0, "y": 2990.0, "radius": 26.0}
		],
		"pickups": [
			{"type": "soap_sliver",   "x": -20.0, "y": 1230.0},
			{"type": "bubble_shield", "x":  20.0, "y": 2160.0}
		]
	},
	# ---- Levels 4-10 — Procedural, steep escalation ----
	{
		"id": 4, "name": "Dutch Current", "flag": "🇳🇱",
		"min_soap": 0.44, "obstacle_damage": 0.27, "channel_half": 114.0,
		"level_length": 3300.0, "forward_speed": 222.0,
		"procedural": true, "proc_seed": 6001,
		"proc_wet_zone_count": 5, "proc_wet_zone_height_min": 300.0, "proc_wet_zone_height_max": 430.0,
		"proc_obstacle_count": 16, "proc_obstacle_radius_min": 24.0, "proc_obstacle_radius_max": 29.0,
		"proc_pickup_count": 2
	},
	{
		"id": 5, "name": "Sisserou Tunnel", "flag": "🇩🇲",
		"min_soap": 0.41, "obstacle_damage": 0.28, "channel_half": 110.0,
		"level_length": 3550.0, "forward_speed": 228.0,
		"procedural": true, "proc_seed": 7001,
		"proc_wet_zone_count": 5, "proc_wet_zone_height_min": 310.0, "proc_wet_zone_height_max": 450.0,
		"proc_obstacle_count": 20, "proc_obstacle_radius_min": 24.0, "proc_obstacle_radius_max": 30.0,
		"proc_pickup_count": 2
	},
	{
		"id": 6, "name": "Pula Falls", "flag": "🇧🇼",
		"min_soap": 0.38, "obstacle_damage": 0.29, "channel_half": 107.0,
		"level_length": 3800.0, "forward_speed": 235.0,
		"procedural": true, "proc_seed": 8001,
		"proc_wet_zone_count": 6, "proc_wet_zone_height_min": 315.0, "proc_wet_zone_height_max": 460.0,
		"proc_obstacle_count": 24, "proc_obstacle_radius_min": 25.0, "proc_obstacle_radius_max": 32.0,
		"proc_pickup_count": 3
	},
	{
		"id": 7, "name": "Sauna Deep Drain", "flag": "🇫🇮",
		"min_soap": 0.35, "obstacle_damage": 0.30, "channel_half": 104.0,
		"level_length": 4050.0, "forward_speed": 242.0,
		"procedural": true, "proc_seed": 9001,
		"proc_wet_zone_count": 6, "proc_wet_zone_height_min": 325.0, "proc_wet_zone_height_max": 475.0,
		"proc_obstacle_count": 28, "proc_obstacle_radius_min": 25.0, "proc_obstacle_radius_max": 33.0,
		"proc_pickup_count": 3
	},
	{
		"id": 8, "name": "Sakura Pipe", "flag": "🇯🇵",
		"min_soap": 0.30, "obstacle_damage": 0.31, "channel_half": 100.0,
		"level_length": 4300.0, "forward_speed": 249.0,
		"procedural": true, "proc_seed": 10001,
		"proc_wet_zone_count": 7, "proc_wet_zone_height_min": 335.0, "proc_wet_zone_height_max": 490.0,
		"proc_obstacle_count": 32, "proc_obstacle_radius_min": 26.0, "proc_obstacle_radius_max": 35.0,
		"proc_pickup_count": 3
	},
	{
		"id": 9, "name": "Argentine Flood", "flag": "🇦🇷",
		"min_soap": 0.28, "obstacle_damage": 0.33, "channel_half": 96.0,
		"level_length": 4550.0, "forward_speed": 258.0,
		"procedural": true, "proc_seed": 9999,
		"proc_wet_zone_count": 7, "proc_wet_zone_height_min": 345.0, "proc_wet_zone_height_max": 510.0,
		"proc_obstacle_count": 38, "proc_obstacle_radius_min": 26.0, "proc_obstacle_radius_max": 36.0,
		"proc_pickup_count": 3
	},
	{
		"id": 10, "name": "Thames Edge", "flag": "🇬🇧",
		"min_soap": 0.24, "obstacle_damage": 0.35, "channel_half": 92.0,
		"level_length": 4800.0, "forward_speed": 271.0,
		"procedural": true, "proc_seed": 10999,
		"proc_wet_zone_count": 8, "proc_wet_zone_height_min": 360.0, "proc_wet_zone_height_max": 530.0,
		"proc_obstacle_count": 44, "proc_obstacle_radius_min": 27.0, "proc_obstacle_radius_max": 38.0,
		"proc_pickup_count": 3
	}
]

static func get_level(id: int) -> Dictionary:
	for lv in LEVELS:
		if lv.id == id:
			return lv
	return {}

static func get_theme(level_index: int) -> Dictionary:
	if level_index >= 0 and level_index < LEVEL_THEMES.size():
		return LEVEL_THEMES[level_index]
	return {"tile_bg": Color("#e0f2fe"), "accent": Color("#7dd3fc")}
