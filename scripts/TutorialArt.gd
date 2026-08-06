class_name TutorialArt
extends Control

# Illustrations for the four onboarding slides. Everything is drawn from the
# shared SoapArt / ObstacleArt components, so the tutorial always shows exactly
# what the player will meet in the game.
#
# COMPOSITION RULES (keep these, they are why the four slides don't jump when
# you swipe):
#   * The control is 390 x 492 (HomeScreen puts it at y 60..552).
#   * Every slide's artwork is optically centred on CY and stays inside
#     SIDE .. w - SIDE horizontally.
#   * Nothing is drawn below STAGE_BOT — the white bottom sheet starts there.

const DARK   := Color("#1a1a2e")
const PINK   := Color("#d63384")
const PURPLE := Color("#7c3aed")
const GREY   := Color("#6b7280")
const SKY    := Color("#e0f2fe")
const WATER  := Color("#7dd3fc")
const WATER_D := Color("#38bdf8")
const BLUE_T := Color("#0369a1")
const LANE   := Color("#fbcfe8")
const GREEN  := Color("#86efac")
const GREEN_D := Color("#15803d")
const RED    := Color("#ef4444")

const CY       := 236.0   # shared optical centre of every slide
const SIDE     := 24.0    # horizontal safe margin
const STAGE_BOT := 470.0

@export var kind: String = "logo"

var _t := 0.0

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return
	match kind:
		"logo":      _draw_logo(w)
		"steer":     _draw_steer(w)
		"obstacles": _draw_obstacles(w)
		"water":     _draw_water(w)

# ── 1. Logo + promise ──────────────────────────────────────────────────────

func _draw_logo(w: float) -> void:
	var c := Vector2(w * 0.5, CY + sin(_t * 1.4) * 5.0)
	var hw := 150.0
	var hh := 92.0
	var r  := 46.0
	_poly(SoapArt.rounded_rect(hw, hh, r), c + Vector2(6, 8), Color(DARK.r, DARK.g, DARK.b, 0.18))
	_poly(SoapArt.rounded_rect(hw, hh, r), c, DARK)
	_poly(SoapArt.rounded_rect(hw - 5.0, hh - 5.0, r - 3.0), c, SKY)
	_poly(_water_fill(hw - 5.0, hh - 5.0, r - 3.0, 20.0), c, WATER)
	for b: Array in [[Vector2(-104, 50), 6.0], [Vector2(-66, 64), 4.0], [Vector2(80, 56), 5.0]]:
		draw_arc(c + (b[0] as Vector2), b[1] as float, 0.0, TAU, 16,
			Color(1, 1, 1, 0.6), 1.8, true)
	_arch(c + Vector2(0, -34), 330.0, "Soapy Escape", 34)
	SoapArt.paint(self, c + Vector2(0, 30), 1.7, SoapArt.CALM)

	# floating bubbles fill the field so slide 1 has the same visual weight as
	# the other three and the swipe doesn't feel like it drops a beat
	for b: Array in [[Vector2(52, 92), 20.0], [Vector2(332, 126), 14.0],
			[Vector2(34, 382), 26.0], [Vector2(352, 354), 18.0],
			[Vector2(300, 58), 10.0], [Vector2(88, 428), 13.0]]:
		var bp: Vector2 = b[0] as Vector2
		bp.y += sin(_t * 0.9 + bp.x * 0.05) * 4.0
		draw_arc(bp, b[1] as float, 0.0, TAU, 22,
			Color(PURPLE.r, PURPLE.g, PURPLE.b, 0.18), 1.6, true)

# ── 2. How to steer ────────────────────────────────────────────────────────
# A phone screen split down the middle: touch a half, the soap goes that way.

func _draw_steer(w: float) -> void:
	var cx := w * 0.5
	var hw := 112.0
	var hh := 186.0
	var c  := Vector2(cx, CY)

	# device
	_poly(SoapArt.rounded_rect(hw, hh, 30.0), c + Vector2(5, 7),
		Color(DARK.r, DARK.g, DARK.b, 0.16))
	_poly(SoapArt.rounded_rect(hw, hh, 30.0), c, DARK)
	_poly(SoapArt.rounded_rect(hw - 5.0, hh - 5.0, 27.0), c, Color.WHITE)

	# the two touch halves
	for side: float in [-1.0, 1.0]:
		var half_x := cx + side * 54.0
		_poly(SoapArt.rounded_rect(48.0, 158.0, 22.0), Vector2(half_x, CY),
			Color(PINK.r, PINK.g, PINK.b, 0.09))

		# a finger tap: ripple ring + solid dot, universally readable
		var tap := Vector2(half_x, CY - 86.0)
		draw_arc(tap, 34.0, 0.0, TAU, 32, Color(PINK.r, PINK.g, PINK.b, 0.22), 1.8, true)
		draw_circle(tap, 25.0, Color(PINK.r, PINK.g, PINK.b, 0.13))
		draw_arc(tap, 25.0, 0.0, TAU, 28, Color(PINK.r, PINK.g, PINK.b, 0.45), 2.0, true)
		draw_circle(tap, 12.0, PINK)

		_label_centred(Vector2(half_x, CY - 34.0),
			"HOLD HERE" if side < 0.0 else "OR HERE", Fonts.nunito(800), 12, PINK)

	# dashed split so "left half / right half" is unmistakable
	_dashed_v(cx, CY - 160.0, CY + 152.0, Color(PINK.r, PINK.g, PINK.b, 0.40), 2.0)

	# ← soap → : cause and effect on one line
	var row_y := CY + 96.0
	_arrow(Vector2(cx - 76.0, row_y), -1.0, 16.0, 17.0, PINK)
	_arrow(Vector2(cx + 76.0, row_y),  1.0, 16.0, 17.0, PINK)
	SoapArt.paint(self, Vector2(cx, row_y), 1.55, SoapArt.CALM)

# ── 3. The four obstacles ──────────────────────────────────────────────────

func _draw_obstacles(w: float) -> void:
	var kinds := [ObstacleArt.DUCK, ObstacleArt.GRATE, ObstacleArt.SPONGE, ObstacleArt.COMB]
	var names := ["Rubber duck", "Drain grate", "Sponge", "Comb"]
	var hw := 78.0
	var hh := 68.0
	for i in 4:
		var col := i % 2
		var row := i / 2
		var c := Vector2(w * 0.5 + (-84.0 if col == 0 else 84.0), CY + (-80.0 if row == 0 else 80.0))
		_poly(SoapArt.rounded_rect(hw, hh, 24.0), c + Vector2(0, 5),
			Color(DARK.r, DARK.g, DARK.b, 0.07))
		_poly(SoapArt.rounded_rect(hw, hh, 24.0), c, Color.WHITE)
		ObstacleArt.paint(self, kinds[i], c + Vector2(0, -12), 34.0)
		_label_centred(c + Vector2(0, 50.0), names[i], Fonts.nunito(700), 13, PURPLE)
		_no_badge(c + Vector2(hw - 18.0, -hh + 18.0), 12.0)

# ── 4. The run: water shrinks you, sparkles grow you, flag is the end ──────

func _draw_water(w: float) -> void:
	var cx := w * 0.5
	var hw := 88.0
	var top := 16.0
	var bot := 462.0
	var mid := (top + bot) * 0.5
	var hh  := (bot - top) * 0.5

	_poly(SoapArt.rounded_rect(hw + 4.0, hh + 4.0, 34.0), Vector2(cx, mid), LANE)
	_poly(SoapArt.rounded_rect(hw, hh, 30.0), Vector2(cx, mid), Color.WHITE)
	# dashed centreline, exactly like the real lane in Spawner.gd — it also stops
	# this reading as the phone from slide 2
	_dashed_v(cx, top + 26.0, bot - 26.0, Color(PINK.r, PINK.g, PINK.b, 0.16), 2.0)

	# 1 — your soap, full size
	SoapArt.paint(self, Vector2(cx, 76.0), 1.5, SoapArt.CALM)

	# 2 — the water band (straight part of the lane, so it can never spill)
	var band_top := 122.0
	var band_bot := 240.0
	var band := PackedVector2Array()
	for i in 25:
		var t: float = float(i) / 24.0
		band.append(Vector2(cx - hw + hw * 2.0 * t, band_top + sin(t * PI * 3.0 + _t) * 4.0))
	band.append(Vector2(cx + hw, band_bot))
	band.append(Vector2(cx - hw, band_bot))
	draw_colored_polygon(band, Color(WATER.r, WATER.g, WATER.b, 0.9))

	# the soap in the water is visibly smaller, with squeeze arrows either side
	var small_y := 190.0
	SoapArt.paint(self, Vector2(cx, small_y), 0.95, SoapArt.PANICKED)
	_arrow(Vector2(cx - 40.0, small_y),  1.0, 9.0, 9.0, BLUE_T)
	_arrow(Vector2(cx + 40.0, small_y), -1.0, 9.0, 9.0, BLUE_T)
	_callout(Vector2(cx - hw - 42.0, small_y), "WATER", "shrinks you", BLUE_T)

	# 3 — the green sparkle pickup puts the size back (matches Spawner.gd)
	var grow_y := 300.0
	SoapArt.paint(self, Vector2(cx - 35.0, grow_y), 1.5, SoapArt.CALM)
	_sparkle_orb(Vector2(cx + 39.0, grow_y))
	_callout(Vector2(cx + hw + 42.0, grow_y), "SPARKLE", "grows you", GREEN_D)

	# 4 — the finish flag, centred with its own breathing room
	_flag(Vector2(cx - 28.0, 424.0))
	_label_centred(Vector2(cx, 448.0), "FINISH", Fonts.nunito(800), 13, PINK)

# ── slide parts ────────────────────────────────────────────────────────────

func _sparkle_orb(c: Vector2) -> void:
	draw_circle(c, 22.0, Color(GREEN.r, GREEN.g, GREEN.b, 0.30))
	draw_circle(c, 17.0, Color(GREEN.r, GREEN.g, GREEN.b, 0.92))
	draw_arc(c, 17.0, 0.0, TAU, 24, GREEN_D, 2.0, true)
	_poly(SoapArt.star(Vector2.ZERO, 11.0, 3.6, 4), c, Color.WHITE)

func _flag(base: Vector2) -> void:
	var top := base.y - 62.0
	draw_line(Vector2(base.x, base.y), Vector2(base.x, top), DARK, 4.0, true)
	draw_circle(Vector2(base.x, top), 3.0, DARK)
	var tile := 18.0
	for r in 2:
		for c in 3:
			var even := (r + c) % 2 == 0
			draw_rect(Rect2(base.x + 2.0 + float(c) * tile, top + float(r) * tile, tile, tile),
				PINK if even else Color.WHITE)
	draw_rect(Rect2(base.x + 2.0, top, tile * 3.0, tile * 2.0), DARK, false, 1.6)

func _callout(pos: Vector2, top_text: String, bottom_text: String, col: Color) -> void:
	_label_centred(pos + Vector2(0, -3.0), top_text, Fonts.nunito(800), 11, col)
	_label_centred(pos + Vector2(0, 13.0), bottom_text, Fonts.nunito(600), 11, GREY)

func _no_badge(c: Vector2, r: float) -> void:
	draw_circle(c, r, Color.WHITE)
	draw_arc(c, r - 1.0, 0.0, TAU, 24, RED, 2.4, true)
	var d := (r - 1.0) * 0.70
	draw_line(c + Vector2(-d, d), c + Vector2(d, -d), RED, 2.4, true)

# ── helpers ────────────────────────────────────────────────────────────────

func _arrow(c: Vector2, dir: float, half_len: float, half_h: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(c.x + dir * half_len, c.y),
		Vector2(c.x - dir * half_len, c.y - half_h),
		Vector2(c.x - dir * half_len, c.y + half_h)]), col)

func _dashed_v(x: float, y0: float, y1: float, col: Color, width: float) -> void:
	var y := y0
	while y < y1:
		draw_line(Vector2(x, y), Vector2(x, minf(y + 7.0, y1)), col, width, true)
		y += 13.0

func _water_fill(hw: float, hh: float, r: float, surface_y: float) -> PackedVector2Array:
	var shape := SoapArt.rounded_rect(hw, hh, r)
	var pts := PackedVector2Array()
	for i in 33:
		var t: float = float(i) / 32.0
		pts.append(Vector2(-hw + hw * 2.0 * t, surface_y + sin(t * PI * 3.0) * 5.0))
	var below: Array[Vector2] = []
	for p in shape:
		if p.y > surface_y:
			below.append(p)
	below.sort_custom(func(a: Vector2, b: Vector2): return atan2(a.y, a.x) < atan2(b.y, b.x))
	for p in below:
		pts.append(p)
	return pts

func _arch(pos: Vector2, radius: float, text: String, size_px: int) -> void:
	var f := Fonts.fredoka()
	var centre := pos + Vector2(0.0, radius)
	var widths: Array[float] = []
	var total := 0.0
	for i in text.length():
		var cw := f.get_string_size(text[i], HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
		widths.append(cw)
		total += cw
	var x := -total * 0.5
	var seen_space := false
	for i in text.length():
		var ch := text[i]
		var cw: float = widths[i]
		if ch == " ":
			seen_space = true
			x += cw
			continue
		var a: float = -PI * 0.5 + ((x + cw * 0.5) / radius)
		var p := centre + Vector2(cos(a), sin(a)) * radius
		draw_set_transform(p, a + PI * 0.5, Vector2.ONE)
		draw_string(f, Vector2(-cw * 0.5, size_px * 0.34), ch, HORIZONTAL_ALIGNMENT_LEFT, -1,
			size_px, PURPLE if seen_space else PINK)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		x += cw

func _label_centred(pos: Vector2, text: String, f: Font, size_px: int, col: Color) -> void:
	var tw := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
	draw_string(f, pos - Vector2(tw * 0.5, 0.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, col)

func _poly(pts: PackedVector2Array, off: Vector2, col: Color) -> void:
	var moved := PackedVector2Array()
	for p in pts:
		moved.append(p + off)
	draw_colored_polygon(moved, col)
