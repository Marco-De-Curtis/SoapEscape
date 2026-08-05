class_name MapScreen
extends Control

const NODE_POSITIONS: Array[Vector2] = [
	Vector2( 90, 720), Vector2(280, 650),
	Vector2(110, 578), Vector2(276, 508),
	Vector2(105, 436), Vector2(268, 364),
	Vector2(110, 292), Vector2(276, 220),
	Vector2(105, 148), Vector2(268,  76)
]

const C_PATH   := Color("#f9a8d4")
const C_DONE   := Color("#86efac")
const C_LOCKED := Color("#e5e7eb")
const C_PURPLE := Color("#7c3aed")
const C_PINK   := Color("#d63384")


@onready var bg:         ColorRect = $Background
@onready var nodes_root: Control   = $LevelNodes

func _ready() -> void:
	bg.color = Color("#fdf2f8")  # color_bg_app
	_build_grid()
	_build_path()
	_build_bubbles()
	_build_top_bar()
	_build_nodes()

# ── Background grid (rgba(249,168,212,0.1), 22x22 — from main README, not the tokens file) ──

func _build_grid() -> void:
	var grid := Control.new()
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var gs := GDScript.new()
	gs.source_code = """extends Control
func _draw() -> void:
	var c := Color(0.9765, 0.6588, 0.8314, 0.1)
	var step := 22.0
	var x := 0.0
	while x < size.x:
		draw_line(Vector2(x, 0.0), Vector2(x, size.y), c, 1.0)
		x += step
	var y := 0.0
	while y < size.y:
		draw_line(Vector2(0.0, y), Vector2(size.x, y), c, 1.0)
		y += step
"""
	gs.reload()
	grid.set_script(gs)
	add_child(grid)

# ── Top bar ────────────────────────────────────────────────────────────────

func _build_top_bar() -> void:
	var bar := ColorRect.new()
	bar.color = Color(1.0, 1.0, 1.0, 0.92)
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.custom_minimum_size = Vector2(0.0, 56.0)
	add_child(bar)

	var title := Label.new()
	title.text = "Soap Escape"
	title.add_theme_font_override("font", Fonts.fredoka())
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", C_PINK)
	title.position = Vector2(16.0, 12.0)
	bar.add_child(title)

	# Right-side status: next unlocked level, or "All levels complete" past the last one
	var next_unlocked := 1
	for lv: Dictionary in LevelData.LEVELS:
		var lid := int(lv.get("id", 1))
		if SaveData.is_level_complete(lid):
			next_unlocked = lid + 1
	var status_text: String
	if next_unlocked > LevelData.LEVELS.size():
		status_text = "All levels complete ✦"
	else:
		status_text = "Level %d unlocked ✦" % next_unlocked

	var status := Label.new()
	status.text = status_text
	status.add_theme_font_override("font", _nv(700))
	status.add_theme_font_size_override("font_size", 13)
	status.add_theme_color_override("font_color", C_PURPLE)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	status.anchor_left  = 1.0; status.anchor_right  = 1.0
	status.offset_left  = -220.0; status.offset_right = -16.0
	status.offset_top   = 0.0;    status.offset_bottom = 56.0
	bar.add_child(status)

	var border := ColorRect.new()
	border.color = C_PATH
	border.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	border.custom_minimum_size = Vector2(0.0, 2.0)
	bar.add_child(border)

	_build_dynamic_island()

func _build_dynamic_island() -> void:
	var island := Panel.new()
	var sty := StyleBoxFlat.new()
	sty.bg_color = Color("#1a1a2e")  # color_outline_dark
	sty.set_corner_radius_all(18)
	island.add_theme_stylebox_override("panel", sty)
	island.mouse_filter = Control.MOUSE_FILTER_IGNORE
	island.anchor_left  = 0.5; island.anchor_right  = 0.5
	island.offset_left  = -63.0; island.offset_right = 63.0
	island.offset_top    = 12.0; island.offset_bottom = 49.0
	add_child(island)

# ── Dashed path ────────────────────────────────────────────────────────────

func _build_path() -> void:
	# Free the placeholder Line2D from the .tscn
	var old := get_node_or_null("PathLine")
	if old:
		old.queue_free()

	var DASH := 13.0
	var GAP  :=  9.0

	for i in NODE_POSITIONS.size() - 1:
		var a    := NODE_POSITIONS[i]
		var b    := NODE_POSITIONS[i + 1]
		var dir  := (b - a).normalized()
		var total := a.distance_to(b)
		var t       := 0.0
		var is_dash := true
		while t < total - 0.5:
			var step := minf(DASH if is_dash else GAP, total - t)
			if is_dash:
				var seg := Line2D.new()
				seg.width             = 5.0
				seg.default_color     = C_PATH
				seg.begin_cap_mode    = Line2D.LINE_CAP_ROUND
				seg.end_cap_mode      = Line2D.LINE_CAP_ROUND
				seg.add_point(a + dir * t)
				seg.add_point(a + dir * (t + step))
				add_child(seg)
			t       += step
			is_dash  = !is_dash

# ── Decorative bubbles ─────────────────────────────────────────────────────

func _build_bubbles() -> void:
	var bubbles: Array = [
		[Vector2(162, 692),  7.0, Color("#f9a8d4")],
		[Vector2(330, 570),  5.0, Color("#c4b5fd")],
		[Vector2( 46, 500),  9.0, Color("#f9a8d4")],
		[Vector2(345, 402),  6.0, Color("#c4b5fd")],
		[Vector2(178, 338),  8.0, Color("#f9a8d4")],
		[Vector2( 55, 228),  5.0, Color("#c4b5fd")],
		[Vector2(358, 188),  7.0, Color("#f9a8d4")],
		[Vector2(148, 108),  6.0, Color("#c4b5fd")],
	]
	for bd in bubbles:
		var poly := _ring_poly(bd[0], bd[1], 14)
		poly.color = bd[2]
		add_child(poly)

# ── Level nodes ────────────────────────────────────────────────────────────

func _build_nodes() -> void:
	for c in nodes_root.get_children():
		c.queue_free()

	var nunito_sm := _nv(600)
	var current_idx := GameData.current_level_index

	for i in LevelData.LEVELS.size():
		var lv: Dictionary = LevelData.LEVELS[i]
		var lid      := int(lv.get("id", i + 1))
		var pos      := NODE_POSITIONS[i]
		var done     := SaveData.is_level_complete(lid)
		var unlocked := is_unlocked(i)
		var stars    := SaveData.get_stars(lid)
		var is_cur   := (i == current_idx)

		# Pick fill colour
		var fill: Color
		var label_text: String
		if done:
			fill = C_DONE
			label_text = str(lid)
		elif unlocked:
			fill = LevelData.get_theme(i).accent
			label_text = str(lid)
		else:
			fill = C_LOCKED
			label_text = "🔒"

		# Button style
		var sty := StyleBoxFlat.new()
		sty.set_corner_radius_all(28)
		sty.bg_color     = fill
		sty.set_border_width_all(3)
		sty.border_color = Color.WHITE if unlocked else Color("#d1d5db")

		var sty_press := sty.duplicate() as StyleBoxFlat
		sty_press.bg_color = fill.darkened(0.12)

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(56.0, 56.0)
		btn.position            = pos - Vector2(28.0, 28.0)
		btn.text                = label_text
		btn.disabled            = not unlocked
		btn.focus_mode          = Control.FOCUS_NONE
		btn.add_theme_stylebox_override("normal",   sty)
		btn.add_theme_stylebox_override("hover",    sty)
		btn.add_theme_stylebox_override("pressed",  sty_press)
		btn.add_theme_stylebox_override("disabled", sty)
		btn.add_theme_stylebox_override("focus",    StyleBoxEmpty.new())
		btn.add_theme_font_override("font", Fonts.fredoka())
		btn.add_theme_font_size_override("font_size", 16)
		btn.add_theme_color_override("font_color",          Color.WHITE)
		btn.add_theme_color_override("font_hover_color",    Color.WHITE)
		btn.add_theme_color_override("font_pressed_color",  Color.WHITE)
		btn.add_theme_color_override("font_disabled_color", Color("#9ca3af"))
		var ci := i
		btn.pressed.connect(func(): _on_level_tapped(ci))
		nodes_root.add_child(btn)

		# Level name label (above the node) — shown for every node per screenshot,
		# including locked ones (design ref: designs/03_level_map.png)
		var name_lbl := Label.new()
		name_lbl.text = lv.get("name", "")
		name_lbl.add_theme_font_override("font", nunito_sm)
		name_lbl.add_theme_font_size_override("font_size", 9)
		name_lbl.add_theme_color_override("font_color", C_PURPLE)
		name_lbl.position = pos + Vector2(-40.0, -48.0)
		name_lbl.size     = Vector2(92.0, 18.0)
		nodes_root.add_child(name_lbl)

		# Stars below completed node
		if stars > 0:
			var star_lbl := Label.new()
			star_lbl.text = "⭐".repeat(stars)
			star_lbl.add_theme_font_size_override("font_size", 11)
			star_lbl.position = pos + Vector2(-10.0 * stars, 32.0)
			nodes_root.add_child(star_lbl)

		# Current-level pulse ring
		if is_cur and unlocked:
			var accent_col: Color = LevelData.get_theme(i).get("accent", Color("#f9a8d4"))
			var ac := Color(accent_col.r, accent_col.g, accent_col.b, 1.0)

			# Static glow halo behind the button
			var ring_static := _centered_ring(pos, 34.0, 32)
			ring_static.color = Color(ac.r, ac.g, ac.b, 0.28)
			nodes_root.add_child(ring_static)

			# Animated pulse ring — expands & fades, loops
			var pulse := _centered_ring(pos, 34.0, 32)
			pulse.color = Color(ac.r, ac.g, ac.b, 0.55)
			nodes_root.add_child(pulse)
			var tw := pulse.create_tween()
			tw.set_loops()
			tw.tween_property(pulse, "scale", Vector2(1.55, 1.55), 0.85).set_ease(Tween.EASE_OUT)
			tw.parallel().tween_property(pulse, "modulate:a", 0.0, 0.85).set_ease(Tween.EASE_IN)
			tw.tween_callback(func(): pulse.scale = Vector2.ONE; pulse.modulate.a = 1.0)
			tw.tween_interval(0.35)

# ── Helpers ────────────────────────────────────────────────────────────────

## A level is playable only once the previous one has been completed.
static func is_unlocked(index: int) -> bool:
	if index <= 0:
		return true
	if index >= LevelData.LEVELS.size():
		return false
	var prev_id := int(LevelData.LEVELS[index - 1].get("id", index))
	return SaveData.is_level_complete(prev_id)

func _on_level_tapped(index: int) -> void:
	# The node button is already disabled when locked; this second check means a
	# locked level can never be entered even if the button state is ever wrong.
	if not is_unlocked(index):
		return
	GameData.current_level_index = index
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _nv(weight: int) -> FontVariation:
	return Fonts.nunito(weight)

func _centered_ring(center: Vector2, radius: float, segments: int) -> Polygon2D:
	var pts := PackedVector2Array()
	for i in segments:
		var a: float = TAU * float(i) / float(segments)
		pts.append(Vector2(cos(a), sin(a)) * radius)
	var poly := Polygon2D.new()
	poly.polygon = pts
	poly.position = center
	return poly

func _ring_poly(center: Vector2, radius: float, segments: int) -> Polygon2D:
	var pts := PackedVector2Array()
	for i in segments:
		var a := TAU * float(i) / float(segments)
		pts.append(center + Vector2(cos(a), sin(a)) * radius)
	var poly := Polygon2D.new()
	poly.polygon = pts
	return poly
