extends Control

const C_RED    := Color("#e11d48")
const C_PINK   := Color("#d63384")
const C_WHITE  := Color.WHITE
const C_OUTLINE := Color("#1a1a2e")
const C_CHEEK  := Color(0.95, 0.56, 0.70, 0.62)
const C_BG     := Color("#fdf2f8")

# All 3 cause cards always shown, fixed order (matches main README + screenshot); active one is full opacity
const CAUSES: Array[Dictionary] = [
	{
		"key":   "dissolved",
		"icon":  "💧",
		"title": "Dissolved!",
		"body":  "Your soap bar melted completely in the water."
	},
	{
		"key":   "obstacle",
		"icon":  "🚫",
		"title": "Hit an obstacle!",
		"body":  "That rubber duck really doesn't like you."
	},
	{
		"key":   "too_small",
		"icon":  "📏",
		"title": "Too small at the finish!",
		"body":  "You needed at least 30% soap to pass."
	},
]


var _bob_t: float = 0.0

func _ready() -> void:
	var reason := GameData.fail_reason
	_build_title()
	_build_cause_cards(reason)
	_build_motivation()
	_build_buttons()


func _process(delta: float) -> void:
	_bob_t += delta
	queue_redraw()

# ── Background + soap mascot ───────────────────────────────────────────────

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), C_BG)

	# Decorative soft oval in top-right
	draw_colored_polygon(_circle(size.x * 0.88, size.y * 0.08, 80.0, 28), Color(0.95, 0.56, 0.70, 0.12))
	draw_colored_polygon(_circle(size.x * 0.10, size.y * 0.82, 60.0, 24), Color(0.95, 0.56, 0.70, 0.09))

	# Critical soap mascot (× × eyes, wavy mouth)
	var cx := size.x * 0.5
	var cy := 148.0 + sin(_bob_t * 1.5) * 5.0
	SoapArt.paint(self, Vector2(cx, cy), 3.0, SoapArt.CRITICAL)

# ── Soap drawing helpers ───────────────────────────────────────────────────

# ── Title ──────────────────────────────────────────────────────────────────

func _build_title() -> void:
	var lbl := Label.new()
	lbl.text = "Oops! Try again."
	lbl.add_theme_font_override("font", Fonts.fredoka())
	lbl.add_theme_font_size_override("font_size", 30)  # Fail headline token
	lbl.add_theme_color_override("font_color", C_RED)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.anchor_left  = 0.0;   lbl.anchor_right  = 1.0
	lbl.offset_top   = 213.0; lbl.offset_bottom = 263.0
	add_child(lbl)

# ── Cause cards ────────────────────────────────────────────────────────────

func _build_cause_cards(active_key: String) -> void:
	var card_h := 74.0
	var gap    :=  8.0
	var start_y := 277.0

	for ci in CAUSES.size():
		var cause: Dictionary = CAUSES[ci]
		var is_active: bool = cause["key"] == active_key
		var alpha := 1.0 if is_active else 0.38

		var card := Panel.new()
		var sty := StyleBoxFlat.new()
		sty.set_corner_radius_all(14)
		sty.bg_color = C_WHITE if is_active else Color(1.0, 1.0, 1.0, 0.7)
		if is_active:
			sty.set_border_width_all(2)
			sty.border_color = C_RED
		card.add_theme_stylebox_override("panel", sty)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.anchor_left   = 0.0;  card.anchor_right  = 1.0
		card.offset_left   = 28.0; card.offset_right  = -28.0
		card.offset_top    = start_y + float(ci) * (card_h + gap)
		card.offset_bottom = card.offset_top + card_h
		card.modulate.a    = alpha
		add_child(card)

		# Icon
		var icon_lbl := Label.new()
		icon_lbl.text = cause["icon"]
		icon_lbl.add_theme_font_size_override("font_size", 26)
		icon_lbl.position = Vector2(12.0, (card_h - 30.0) * 0.5)
		icon_lbl.size     = Vector2(36.0, 30.0)
		card.add_child(icon_lbl)

		# Title
		var title_lbl := Label.new()
		title_lbl.text = cause["title"]
		title_lbl.add_theme_font_override("font", _nv(700))
		title_lbl.add_theme_font_size_override("font_size", 14)
		title_lbl.add_theme_color_override("font_color", C_RED if is_active else Color("#6b7280"))
		title_lbl.anchor_left   = 0.0;  title_lbl.anchor_right  = 1.0
		title_lbl.offset_left   = 54.0; title_lbl.offset_right  = -8.0
		title_lbl.offset_top    = 10.0; title_lbl.offset_bottom = 30.0
		card.add_child(title_lbl)

		# Body
		var body_lbl := Label.new()
		var body_text: String = cause["body"]
		if cause["key"] == "too_small":
			var pct := int(GameData.min_soap_pct * 100)
			body_text = "You needed at least %d%% soap to pass." % pct
		body_lbl.text = body_text
		body_lbl.add_theme_font_override("font", _nv(400))
		body_lbl.add_theme_font_size_override("font_size", 12)
		body_lbl.add_theme_color_override("font_color", Color("#6b7280"))
		body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body_lbl.anchor_left   = 0.0;  body_lbl.anchor_right  = 1.0
		body_lbl.offset_left   = 54.0; body_lbl.offset_right  = -8.0
		body_lbl.offset_top    = 32.0; body_lbl.offset_bottom = 62.0
		card.add_child(body_lbl)

# ── Motivational text ──────────────────────────────────────────────────────

func _build_motivation() -> void:
	var lbl := Label.new()
	lbl.text = "The drain isn't going anywhere.\nGive it another shot — you've got this. 🧼"
	lbl.add_theme_font_override("font", _nv(400))
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color("#9ca3af"))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.anchor_left  = 0.0;   lbl.anchor_right  = 1.0
	lbl.offset_left  = 40.0;  lbl.offset_right  = -40.0
	lbl.offset_top   = 553.0; lbl.offset_bottom = 600.0
	add_child(lbl)

# ── Buttons ────────────────────────────────────────────────────────────────

func _build_buttons() -> void:
	# Map — left half, grey outline (main README: "[Map] grey outlined"; not in tokens file)
	const C_GREY := Color("#6b7280")
	var map_btn := _make_pill_btn("Map", Color(0, 0, 0, 0), C_GREY)
	var ghost := StyleBoxFlat.new()
	ghost.set_corner_radius_all(27)
	ghost.bg_color = Color(0, 0, 0, 0)
	ghost.set_border_width_all(2)
	ghost.border_color = C_GREY
	map_btn.add_theme_stylebox_override("normal", ghost)
	map_btn.add_theme_stylebox_override("hover",  ghost)
	map_btn.add_theme_color_override("font_color",       C_GREY)
	map_btn.add_theme_color_override("font_hover_color", C_GREY)
	map_btn.anchor_left  = 0.0; map_btn.anchor_right  = 0.5
	map_btn.offset_left  = 28.0; map_btn.offset_right  = -8.0
	map_btn.offset_top   = 614.0; map_btn.offset_bottom = 670.0
	map_btn.pressed.connect(_on_map)
	add_child(map_btn)

	# Try Again — right half, filled color_primary_pink + primary-button-glow token
	var retry := _make_pill_btn("Try Again", C_PINK, C_WHITE)
	var retry_sty := _pill_style(C_PINK)
	retry_sty.shadow_color  = Color(214.0 / 255.0, 51.0 / 255.0, 132.0 / 255.0, 0.4)
	retry_sty.shadow_size   = 24
	retry_sty.shadow_offset = Vector2(0.0, 6.0)
	retry.add_theme_stylebox_override("normal", retry_sty)
	retry.anchor_left  = 0.5; retry.anchor_right  = 1.0
	retry.offset_left  = 8.0;  retry.offset_right  = -28.0
	retry.offset_top   = 614.0; retry.offset_bottom = 670.0
	retry.pressed.connect(_on_retry)
	add_child(retry)

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

func _on_retry() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_map() -> void:
	get_tree().change_scene_to_file("res://scenes/MapScreen.tscn")

# ── Polygon helpers ────────────────────────────────────────────────────────

func _nv(weight: int) -> FontVariation:
	return Fonts.nunito(weight)

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
