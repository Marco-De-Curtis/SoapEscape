extends Control

const C_PINK   := Color("#d63384")
const C_PURPLE := Color("#7c3aed")
const C_GOLD   := Color("#f59e0b")
const C_OUTLINE := Color("#1a1a2e")
const C_CHEEK  := Color(0.95, 0.56, 0.70, 0.62)
const C_BG     := Color("#fdf2f8")


var _bob_t:     float = 0.0
var _burst_t:   float = 0.0
var _total_stars: int = 0

func _ready() -> void:
	_total_stars = _count_total_stars()
	_build_ui()

	# Play star dings for every star earned (up to 6 fast dings)
	var dings := mini(_total_stars, 6)
	for _i in dings:
		AudioManager.play("star_ding")
		await get_tree().create_timer(0.18).timeout

func _process(delta: float) -> void:
	_bob_t   += delta
	_burst_t += delta
	queue_redraw()

# ── Background + animated soap ─────────────────────────────────────────────

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), C_BG)

	# Animated confetti burst — 24 particles radiating out over time
	var cx := size.x * 0.5
	var palette := [C_PINK, C_PURPLE, C_GOLD, Color("#86efac"), Color("#7dd3fc"), Color("#f9a8d4")]
	for i in 24:
		var a: float   = TAU * float(i) / 24.0
		var spd: float = 80.0 + float(i % 4) * 28.0
		var t: float   = fmod(_burst_t * 0.55 + float(i) * 0.18, 2.4)
		var fade: float = clampf(1.0 - t * 0.55, 0.0, 1.0)
		var px: float  = cx + cos(a) * spd * t
		var py: float  = 200.0 + sin(a) * spd * t + 120.0 * t * t
		var col: Color = palette[i % palette.size()]
		draw_rect(
			Rect2(px - 5.0, py - 3.0, 10.0, 6.0),
			Color(col.r, col.g, col.b, fade * 0.85)
		)

	# Sparkle stars at corners
	_draw_sparkle(Vector2(36.0, 68.0), 9.0, C_GOLD, _bob_t)
	_draw_sparkle(Vector2(size.x - 40.0, 80.0), 7.0, C_PURPLE, _bob_t + 0.5)
	_draw_sparkle(Vector2(44.0, 190.0), 6.0, C_PINK, _bob_t + 1.1)
	_draw_sparkle(Vector2(size.x - 36.0, 178.0), 8.0, C_GOLD, _bob_t + 0.8)

	# Victory soap (big, star eyes, floating)
	var soap_cx := size.x * 0.5
	var soap_cy := 162.0 + sin(_bob_t * 1.4) * 8.0
	SoapArt.paint(self, Vector2(soap_cx, soap_cy), 3.6, SoapArt.VICTORY)

func _draw_sparkle(pos: Vector2, r: float, col: Color, t: float) -> void:
	var pulse: float = 0.5 + 0.5 * sin(t * 2.5)
	for i in 4:
		var a: float = PI * 0.25 + PI * 0.5 * float(i)
		var pt := pos + Vector2(cos(a) * r * pulse, sin(a) * r * pulse)
		draw_line(pos, pt, Color(col.r, col.g, col.b, 0.75 * pulse), 2.0, true)

# ── Soap drawing ───────────────────────────────────────────────────────────

# ── UI ─────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	# "You Did It!" headline
	var headline := Label.new()
	headline.text = "You Did It! 🎉"
	headline.add_theme_font_override("font", Fonts.fredoka())
	headline.add_theme_font_size_override("font_size", 46)
	headline.add_theme_color_override("font_color", C_PINK)
	headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	headline.anchor_left  = 0.0; headline.anchor_right  = 1.0
	headline.offset_top   = 280.0; headline.offset_bottom = 344.0
	add_child(headline)

	var sub := Label.new()
	sub.text = "All 10 levels beaten. You're basically a drain."
	sub.add_theme_font_override("font", _nv(500))
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_color", C_PURPLE)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.anchor_left  = 0.0; sub.anchor_right  = 1.0
	sub.offset_left  = 40.0; sub.offset_right  = -40.0
	sub.offset_top   = 348.0; sub.offset_bottom = 390.0
	add_child(sub)

	# Score card
	_build_score_card()

	# Stars row
	_build_stars_row()

	# Buttons
	_build_buttons()

func _build_score_card() -> void:
	var panel := Panel.new()
	var sty := StyleBoxFlat.new()
	sty.set_corner_radius_all(20)
	sty.bg_color = Color.WHITE
	panel.add_theme_stylebox_override("panel", sty)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.anchor_left   = 0.0; panel.anchor_right  = 1.0
	panel.offset_left   = 28.0; panel.offset_right  = -28.0
	panel.offset_top    = 404.0; panel.offset_bottom = 530.0
	add_child(panel)

	# Total stars
	var stars_lbl := Label.new()
	stars_lbl.text = "⭐  %d / 30 stars" % _total_stars
	stars_lbl.add_theme_font_override("font", Fonts.fredoka())
	stars_lbl.add_theme_font_size_override("font_size", 32)
	stars_lbl.add_theme_color_override("font_color", C_GOLD)
	stars_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stars_lbl.anchor_left  = 0.0; stars_lbl.anchor_right  = 1.0
	stars_lbl.offset_top   = 14.0; stars_lbl.offset_bottom = 60.0
	panel.add_child(stars_lbl)

	# Stars bar background
	var bar_bg := Panel.new()
	var bbsty := StyleBoxFlat.new()
	bbsty.set_corner_radius_all(6)
	bbsty.bg_color = Color("#fef9c3")
	bar_bg.add_theme_stylebox_override("panel", bbsty)
	bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar_bg.anchor_left  = 0.0; bar_bg.anchor_right  = 1.0
	bar_bg.offset_left  = 20.0; bar_bg.offset_right  = -20.0
	bar_bg.offset_top   = 64.0; bar_bg.offset_bottom = 80.0
	panel.add_child(bar_bg)

	var bar_fill := Panel.new()
	var bfsty := StyleBoxFlat.new()
	bfsty.set_corner_radius_all(6)
	bfsty.bg_color = C_GOLD
	bar_fill.add_theme_stylebox_override("panel", bfsty)
	bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar_fill.anchor_left   = 0.0
	bar_fill.anchor_right  = clampf(float(_total_stars) / 30.0, 0.0, 1.0)
	bar_fill.anchor_top    = 0.0
	bar_fill.anchor_bottom = 1.0
	bar_bg.add_child(bar_fill)

	# Rating label
	var rating: String
	if _total_stars >= 28:
		rating = "Legendary Soap! 🏆"
	elif _total_stars >= 22:
		rating = "Master Slider! ✨"
	elif _total_stars >= 15:
		rating = "Clean Finish! 🧼"
	else:
		rating = "Made it through!"
	var rating_lbl := Label.new()
	rating_lbl.text = rating
	rating_lbl.add_theme_font_override("font", _nv(700))
	rating_lbl.add_theme_font_size_override("font_size", 16)
	rating_lbl.add_theme_color_override("font_color", C_PURPLE)
	rating_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rating_lbl.anchor_left  = 0.0; rating_lbl.anchor_right  = 1.0
	rating_lbl.offset_top   = 84.0; rating_lbl.offset_bottom = 108.0
	panel.add_child(rating_lbl)

func _build_stars_row() -> void:
	var spacing := 48.0
	var cx       := size.x * 0.5
	var filled   := mini(_total_stars, 10)
	for i in 10:
		var poly := Polygon2D.new()
		poly.polygon = _star_poly(Vector2.ZERO, 16.0, 7.0, 5)
		poly.color   = C_GOLD if i < filled else Color("#e5e7eb")
		poly.position = Vector2(cx - spacing * 4.5 + float(i) * spacing, 556.0)
		add_child(poly)

func _build_buttons() -> void:
	# Play Again — left
	var again_btn := _pill_btn("Play Again", Color(0, 0, 0, 0), C_PURPLE)
	var ghost := StyleBoxFlat.new()
	ghost.set_corner_radius_all(27)
	ghost.bg_color = Color(0, 0, 0, 0)
	ghost.set_border_width_all(2)
	ghost.border_color = C_PURPLE
	again_btn.add_theme_stylebox_override("normal", ghost)
	again_btn.add_theme_stylebox_override("hover",  ghost)
	again_btn.add_theme_color_override("font_color",       C_PURPLE)
	again_btn.add_theme_color_override("font_hover_color", C_PURPLE)
	again_btn.anchor_left  = 0.0; again_btn.anchor_right  = 0.5
	again_btn.offset_left  = 28.0; again_btn.offset_right  = -8.0
	again_btn.offset_top   = 598.0; again_btn.offset_bottom = 654.0
	again_btn.pressed.connect(_on_play_again)
	add_child(again_btn)

	# Level Map — right, filled
	var map_btn := _pill_btn("Level Map", C_PINK, Color.WHITE)
	map_btn.anchor_left  = 0.5; map_btn.anchor_right  = 1.0
	map_btn.offset_left  = 8.0;  map_btn.offset_right  = -28.0
	map_btn.offset_top   = 598.0; map_btn.offset_bottom = 654.0
	map_btn.pressed.connect(_on_map)
	add_child(map_btn)

func _pill_btn(label: String, bg: Color, fg: Color) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.add_theme_font_override("font", _nv(700))
	btn.add_theme_font_size_override("font_size", 17)
	btn.add_theme_color_override("font_color",       fg)
	btn.add_theme_color_override("font_hover_color", fg)
	var sty := StyleBoxFlat.new(); sty.set_corner_radius_all(27); sty.bg_color = bg
	btn.add_theme_stylebox_override("normal",  sty)
	var hover := sty.duplicate() as StyleBoxFlat; hover.bg_color = bg.lightened(0.08)
	btn.add_theme_stylebox_override("hover",   hover)
	var press := sty.duplicate() as StyleBoxFlat; press.bg_color = bg.darkened(0.10)
	btn.add_theme_stylebox_override("pressed", press)
	btn.add_theme_stylebox_override("focus",   StyleBoxEmpty.new())
	btn.focus_mode = Control.FOCUS_NONE
	return btn

# ── Navigation ─────────────────────────────────────────────────────────────

func _on_play_again() -> void:
	GameData.current_level_index = 0
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_map() -> void:
	get_tree().change_scene_to_file("res://scenes/MapScreen.tscn")

# ── Helpers ────────────────────────────────────────────────────────────────

func _count_total_stars() -> int:
	var total := 0
	for lv in LevelData.LEVELS:
		total += SaveData.get_stars(int(lv.get("id", 0)))
	return total

func _nv(weight: int) -> FontVariation:
	return Fonts.nunito(weight)

func _star_poly(centre: Vector2, outer: float, inner: float, points: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in points * 2:
		var a := -PI * 0.5 + TAU * float(i) / float(points * 2)
		var r := outer if i % 2 == 0 else inner
		pts.append(centre + Vector2(cos(a), sin(a)) * r)
	return pts

func _rrect(cx: float, cy: float, hw: float, hh: float, r: float) -> PackedVector2Array:
	r = minf(r, minf(hw, hh) * 0.99)
	var pts := PackedVector2Array()
	var ccx := PackedFloat32Array([-hw+r, hw-r, hw-r, -hw+r])
	var ccy := PackedFloat32Array([-hh+r, -hh+r, hh-r, hh-r])
	var ca0 := PackedFloat32Array([PI, -PI*0.5, 0.0, PI*0.5])
	for i in 4:
		for j in 4:
			var a: float = ca0[i] + PI * 0.5 * float(j) / 3.0
			pts.append(Vector2(cx + ccx[i] + cos(a) * r, cy + ccy[i] + sin(a) * r))
	return pts

func _circle(cx: float, cy: float, r: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a: float = TAU * float(i) / float(n)
		pts.append(Vector2(cx + cos(a) * r, cy + sin(a) * r))
	return pts
