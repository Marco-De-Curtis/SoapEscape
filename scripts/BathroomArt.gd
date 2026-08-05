class_name BathroomArt
extends RefCounted

# Per-level bathroom backdrops, one country each. Draws the wall/tile pattern
# behind the play lane. Kept separate from LevelData so the palette and the
# pattern live together in one place.

const THEMES: Array[Dictionary] = [
	{"name": "Onsen",     "country": "Japan",   "pattern": "slats",    "wall": Color("#efe4d4"), "tile": Color("#d9b892"), "line": Color("#8a6b4f"), "accent": Color("#3b5b8c")},
	{"name": "Riad",      "country": "Morocco", "pattern": "zellige",  "wall": Color("#f3ede1"), "tile": Color("#1f8a8a"), "line": Color("#c96f4a"), "accent": Color("#e0a458")},
	{"name": "Carrara",   "country": "Italy",   "pattern": "marble",   "wall": Color("#f6f5f2"), "tile": Color("#e6e4df"), "line": Color("#b9b6ae"), "accent": Color("#b08d57")},
	{"name": "Haussmann", "country": "France",  "pattern": "checker",  "wall": Color("#f4f1ea"), "tile": Color("#2b2b2e"), "line": Color("#ffffff"), "accent": Color("#c8a24a")},
	{"name": "Cyclades",  "country": "Greece",  "pattern": "wash",     "wall": Color("#f7f7f4"), "tile": Color("#2f6fb5"), "line": Color("#dfe6ea"), "accent": Color("#2f6fb5")},
	{"name": "Talavera",  "country": "Mexico",  "pattern": "talavera", "wall": Color("#fbf3e4"), "tile": Color("#1f5fa8"), "line": Color("#e0b23c"), "accent": Color("#c8452f")},
	{"name": "Hammam",    "country": "Turkey",  "pattern": "hex",      "wall": Color("#efe9e0"), "tile": Color("#cfc3b2"), "line": Color("#a08e78"), "accent": Color("#b06a3b")},
	{"name": "Hygge",     "country": "Sweden",  "pattern": "scandi",   "wall": Color("#f6f4f0"), "tile": Color("#e3ded4"), "line": Color("#c9c2b4"), "accent": Color("#7f9a86")},
	{"name": "Jaali",     "country": "India",   "pattern": "jaali",    "wall": Color("#f3ece2"), "tile": Color("#1d6b5a"), "line": Color("#d9c9a3"), "accent": Color("#c9a227")},
	{"name": "Deco",      "country": "USA",     "pattern": "deco",     "wall": Color("#f2efe9"), "tile": Color("#15181c"), "line": Color("#d7cfc2"), "accent": Color("#1fa5a0")},
]

static func theme(level_index: int) -> Dictionary:
	if level_index >= 0 and level_index < THEMES.size():
		return THEMES[level_index]
	return THEMES[0]

## Paints the backdrop for `level_index` across `rect`.
## `strength` fades the pattern toward the wall colour so it never fights the
## gameplay: 1.0 is the full pattern, 0.0 is a plain wall.
static func paint(ci: CanvasItem, level_index: int, rect: Rect2, strength: float = 1.0) -> void:
	var t := theme(level_index)
	var wall: Color   = t["wall"]
	var tile: Color   = _mix(t["tile"], wall, strength)
	var line: Color   = _mix(t["line"], wall, strength)
	var accent: Color = _mix(t["accent"], wall, strength)

	ci.draw_rect(rect, wall)
	var p := rect.position
	var s := rect.size

	match str(t["pattern"]):
		"slats":
			var x := p.x
			while x < p.x + s.x:
				ci.draw_rect(Rect2(x, p.y, 22.0, s.y), tile)
				ci.draw_line(Vector2(x + 23.0, p.y), Vector2(x + 23.0, p.y + s.y), line, 1.5)
				x += 30.0
		"zellige":
			var step := 34.0
			var yy := p.y
			var row := 0
			while yy < p.y + s.y + step:
				var xx := p.x + (0.0 if row % 2 == 0 else step * 0.5)
				while xx < p.x + s.x + step:
					var c: Color = tile if (row + int(xx / step)) % 3 != 0 else accent
					_diamond(ci, Vector2(xx, yy), step * 0.46, c)
					xx += step
				yy += step * 0.62
				row += 1
		"marble":
			ci.draw_rect(rect, tile)
			var rng := RandomNumberGenerator.new()
			rng.seed = 12345
			for i in 14:
				var pts := PackedVector2Array()
				var y0: float = p.y + s.y * rng.randf()
				for j in 13:
					var f: float = float(j) / 12.0
					pts.append(Vector2(p.x + s.x * f, y0 + sin(f * PI * 2.0 + float(i)) * 26.0))
				ci.draw_polyline(pts, Color(line.r, line.g, line.b, 0.7), 2.0, true)
		"checker":
			# 46px squares showed barely one column in a wall strip
			var ts := 26.0
			var rows := int(s.y / ts) + 2
			var cols := int(s.x / ts) + 2
			for r in rows:
				for c2 in cols:
					if (r + c2) % 2 == 0:
						ci.draw_rect(Rect2(p.x + float(c2) * ts, p.y + float(r) * ts, ts, ts), tile)
		"wash":
			# Santorini reads as whitewashed stone blocks, not arches: at this
			# width the arches were too timid and the bands too heavy.
			ci.draw_rect(rect, wall)
			var bh := 24.0
			var yy5 := p.y
			var brow := 0
			while yy5 < p.y + s.y:
				var blue_row := brow % 5 == 4
				var xx5 := p.x - (0.0 if brow % 2 == 0 else 26.0)
				while xx5 < p.x + s.x:
					var bwid: float = 40.0 + float((brow * 7 + int(xx5)) % 3) * 14.0
					var blk := Rect2(xx5 + 1.5, yy5 + 1.5, bwid - 3.0, bh - 3.0)
					ci.draw_rect(blk, tile if blue_row else Color(1, 1, 1, 0.92))
					xx5 += bwid
				yy5 += bh
				brow += 1
			# soft mortar shading so the blocks read as stone, not tiles
			var yy6 := p.y
			while yy6 < p.y + s.y:
				ci.draw_line(Vector2(p.x, yy6), Vector2(p.x + s.x, yy6),
					Color(line.r, line.g, line.b, 0.55), 1.2)
				yy6 += bh

		"talavera":
			var t3 := 30.0
			var rows2 := int(s.y / t3) + 2
			var cols2 := int(s.x / t3) + 2
			for r in rows2:
				for c3 in cols2:
					var o := Vector2(p.x + float(c3) * t3, p.y + float(r) * t3)
					ci.draw_rect(Rect2(o, Vector2(t3 - 2.0, t3 - 2.0)), Color(1, 1, 1, 0.55))
					var mid := o + Vector2(t3 * 0.5, t3 * 0.5)
					_diamond(ci, mid, 7.0, tile)
					ci.draw_circle(mid, 2.6, accent)
		"hex":
			var hr := 26.0
			var yy2 := p.y
			var row2 := 0
			while yy2 < p.y + s.y + hr:
				var xx2 := p.x + (0.0 if row2 % 2 == 0 else hr * 0.87)
				while xx2 < p.x + s.x + hr:
					_hex(ci, Vector2(xx2, yy2), hr * 0.82, tile, line)
					xx2 += hr * 1.74
				yy2 += hr * 1.5
				row2 += 1
		"scandi":
			ci.draw_rect(rect, tile)
			var yy3 := p.y
			while yy3 < p.y + s.y:
				ci.draw_line(Vector2(p.x, yy3), Vector2(p.x + s.x, yy3), line, 1.5)
				yy3 += 34.0
		"jaali":
			ci.draw_rect(rect, tile)
			var step2 := 46.0
			var yy4 := p.y
			while yy4 < p.y + s.y + step2:
				var xx4 := p.x
				while xx4 < p.x + s.x + step2:
					ci.draw_arc(Vector2(xx4, yy4), step2 * 0.42, 0.0, TAU, 20,
						Color(line.r, line.g, line.b, 0.8), 2.2, true)
					xx4 += step2
				yy4 += step2
		"deco":
			# The sunburst needed a whole wall to read; stacked chevrons are the
			# same deco language but tile happily down a narrow strip.
			ci.draw_rect(rect, wall)
			var band := 44.0
			var yy6 := p.y - band
			var idx := 0
			while yy6 < p.y + s.y + band:
				var col: Color = tile if idx % 2 == 0 else accent
				var chev := PackedVector2Array([
					Vector2(p.x, yy6 + band * 0.55),
					Vector2(p.x + s.x * 0.5, yy6),
					Vector2(p.x + s.x, yy6 + band * 0.55),
					Vector2(p.x + s.x, yy6 + band * 0.85),
					Vector2(p.x + s.x * 0.5, yy6 + band * 0.30),
					Vector2(p.x, yy6 + band * 0.85)])
				ci.draw_colored_polygon(chev, col)
				yy6 += band
				idx += 1

static func _mix(c: Color, wall: Color, strength: float) -> Color:
	return wall.lerp(c, clampf(strength, 0.0, 1.0))

static func _diamond(ci: CanvasItem, c: Vector2, r: float, col: Color) -> void:
	ci.draw_colored_polygon(PackedVector2Array([
		c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)]), col)

static func _hex(ci: CanvasItem, c: Vector2, r: float, col: Color, line: Color) -> void:
	var pts := PackedVector2Array()
	for i in 6:
		var a: float = PI / 6.0 + TAU * float(i) / 6.0
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	ci.draw_colored_polygon(pts, col)
	pts.append(pts[0])
	ci.draw_polyline(pts, line, 1.2, true)
