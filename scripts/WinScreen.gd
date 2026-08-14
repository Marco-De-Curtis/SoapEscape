extends Control

const C_PINK   := Color("#d63384")
const C_PURPLE := Color("#7c3aed")
const C_GOLD   := Color("#f59e0b")
const C_GREY   := Color("#d1d5db")
const C_OUTLINE := Color("#1a1a2e")
const C_CHEEK  := Color(0.95, 0.56, 0.70, 0.62)


var _bob_t: float = 0.0
var _bg_color: Color = Color("#e0f2fe")

func _ready() -> void:
	var stars    := GameData.last_stars
	var soap_pct := GameData.last_soap_pct
	var theme    := LevelData.get_theme(GameData.current_level_index)
	_bg_color = theme.tile_bg

	_build_title(stars)
	_build_soap_card(soap_pct)
	_build_stars(stars)
	_build_buttons(stars)

	for i in stars:
		AudioManager.play("star_ding")
		await get_tree().create_timer(0.28).timeout

func _process(delta: float) -> void:
	_bob_t += delta
	queue_redraw()

# ── Background + soap mascot ───────────────────────────────────────────────

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), _bg_color)

	# Decorative sparkles
	_draw_sparkle(Vector2(32.0,  72.0), 7.0, C_GOLD)
	_draw_sparkle(Vector2(size.x - 44.0, 88.0), 5.0, C_PURPLE)
	_draw_sparkle(Vector2(52.0, 188.0), 4.0, C_PINK)
	_draw_sparkle(Vector2(size.x - 28.0, 162.0), 6.0, C_GOLD)

	# Victory soap mascot (star eyes, big smile)
	var cx := size.x * 0.5
	var cy := 148.0 + sin(_bob_t * 1.5) * 6.0
	SoapArt.paint(self, Vector2(cx, cy), 3.2, SoapArt.VICTORY)

func _draw_sparkle(pos: Vector2, r: float, col: Color) -> void:
	for i in 4:
		var a: float = PI * 0.25 + PI * 0.5 * float(i)
		var pt := pos + Vector2(cos(a) * r, sin(a) * r)
		draw_line(pos, pt, Color(col.r, col.g, col.b, 0.7), 1.5, true)

# ── Soap drawing helpers ───────────────────────────────────────────────────

# ── Title section ──────────────────────────────────────────────────────────

func _build_title(stars: int) -> void:
	var lv: Dictionary = LevelData.LEVELS[GameData.current_level_index]
	var level_flag: String = lv.get("flag", "")
	var level_name: String = str(lv.get("name", ""))

	# "New record!" badge — show whenever stars improved over personal best
	if stars > GameData.prev_stars:
		var badge_panel := Panel.new()
		var bsty := StyleBoxFlat.new()
		bsty.set_corner_radius_all(14)
		bsty.bg_color = C_GOLD
		badge_panel.add_theme_stylebox_override("panel", bsty)
		badge_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge_panel.anchor_left  = 0.5; badge_panel.anchor_right  = 0.5
		badge_panel.offset_left  = -76.0; badge_panel.offset_right = 76.0
		badge_panel.offset_top   = 222.0; badge_panel.offset_bottom = 248.0
		add_child(badge_panel)
		var badge_lbl := Label.new()
		badge_lbl.text = "New record!  ✦"
		badge_lbl.add_theme_font_override("font", _nv(700))
		badge_lbl.add_theme_font_size_override("font_size", 12)
		badge_lbl.add_theme_color_override("font_color", Color.WHITE)
		badge_lbl.anchor_right = 1.0; badge_lbl.anchor_bottom = 1.0
		badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		badge_panel.add_child(badge_lbl)

	var headline := Label.new()
	headline.text = "Level Complete!"
	headline.add_theme_font_override("font", Fonts.fredoka())
	headline.add_theme_font_size_override("font_size", 40)
	headline.add_theme_color_override("font_color", C_PINK)
	headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	headline.anchor_left  = 0.0; headline.anchor_right  = 1.0
	headline.offset_top   = 255.0; headline.offset_bottom = 308.0
	add_child(headline)

	if level_flag != "":
		var flag_icon := FlagIcon.new()
		flag_icon.country     = level_flag
		flag_icon.icon_width  = 20.0
		flag_icon.icon_height = 14.0
		flag_icon.position    = Vector2(size.x * 0.5, 296.0)
		add_child(flag_icon)

	var sub := Label.new()
	sub.text = level_name
	sub.add_theme_font_override("font", _nv(600))
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", C_PURPLE)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.anchor_left  = 0.0; sub.anchor_right  = 1.0
	sub.offset_top   = 308.0; sub.offset_bottom = 338.0
	add_child(sub)

# ── Soap remaining card ────────────────────────────────────────────────────

func _build_soap_card(soap_pct: float) -> void:
	var panel := Panel.new()
	var sty := StyleBoxFlat.new()
	sty.set_corner_radius_all(16)
	sty.bg_color = Color.WHITE
	panel.add_theme_stylebox_override("panel", sty)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.anchor_left   = 0.0; panel.anchor_right  = 1.0
	panel.offset_top    = 352.0; panel.offset_bottom = 438.0
	panel.offset_left   = 28.0;  panel.offset_right  = -28.0
	add_child(panel)

	var lbl_top := Label.new()
	lbl_top.text = "SOAP REMAINING"
	lbl_top.add_theme_font_override("font", _nv(700))
	lbl_top.add_theme_font_size_override("font_size", 10)
	lbl_top.add_theme_color_override("font_color", Color("#9ca3af"))
	lbl_top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_top.anchor_left  = 0.0; lbl_top.anchor_right  = 1.0
	lbl_top.offset_top   = 12.0; lbl_top.offset_bottom = 28.0
	panel.add_child(lbl_top)

	# Bar background
	var bar_bg := Panel.new()
	var bbsty := StyleBoxFlat.new()
	bbsty.set_corner_radius_all(6)
	bbsty.bg_color = Color("#fce7f3")
	bar_bg.add_theme_stylebox_override("panel", bbsty)
	bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar_bg.anchor_left  = 0.0; bar_bg.anchor_right  = 1.0
	bar_bg.offset_top   = 32.0; bar_bg.offset_bottom = 54.0
	bar_bg.offset_left  = 44.0; bar_bg.offset_right  = -80.0
	panel.add_child(bar_bg)

	# Bar fill (uses anchor to represent fraction)
	var bar_fill := Panel.new()
	var bfsty := StyleBoxFlat.new()
	bfsty.set_corner_radius_all(6)
	bfsty.bg_color = C_PINK
	bar_fill.add_theme_stylebox_override("panel", bfsty)
	bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar_fill.anchor_left   = 0.0
	bar_fill.anchor_right  = clampf(soap_pct, 0.0, 1.0)
	bar_fill.anchor_top    = 0.0
	bar_fill.anchor_bottom = 1.0
	bar_bg.add_child(bar_fill)

	# Soap icon
	var icon_lbl := Label.new()
	icon_lbl.text = "🧼"
	icon_lbl.add_theme_font_size_override("font_size", 18)
	icon_lbl.position = Vector2(10.0, 26.0)
	icon_lbl.size     = Vector2(32.0, 32.0)
	panel.add_child(icon_lbl)

	# Percentage
	var pct_lbl := Label.new()
	pct_lbl.text = "%d%%" % roundi(soap_pct * 100.0)
	pct_lbl.add_theme_font_override("font", Fonts.fredoka())
	pct_lbl.add_theme_font_size_override("font_size", 22)
	pct_lbl.add_theme_color_override("font_color", C_PINK)
	pct_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pct_lbl.anchor_right  = 1.0
	pct_lbl.offset_right  = -12.0
	pct_lbl.offset_top    = 28.0; pct_lbl.offset_bottom = 58.0
	panel.add_child(pct_lbl)

	# Star threshold hint — computed from this level's actual thresholds
	var lv2: Dictionary = LevelData.LEVELS[GameData.current_level_index]
	var lv_min := float(lv2.get("min_soap", 0.5))
	var hint_text: String
	if lv_min < 0.45:
		hint_text = "★ %d%%+    ★★ 45%%+    ★★★ 70%%+" % int(lv_min * 100)
	else:
		hint_text = "★★ %d%%+    ★★★ 70%%+" % int(lv_min * 100)
	var hint := Label.new()
	hint.text = hint_text
	hint.add_theme_font_override("font", _nv(400))
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color("#9ca3af"))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.anchor_left  = 0.0; hint.anchor_right  = 1.0
	hint.offset_top   = 56.0; hint.offset_bottom = 72.0
	panel.add_child(hint)

# ── Stars ──────────────────────────────────────────────────────────────────

func _build_stars(stars: int) -> void:
	var cx      := 195.0
	var spacing := 62.0
	var offsets := [-spacing, 0.0, spacing]
	for i in 3:
		var earned := (i < stars)
		var poly := Polygon2D.new()
		poly.polygon = _star_poly(Vector2.ZERO, 26.0, 12.0, 5)
		poly.color   = C_GOLD if earned else C_GREY
		poly.position = Vector2(cx + offsets[i], 472.0)
		poly.scale    = Vector2.ZERO if earned else Vector2.ONE
		add_child(poly)
		if earned:
			var tw := poly.create_tween()
			tw.tween_interval(float(i) * 0.22)
			tw.tween_property(poly, "scale", Vector2(1.35, 1.35), 0.22).set_ease(Tween.EASE_OUT)
			tw.tween_property(poly, "scale", Vector2.ONE, 0.10)

# ── Buttons ────────────────────────────────────────────────────────────────

func _build_buttons(_stars: int) -> void:
	var next_idx := GameData.current_level_index + 1
	var has_next := next_idx < LevelData.LEVELS.size()

	# Map button — left half
	var map_btn := _make_pill_btn("Map", Color(0, 0, 0, 0), C_PURPLE)
	var ghost := _pill_style(Color(0, 0, 0, 0))
	ghost.set_border_width_all(2)
	ghost.border_color = C_PURPLE
	ghost.set_corner_radius_all(27)
	map_btn.add_theme_stylebox_override("normal", ghost)
	map_btn.add_theme_stylebox_override("hover",  ghost)
	map_btn.add_theme_color_override("font_color",       C_PURPLE)
	map_btn.add_theme_color_override("font_hover_color", C_PURPLE)
	map_btn.anchor_left  = 0.0; map_btn.anchor_right  = 0.5
	map_btn.offset_left  = 28.0; map_btn.offset_right  = -8.0
	map_btn.offset_top   = 510.0; map_btn.offset_bottom = 566.0
	map_btn.pressed.connect(_on_map)
	add_child(map_btn)

	# Next Level button — right half (goes to Game Complete screen if last level)
	var next_label := "Next Level  →" if has_next else "See Results  🎉"
	var next_btn := _make_pill_btn(next_label, C_PURPLE, Color.WHITE)
	next_btn.anchor_left  = 0.5; next_btn.anchor_right  = 1.0
	next_btn.offset_left  = 8.0;  next_btn.offset_right  = -28.0
	next_btn.offset_top   = 510.0; next_btn.offset_bottom = 566.0
	next_btn.pressed.connect(_on_next)
	add_child(next_btn)

func _make_pill_btn(label: String, bg: Color, fg: Color) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.add_theme_font_override("font", _nv(700))
	btn.add_theme_font_size_override("font_size", 17)
	btn.add_theme_color_override("font_color",       fg)
	btn.add_theme_color_override("font_hover_color", fg)
	btn.add_theme_stylebox_override("normal",  _pill_style(bg))
	btn.add_theme_stylebox_override("hover",   _pill_style(bg.lightened(0.08)))
	btn.add_theme_stylebox_override("pressed", _pill_style(bg.darkened(0.10)))
	btn.add_theme_stylebox_override("focus",   StyleBoxEmpty.new())
	btn.focus_mode = Control.FOCUS_NONE
	return btn

func _pill_style(bg: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.set_corner_radius_all(27)
	s.bg_color = bg
	return s

# ── Navigation ─────────────────────────────────────────────────────────────

func _on_next() -> void:
	var next_idx := GameData.current_level_index + 1
	if next_idx < LevelData.LEVELS.size():
		GameData.current_level_index = next_idx
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/GameCompleteScreen.tscn")

func _on_map() -> void:
	get_tree().change_scene_to_file("res://scenes/MapScreen.tscn")

# ── Polygon helpers ────────────────────────────────────────────────────────

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
