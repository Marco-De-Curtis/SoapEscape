class_name SoapArt
extends RefCounted

# SINGLE SOURCE OF TRUTH for how the soap character looks.
#
# The character used to be redrawn by hand in six different files (the in-game
# Soap plus five UI screens), which is how the gameplay soap and the menu soap
# drifted into two different designs. Everything now comes from here:
#   * Soap.gd feeds these shapes into its persistent Polygon2D/Line2D nodes.
#   * UI screens call paint() for immediate-mode drawing in _draw().
# Change a number here and every screen follows.

const BASE_WIDTH:  float = 36.0
const BASE_HEIGHT: float = 20.0

const OUTLINE_COLOR := Color("#1a1a2e")
const CHEEK_COLOR   := Color(0.95, 0.56, 0.70, 0.72)
const SHEEN_COLOR   := Color(1.0, 1.0, 1.0, 0.34)
const SHINE_COLOR   := Color(1.0, 1.0, 1.0, 0.90)
const SPARK_COLOR   := Color(1.0, 1.0, 1.0, 0.75)
const STAR_EYE_COLOR := Color("#f59e0b")

# Sticker-rim double layer, between the outline and the fill. Violet first —
# the lane itself is near-white (Spawner.gd's lane fill is
# Color(1,1,1,0.92)), so a plain white rim alone washed out against it. The
# same brand purple used everywhere else in the UI, not a new one-off color.
const VIOLET_BAND_COLOR := Color("#7c3aed")
const WHITE_BAND_COLOR  := Color("#ffffff")

# Body fill per state (0 calm, 1 worried, 2 panicked, 3 critical)
const FILL_COLORS: Array[Color] = [
	Color("#c4b5fd"),  # calm     — lavender
	Color("#fde047"),  # worried  — yellow
	Color("#fb923c"),  # panicked — orange
	Color("#e11d48"),  # critical — red
]

# Face states
enum { CALM, WORRIED, PANICKED, CRITICAL, VICTORY }

# ── Shape metrics ──────────────────────────────────────────────────────────

# Features shrink slightly faster than the body: the body bottoms out at
# 10x6 px (collision floor) while the face would keep its ratio, leaving the
# small states edge-to-edge with no breathing room.
static func tightness(w: float) -> float:
	var t := clampf((w - 10.0) / (BASE_WIDTH - 10.0), 0.0, 1.0)
	return lerpf(0.80, 1.0, t)

static func body_radius(hw: float, hh: float) -> float:
	return minf(hw, hh) * 0.80  # near-pill, pillowy soap-bar roundness

static func eye_offset(w: float, h: float) -> Vector2:
	var tight := tightness(w)
	return Vector2(w * 0.255 * tight, -h * 0.09 * tight)

static func eye_radius(w: float, state: int) -> float:
	var tight := tightness(w)
	match state:
		WORRIED:  return w * 0.118 * tight
		PANICKED: return w * 0.130 * tight
		CRITICAL: return w * 0.072 * tight
		VICTORY:  return w * 0.096 * tight
		_:        return w * 0.128 * tight

static func eye_segments(state: int) -> int:
	return 10 if state == CRITICAL else 16

static func mouth_width(w: float) -> float:
	# No upper cap: in play the soap is at most 36px wide so this never exceeds
	# ~2.2 anyway, but the logo and the 1024px app icon draw the same character
	# far larger, and a fixed cap left them with a hairline smile.
	return maxf(0.6, w * 0.060)

static func cheek_alpha(state: int) -> float:
	match state:
		WORRIED:  return 0.65
		PANICKED: return 0.35
		CRITICAL: return 0.0
		_:        return 1.0

static func has_eye_shine(state: int) -> bool:
	return state == CALM or state == WORRIED or state == PANICKED

static func cheek_centre(w: float, h: float) -> Vector2:
	return Vector2(w * 0.335, h * 0.24)

static func cheek_radius(w: float) -> float:
	return w * 0.098

static func cheek_color(state: int) -> Color:
	var a := cheek_alpha(state)
	return Color(CHEEK_COLOR.r, CHEEK_COLOR.g, CHEEK_COLOR.b, CHEEK_COLOR.a * a)

static func fill_color(state: int) -> Color:
	if state == VICTORY:
		return FILL_COLORS[CALM]
	return FILL_COLORS[mini(state, FILL_COLORS.size() - 1)]

# ── Geometry ───────────────────────────────────────────────────────────────

static func rounded_rect(hw: float, hh: float, r: float) -> PackedVector2Array:
	# 8 points per corner — 3 made the silhouette read as a faceted octagon.
	const CORNER_STEPS := 8
	r = minf(r, minf(hw, hh) * 0.99)
	var pts := PackedVector2Array()
	var ccx := PackedFloat32Array([-hw + r,  hw - r,  hw - r, -hw + r])
	var ccy := PackedFloat32Array([-hh + r, -hh + r,  hh - r,  hh - r])
	var ca0 := PackedFloat32Array([PI, -PI * 0.5, 0.0, PI * 0.5])
	for i in 4:
		for j in CORNER_STEPS:
			var a: float = ca0[i] + PI * 0.5 * float(j) / float(CORNER_STEPS - 1)
			pts.append(Vector2(ccx[i] + cos(a) * r, ccy[i] + sin(a) * r))
	return pts

static func circle(centre: Vector2, radius: float, steps: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in steps:
		var a: float = TAU * float(i) / float(steps)
		pts.append(centre + Vector2(cos(a), sin(a)) * radius)
	return pts

static func star(centre: Vector2, outer: float, inner: float, points: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in points * 2:
		var a := -PI * 0.5 + TAU * float(i) / float(points * 2)
		var r := outer if i % 2 == 0 else inner
		pts.append(centre + Vector2(cos(a), sin(a)) * r)
	return pts

static func sheen(hw: float, hh: float) -> PackedVector2Array:
	var streak := rounded_rect(hw * 0.50, maxf(0.6, hh * 0.11), maxf(0.6, hh * 0.11))
	var moved := PackedVector2Array()
	for p in streak:
		moved.append(p + Vector2(-hw * 0.12, -hh * 0.60))
	return moved

static func body_outline(hw: float, hh: float) -> PackedVector2Array:
	return rounded_rect(hw, hh, body_radius(hw, hh))

# Band widths are absolute (relative to a reference hw of 18, i.e. BASE_WIDTH
# at scale 1.0) rather than proportional like the old single-step fill inset
# below, so a thin rim doesn't disappear at small sizes the way a percentage
# inset would. Tuned against the soap's true 36x20 in-game size, not just how
# it looks blown up in a mockup.
const _VIOLET_BAND: float = 0.80 / 18.0
const _WHITE_BAND:  float = 1.15 / 18.0
const _FILL_GAP:    float = 0.55 / 18.0

static func body_violet(hw: float, hh: float) -> PackedVector2Array:
	var vw := hw * _VIOLET_BAND
	var r  := maxf(hw * (0.35 / 18.0), body_radius(hw, hh) - vw)
	return rounded_rect(hw - vw, hh - vw, r)

static func body_white(hw: float, hh: float) -> PackedVector2Array:
	var vw := hw * _VIOLET_BAND
	var ww := hw * _WHITE_BAND
	var r  := maxf(hw * (0.30 / 18.0), body_radius(hw, hh) - vw - ww)
	return rounded_rect(hw - vw - ww, hh - vw - ww, r)

static func body_fill(hw: float, hh: float) -> PackedVector2Array:
	var vw  := hw * _VIOLET_BAND
	var ww  := hw * _WHITE_BAND
	var gap := hw * _FILL_GAP
	var r   := maxf(hw * (0.25 / 18.0), body_radius(hw, hh) - vw - ww - gap)
	return rounded_rect(hw - vw - ww - gap, hh - vw - ww - gap, r)

# ── Eye highlights ─────────────────────────────────────────────────────────

static func eye_shine(eye_centre: Vector2, er: float) -> PackedVector2Array:
	var so := er * 0.34
	return circle(eye_centre + Vector2(so, -so), er * 0.38, 10)

static func eye_spark(eye_centre: Vector2, er: float) -> PackedVector2Array:
	return circle(eye_centre + Vector2(-er * 0.36, er * 0.40), er * 0.17, 8)

# ── Mouth shapes ───────────────────────────────────────────────────────────

static func _quad(p0: Vector2, p1: Vector2, p2: Vector2) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 9:
		var t: float = float(i) / 8.0
		var u: float = 1.0 - t
		pts.append(p0 * (u * u) + p1 * (2.0 * u * t) + p2 * (t * t))
	return pts

static func smile(w: float, h: float) -> PackedVector2Array:
	# Small mouth relative to the big eyes — that ratio is the whole trick
	var my := h * 0.22
	var hx := w * 0.125
	return _quad(Vector2(-hx, my), Vector2(0.0, my + h * 0.24), Vector2(hx, my))

static func frown(w: float, h: float) -> PackedVector2Array:
	var my := h * 0.30
	var hx := w * 0.17
	return _quad(Vector2(-hx, my), Vector2(0.0, my - h * 0.26), Vector2(hx, my))

static func flat_mouth(w: float, h: float) -> PackedVector2Array:
	var my := h * 0.26
	return PackedVector2Array([
		Vector2(-w * 0.18, my + h * 0.04),
		Vector2( w * 0.18, my + h * 0.04),
	])

static func o_mouth(w: float, h: float) -> PackedVector2Array:
	var cy := h * 0.28
	var rw := w * 0.10
	var rh := h * 0.09
	var pts := PackedVector2Array()
	for i in 9:
		var a := TAU * float(i) / 8.0
		pts.append(Vector2(cos(a) * rw, cy + sin(a) * rh))
	return pts

static func mouth_points(w: float, h: float, state: int) -> PackedVector2Array:
	match state:
		WORRIED:  return flat_mouth(w, h)
		PANICKED: return o_mouth(w, h)
		CRITICAL: return frown(w, h)
		_:        return smile(w, h)

# ── Immediate-mode painting (used by every UI screen) ──────────────────────

## Draws the whole character centred on `centre`, sized `BASE_WIDTH*scale` wide.
## `state` is one of CALM/WORRIED/PANICKED/CRITICAL/VICTORY.
## `fill_override` lets skins/screens tint the body; leave transparent for default.
static func paint(ci: CanvasItem, centre: Vector2, scale: float, state: int,
		fill_override: Color = Color(0, 0, 0, 0)) -> void:
	var w  := BASE_WIDTH * scale
	var h  := BASE_HEIGHT * scale
	var hw := w * 0.5
	var hh := h * 0.5

	var fill := fill_override if fill_override.a > 0.0 else fill_color(state)

	_fill_at(ci, body_outline(hw, hh), centre, OUTLINE_COLOR)
	_fill_at(ci, body_violet(hw, hh), centre, VIOLET_BAND_COLOR)
	_fill_at(ci, body_white(hw, hh), centre, WHITE_BAND_COLOR)
	_fill_at(ci, body_fill(hw, hh), centre, fill)
	_fill_at(ci, sheen(hw, hh), centre, SHEEN_COLOR)
	paint_face_only(ci, centre, scale, state)

## Face + cheeks only — for callers that paint their own body (e.g. skins with
## a gradient or patterned fill).
static func paint_face_only(ci: CanvasItem, centre: Vector2, scale: float, state: int) -> void:
	var w  := BASE_WIDTH * scale
	var h  := BASE_HEIGHT * scale

	# Cheeks sit behind the eyes
	var ca := cheek_alpha(state)
	if ca > 0.0:
		var cc := cheek_centre(w, h)
		var cr := cheek_radius(w)
		var col := cheek_color(state)
		_fill_at(ci, circle(Vector2(-cc.x, cc.y), cr, 10), centre, col)
		_fill_at(ci, circle(Vector2( cc.x, cc.y), cr, 10), centre, col)

	# Eyes
	var eo := eye_offset(w, h)
	var ey := eo.y
	if state == PANICKED:
		ey -= h * 0.02
	var er := eye_radius(w, state)
	var l_eye := Vector2(-eo.x, ey)
	var r_eye := Vector2( eo.x, ey)

	if state == VICTORY:
		_fill_at(ci, star(l_eye, er, er * 0.45, 5), centre, STAR_EYE_COLOR)
		_fill_at(ci, star(r_eye, er, er * 0.45, 5), centre, STAR_EYE_COLOR)
	else:
		var segs := eye_segments(state)
		_fill_at(ci, circle(l_eye, er, segs), centre, OUTLINE_COLOR)
		_fill_at(ci, circle(r_eye, er, segs), centre, OUTLINE_COLOR)
		if has_eye_shine(state):
			_fill_at(ci, eye_shine(l_eye, er), centre, SHINE_COLOR)
			_fill_at(ci, eye_shine(r_eye, er), centre, SHINE_COLOR)
			_fill_at(ci, eye_spark(l_eye, er), centre, SPARK_COLOR)
			_fill_at(ci, eye_spark(r_eye, er), centre, SPARK_COLOR)

	# Mouth
	var mp := mouth_points(w, h, state)
	var moved := PackedVector2Array()
	for p in mp:
		moved.append(p + centre)
	ci.draw_polyline(moved, OUTLINE_COLOR, mouth_width(w), true)

static func _fill_at(ci: CanvasItem, pts: PackedVector2Array, offset: Vector2, col: Color) -> void:
	var moved := PackedVector2Array()
	for p in pts:
		moved.append(p + offset)
	ci.draw_colored_polygon(moved, col)
