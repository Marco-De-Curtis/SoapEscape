class_name ObstacleArt
extends RefCounted

# SINGLE SOURCE OF TRUTH for how the four obstacles look, so the in-game world
# and the tutorial screens can never drift apart (same reasoning as SoapArt).
# Everything is immediate-mode: call paint() from a CanvasItem's _draw().

enum { DUCK, GRATE, SPONGE, COMB }

const NAMES := ["Rubber duck", "Drain grate", "Sponge", "Comb"]

const OUTLINE     := Color("#1a1a2e")
const DUCK_Y      := Color("#fde047")
const DUCK_Y2     := Color("#fef08a")
const BEAK        := Color("#fb923c")
const GREY_L      := Color("#6b7280")
const GREY_D      := Color("#4b5563")
const GREY_XD     := Color("#1f2937")
const SPONGE_Y    := Color("#fde047")
const SPONGE_G    := Color("#bef264")
const SPONGE_PORE := Color("#ca8a04")
const COMB_TEAL   := Color("#2dd4bf")
const COMB_TEAL_D := Color("#14b8a6")
const HAIR        := Color("#4a4340")
const HAIR_L      := Color("#6b625c")
const BLUSH       := Color(0.95, 0.56, 0.70, 0.5)

## Paints obstacle `kind` centred on `centre`, sized to `radius`
## (the same radius the gameplay collision uses).
static func paint(ci: CanvasItem, kind: int, centre: Vector2, radius: float) -> void:
	match kind:
		DUCK:   _duck(ci, centre, radius / 24.0)
		GRATE:  _grate(ci, centre, radius / 24.0)
		SPONGE: _sponge(ci, centre, radius / 24.0)
		COMB:   _comb(ci, centre, radius / 24.0)

# ── Rubber duck — the beak is what makes it read as a duck ─────────────────

static func _duck(ci: CanvasItem, c: Vector2, s: float) -> void:
	_fill(ci, _ellipse(Vector2(-1, 5) * s, 21.0 * s, 14.0 * s, 22), c, OUTLINE)
	_fill(ci, _ellipse(Vector2(-1, 5) * s, 18.5 * s, 11.5 * s, 22), c, DUCK_Y)
	_fill(ci, _scale([Vector2(-19, 1), Vector2(-27, -5), Vector2(-18, 7)], s), c, OUTLINE)
	_fill(ci, _scale([Vector2(-18, 1), Vector2(-24, -3), Vector2(-17, 5)], s), c, DUCK_Y)
	_fill(ci, SoapArt.circle(Vector2(11, -9) * s, 12.5 * s, 20), c, OUTLINE)
	_fill(ci, SoapArt.circle(Vector2(11, -9) * s, 10.5 * s, 20), c, DUCK_Y2)
	_fill(ci, _scale([Vector2(19, -11), Vector2(31, -8.5), Vector2(19, -4)], s), c, OUTLINE)
	_fill(ci, _scale([Vector2(19.5, -10), Vector2(28.5, -8.4), Vector2(19.5, -5.4)], s), c, BEAK)
	_fill(ci, _ellipse(Vector2(-3, 6) * s, 8.0 * s, 5.5 * s, 14), c, DUCK_Y2)
	_fill(ci, SoapArt.circle(Vector2(13, -12) * s, 3.4 * s, 12), c, OUTLINE)
	_fill(ci, SoapArt.circle(Vector2(14, -13) * s, 1.3 * s, 8), c, Color.WHITE)
	_fill(ci, SoapArt.circle(Vector2(6, -6) * s, 3.0 * s, 10), c, BLUSH)

# ── Drain grate — round, so it reads apart from the boxy ones ──────────────

static func _grate(ci: CanvasItem, c: Vector2, s: float) -> void:
	_fill(ci, SoapArt.circle(Vector2.ZERO, 22.0 * s, 26), c, OUTLINE)
	_fill(ci, SoapArt.circle(Vector2.ZERO, 19.5 * s, 26), c, GREY_L)
	_fill(ci, SoapArt.circle(Vector2.ZERO, 15.0 * s, 24), c, GREY_D)
	for i in 8:
		var a: float = TAU * float(i) / 8.0
		var d := Vector2(cos(a), sin(a))
		ci.draw_line(c + d * 6.0 * s, c + d * 14.0 * s, GREY_XD, maxf(0.6, 2.6 * s), true)
	_fill(ci, SoapArt.circle(Vector2.ZERO, 5.5 * s, 16), c, GREY_L)
	_fill(ci, SoapArt.circle(Vector2(-7, -6) * s, 3.2 * s, 10), c, Color.WHITE)
	_fill(ci, SoapArt.circle(Vector2(-7, -6) * s, 1.8 * s, 8), c, OUTLINE)
	_fill(ci, SoapArt.circle(Vector2(7, -6) * s, 3.2 * s, 10), c, Color.WHITE)
	_fill(ci, SoapArt.circle(Vector2(7, -6) * s, 1.8 * s, 8), c, OUTLINE)
	ci.draw_line(c + Vector2(-4.5, 9) * s, c + Vector2(4.5, 9) * s, OUTLINE, maxf(0.6, 2.0 * s), true)

# ── Sponge — two-tone kitchen sponge ──────────────────────────────────────

static func _sponge(ci: CanvasItem, c: Vector2, s: float) -> void:
	_fill(ci, SoapArt.rounded_rect(23.0 * s, 16.0 * s, 5.0 * s), c, OUTLINE)
	_fill(ci, _at(SoapArt.rounded_rect(20.5 * s, 10.5 * s, 4.0 * s), Vector2(0, 3) * s), c, SPONGE_Y)
	_fill(ci, _at(SoapArt.rounded_rect(20.5 * s, 5.0 * s, 3.0 * s), Vector2(0, -8.5) * s), c, SPONGE_G)
	for p in [Vector2(-13, 5), Vector2(0, 8), Vector2(13, 4), Vector2(-6, 2)]:
		_fill(ci, SoapArt.circle(p * s, 2.0 * s, 8), c, SPONGE_PORE)
	_fill(ci, SoapArt.circle(Vector2(-6.5, 1) * s, 3.4 * s, 12), c, OUTLINE)
	_fill(ci, SoapArt.circle(Vector2(-5.5, 0) * s, 1.3 * s, 8), c, Color.WHITE)
	_fill(ci, SoapArt.circle(Vector2(6.5, 1) * s, 3.4 * s, 12), c, OUTLINE)
	_fill(ci, SoapArt.circle(Vector2(7.5, 0) * s, 1.3 * s, 8), c, Color.WHITE)
	_line(ci, _arc(Vector2(0, 6) * s, 4.6 * s, 0.1, 0.9), c, OUTLINE, 1.9 * s)

# ── Comb with hair caught in the teeth ────────────────────────────────────

static func _comb(ci: CanvasItem, c: Vector2, s: float) -> void:
	var span := 19.0 * s
	for i in 6:
		var t: float = float(i) / 5.0
		var x: float = -span + span * 2.0 * t
		_fill(ci, _at(SoapArt.rounded_rect(2.9 * s, 7.0 * s, 1.6 * s), Vector2(x, 4.0 * s)), c, OUTLINE)
		_fill(ci, _at(SoapArt.rounded_rect(1.7 * s, 5.6 * s, 1.0 * s), Vector2(x, 4.0 * s)), c, COMB_TEAL_D)
	_fill(ci, _at(SoapArt.rounded_rect(22.0 * s, 7.5 * s, 3.5 * s), Vector2(0, -9) * s), c, OUTLINE)
	_fill(ci, _at(SoapArt.rounded_rect(19.5 * s, 5.6 * s, 2.8 * s), Vector2(0, -9) * s), c, COMB_TEAL)
	_line(ci, _curve(Vector2(4, 0) * s, Vector2(16, 6) * s, Vector2(21, 16) * s), c, HAIR, 3.4 * s)
	_line(ci, _curve(Vector2(9, 0) * s, Vector2(20, 8) * s, Vector2(26, 14) * s), c, HAIR, 3.0 * s)
	_line(ci, _curve(Vector2(14, 0) * s, Vector2(22, 3) * s, Vector2(29, 10) * s), c, HAIR, 2.4 * s)
	_line(ci, _curve(Vector2(7, 2) * s, Vector2(17, 10) * s, Vector2(20, 21) * s), c, HAIR_L, 1.6 * s)
	_line(ci, _curve(Vector2(-18, 2) * s, Vector2(-24, 9) * s, Vector2(-19, 15) * s), c, HAIR, 2.2 * s)
	var fc := Vector2(-3, -9) * s
	_fill(ci, SoapArt.circle(fc + Vector2(-5, 0) * s, 2.9 * s, 12), c, Color.WHITE)
	_fill(ci, SoapArt.circle(fc + Vector2(-5, 0) * s, 1.6 * s, 8), c, OUTLINE)
	_fill(ci, SoapArt.circle(fc + Vector2(5, 0) * s, 2.9 * s, 12), c, Color.WHITE)
	_fill(ci, SoapArt.circle(fc + Vector2(5, 0) * s, 1.6 * s, 8), c, OUTLINE)
	_line(ci, _arc(fc + Vector2(0, 2.6) * s, 2.6 * s, 0.2, 0.8), c, OUTLINE, 1.4 * s)
	_fill(ci, SoapArt.circle(fc + Vector2(-10.5, 1.6) * s, 2.2 * s, 10), c, BLUSH)
	_fill(ci, SoapArt.circle(fc + Vector2(10.5, 1.6) * s, 2.2 * s, 10), c, BLUSH)

# ── helpers ───────────────────────────────────────────────────────────────

static func _fill(ci: CanvasItem, pts: PackedVector2Array, off: Vector2, col: Color) -> void:
	ci.draw_colored_polygon(_at(pts, off), col)

static func _line(ci: CanvasItem, pts: PackedVector2Array, off: Vector2, col: Color, w: float) -> void:
	ci.draw_polyline(_at(pts, off), col, maxf(0.6, w), true)

static func _at(pts: PackedVector2Array, off: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(p + off)
	return out

static func _scale(pts: Array, s: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(p * s)
	return out

static func _ellipse(c: Vector2, rw: float, rh: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a: float = TAU * float(i) / float(n)
		pts.append(c + Vector2(cos(a) * rw, sin(a) * rh))
	return pts

static func _curve(p0: Vector2, p1: Vector2, p2: Vector2) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 13:
		var t: float = float(i) / 12.0
		var u: float = 1.0 - t
		pts.append(p0 * (u * u) + p1 * (2.0 * u * t) + p2 * (t * t))
	return pts

static func _arc(c: Vector2, r: float, t0: float, t1: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 13:
		var t: float = t0 + (t1 - t0) * float(i) / 12.0
		var a: float = PI * t
		pts.append(c + Vector2(-cos(a) * r, sin(a) * r))
	return pts
