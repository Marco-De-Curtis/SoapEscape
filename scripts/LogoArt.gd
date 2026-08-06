class_name LogoArt
extends RefCounted

# SINGLE SOURCE OF TRUTH for the Soap Escape logo.
# Two lockups share one recipe (sky, wavy water, floating soap, arched name):
#   paint_wide()  — horizontal sticker, for the Home screen
#   paint_badge() — square badge, for the app icon
# NOTE: draw_set_transform() is absolute in Godot, so shapes are rotated into
# place by hand and the transform is only ever used for one glyph at a time.

const DARK   := Color("#1a1a2e")
const PINK   := Color("#d63384")
const PURPLE := Color("#7c3aed")
const RED    := Color("#e11d48")
const SKY    := Color("#e0f2fe")
const WATER  := Color("#7dd3fc")

const TILT := -3.0  # degrees; a straight logo reads as a UI panel, not a sticker

## Horizontal lockup. `scale` 1.0 ≈ 304x172 px.
static func paint_wide(ci: CanvasItem, centre: Vector2, scale: float = 1.0,
		extras: bool = false) -> void:
	var ang := deg_to_rad(TILT)
	var hw := 152.0 * scale
	var hh := 86.0 * scale
	var r  := 44.0 * scale

	_poly(ci, _wp(centre + Vector2(6, 7) * scale, ang, SoapArt.rounded_rect(hw, hh, r)), DARK)
	_poly(ci, _wp(centre, ang, SoapArt.rounded_rect(hw, hh, r)), DARK)
	_poly(ci, _wp(centre, ang, SoapArt.rounded_rect(hw - 5.0 * scale, hh - 5.0 * scale, r - 3.0 * scale)), SKY)
	_poly(ci, _wp(centre, ang, water(hw - 5.0 * scale, hh - 5.0 * scale, r - 3.0 * scale, 20.0 * scale)), WATER)

	for b in [[Vector2(-98, 50), 6.0], [Vector2(-62, 62), 4.0],
			[Vector2(72, 56), 5.0], [Vector2(106, 42), 3.5]]:
		ci.draw_arc(centre + ((b[0] as Vector2) * scale).rotated(ang), float(b[1]) * scale,
			0.0, TAU, 16, Color(1, 1, 1, 0.6), 1.8 * scale, true)

	arch_text(ci, centre + Vector2(0, -34).rotated(ang) * scale, ang, 330.0 * scale,
		"Soap Escape", int(34.0 * scale), PINK, PURPLE)
	SoapArt.paint(ci, centre + Vector2(0, 24).rotated(ang) * scale, 1.65 * scale, SoapArt.CALM)

	if extras:
		_poly(ci, _wp(centre + Vector2(0, 62).rotated(ang) * scale, ang,
			SoapArt.rounded_rect(94.0 * scale, 12.0 * scale, 12.0 * scale)), PINK)
		ci.draw_circle(centre + Vector2(124, -58).rotated(ang) * scale, 15.0 * scale, RED)

## App Store icon. Deliberately different from the badge lockup: Apple renders
## this at ~60px on a home screen, so it carries NO text, no small props and a
## single large character. Fills `rect` edge to edge, fully opaque, square
## corners — Apple applies the mask itself.
static func paint_icon(ci: CanvasItem, rect: Rect2) -> void:
	var p := rect.position
	var s := rect.size
	var u := s.x / 1024.0  # everything below is authored against a 1024 canvas

	ci.draw_rect(rect, SKY)

	# Water fills the lower third with a wavy surface, so the scene reads as
	# "soap in a bath" without needing a single prop.
	var surface := p.y + s.y * 0.60
	var wave := PackedVector2Array()
	for i in 65:
		var t: float = float(i) / 64.0
		wave.append(Vector2(p.x + s.x * t, surface + sin(t * PI * 2.6) * 26.0 * u))
	wave.append(Vector2(p.x + s.x, p.y + s.y))
	wave.append(Vector2(p.x, p.y + s.y))
	ci.draw_colored_polygon(wave, WATER)

	# A lighter band just under the surface gives the water some depth
	var band := PackedVector2Array()
	for i in 65:
		var t: float = float(i) / 64.0
		band.append(Vector2(p.x + s.x * t, surface + sin(t * PI * 2.6) * 26.0 * u))
	for i in 65:
		var t: float = 1.0 - float(i) / 64.0
		band.append(Vector2(p.x + s.x * t, surface + sin(t * PI * 2.6) * 26.0 * u + 62.0 * u))
	ci.draw_colored_polygon(band, Color(1, 1, 1, 0.16))

	# Bubbles: few and large, so they survive being scaled to a home screen
	for b in [[Vector2(150, 800), 46.0], [Vector2(300, 905), 30.0],
			  [Vector2(880, 830), 38.0], [Vector2(742, 940), 24.0]]:
		var c := p + (b[0] as Vector2) * u
		ci.draw_arc(c, float(b[1]) * u, 0.0, TAU, 40, Color(1, 1, 1, 0.75), 7.0 * u, true)

	# The character, big enough to be the whole story
	SoapArt.paint(ci, p + Vector2(512.0, 470.0) * u, 15.6 * u, SoapArt.CALM)

## Square lockup — works down to app-icon sizes.
static func paint_badge(ci: CanvasItem, centre: Vector2, scale: float = 1.0) -> void:
	var ang := deg_to_rad(TILT)
	var hw := 86.0 * scale
	_poly(ci, _wp(centre, ang, SoapArt.rounded_rect(hw, hw, 48.0 * scale)), DARK)
	var inner := 81.0 * scale
	_poly(ci, _wp(centre, ang, SoapArt.rounded_rect(inner, inner, 45.0 * scale)), SKY)
	_poly(ci, _wp(centre, ang, water(inner, inner, 45.0 * scale, 26.0 * scale)), WATER)
	for b in [[Vector2(-42, 52), 6.0], [Vector2(30, 60), 4.5], [Vector2(52, 44), 3.5]]:
		ci.draw_arc(centre + ((b[0] as Vector2) * scale).rotated(ang), float(b[1]) * scale,
			0.0, TAU, 16, Color(1, 1, 1, 0.6), 1.8 * scale, true)
	arch_text(ci, centre + Vector2(0, -44).rotated(ang) * scale, ang, 260.0 * scale,
		"Soap Escape", int(21.0 * scale), PINK, PURPLE)
	SoapArt.paint(ci, centre + Vector2(0, 16).rotated(ang) * scale, 1.45 * scale, SoapArt.CALM)

## Wavy surface plus the part of the rounded rect below it, so the fill can
## never spill past the rounded corners.
static func water(hw: float, hh: float, r: float, surface_y: float) -> PackedVector2Array:
	var shape := SoapArt.rounded_rect(hw, hh, r)
	var pts := PackedVector2Array()
	for i in 41:
		var t: float = float(i) / 40.0
		pts.append(Vector2(-hw + hw * 2.0 * t, surface_y + sin(t * PI * 3.0) * 6.0))
	var below: Array[Vector2] = []
	for p in shape:
		if p.y > surface_y:
			below.append(p)
	below.sort_custom(func(a: Vector2, b: Vector2): return atan2(a.y, a.x) < atan2(b.y, b.x))
	for p in below:
		pts.append(p)
	return pts

## Characters along a gentle arch, spaced by real glyph width (equal-angle
## spacing bunches them up and they overlap).
static func arch_text(ci: CanvasItem, pos: Vector2, ang: float, radius: float,
		text: String, size_px: int, col_a: Color, col_b: Color) -> void:
	var f := Fonts.fredoka()
	var centre := pos + Vector2(0.0, radius).rotated(ang)
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
		var p := centre + (Vector2(cos(a), sin(a)) * radius).rotated(ang)
		ci.draw_set_transform(p, a + PI * 0.5 + ang, Vector2.ONE)
		ci.draw_string(f, Vector2(-cw * 0.5, size_px * 0.34), ch, HORIZONTAL_ALIGNMENT_LEFT,
			-1, size_px, col_b if seen_space else col_a)
		ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		x += cw

static func _wp(c: Vector2, ang: float, pts: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(c + p.rotated(ang))
	return out

static func _poly(ci: CanvasItem, pts: PackedVector2Array, col: Color) -> void:
	ci.draw_colored_polygon(pts, col)
