extends Control

const SafeArea = preload("res://scripts/SafeArea.gd")

const OUTLINE_COLOR := Color("#1a1a2e")
const SOAP_COLOR    := Color("#c4b5fd")
const CHEEK_COLOR   := Color(0.95, 0.56, 0.70, 0.68)
const C_PINK        := Color("#d63384")
const C_PURPLE      := Color("#7c3aed")
const C_BG          := Color("#fdf2f8")  # color_bg_app
const SHADOW_PINK    := Color(181.0/255.0, 45.0/255.0, 112.0/255.0, 0.45)
const SHADOW_PURPLE  := Color(91.0/255.0, 33.0/255.0, 182.0/255.0, 0.45)


var _bob_t: float = 0.0

func _ready() -> void:
	_build_background()
	_build_tagline()
	_build_buttons()
	if not SaveData.is_onboarding_shown():
		_show_onboarding_carousel()

func _process(delta: float) -> void:
	_bob_t += delta
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), C_BG)
	_draw_bubbles()
	# Logo drifts gently; the mascot lives inside it, so there is no second soap.
	var ly := 268.0 + sin(_bob_t * 1.3) * 6.0
	LogoArt.paint_wide(self, Vector2(size.x * 0.5, ly), 1.0)

# ── Background ─────────────────────────────────────────────────────────────

func _build_background() -> void:
	pass  # Background drawn in _draw() — ColorRect child would cover the soap illustration

# ── Title ──────────────────────────────────────────────────────────────────

func _build_tagline() -> void:
	var sub := Label.new()
	sub.text = "Slide, dodge, and save your soap before it melts away!"
	sub.add_theme_font_override("font", _nv(600))
	sub.add_theme_font_size_override("font_size", 15)
	sub.add_theme_color_override("font_color", C_PURPLE)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.vertical_alignment   = VERTICAL_ALIGNMENT_TOP
	sub.anchor_left  = 0.0; sub.anchor_right  = 1.0
	sub.offset_left  = 44.0; sub.offset_right = -44.0
	sub.offset_top   = 402.0; sub.offset_bottom = 462.0
	add_child(sub)

# ── Buttons ────────────────────────────────────────────────────────────────

func _build_buttons() -> void:
	var has_progress := SaveData.is_level_complete(1)

	var play_btn := _pill_btn(
		"▶ Continue!" if has_progress else "▶ Play!",
		C_PINK, Color.WHITE, 640.0
	)
	play_btn.pressed.connect(_on_play)
	add_child(play_btn)

	var how_btn := _pill_btn("How to play →", Color.TRANSPARENT, C_PURPLE, 706.0)
	how_btn.add_theme_stylebox_override("normal",  StyleBoxEmpty.new())
	how_btn.add_theme_stylebox_override("hover",   StyleBoxEmpty.new())
	how_btn.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	how_btn.pressed.connect(_on_how_to_play)
	add_child(how_btn)

func _pill_btn(label: String, bg: Color, fg: Color, y: float) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.add_theme_font_override("font", _nv(700))
	btn.add_theme_font_size_override("font_size", 17)  # Button labels (Nunito) token
	btn.add_theme_color_override("font_color",       fg)
	btn.add_theme_color_override("font_hover_color", fg)
	btn.add_theme_stylebox_override("normal",  _pill_style(bg))
	btn.add_theme_stylebox_override("hover",   _pill_style(bg.lightened(0.08)))
	btn.add_theme_stylebox_override("pressed", _pill_style(bg.darkened(0.10)))
	btn.add_theme_stylebox_override("focus",   StyleBoxEmpty.new())
	btn.focus_mode = Control.FOCUS_NONE
	btn.anchor_left  = 0.0; btn.anchor_right  = 1.0
	btn.offset_left  = 40.0; btn.offset_right = -40.0
	btn.offset_top   = y;   btn.offset_bottom = y + 56.0
	return btn

func _pill_style(bg: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.set_corner_radius_all(28)
	s.bg_color = bg
	if bg.a > 0.01:
		# Primary button glow token: 0 6px 24px rgba(214,51,132,.4)
		s.shadow_color  = Color(214.0/255.0, 51.0/255.0, 132.0/255.0, 0.4)
		s.shadow_size   = 24
		s.shadow_offset = Vector2(0.0, 6.0)
	return s

# ── Navigation ─────────────────────────────────────────────────────────────

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/MapScreen.tscn")

func _on_how_to_play() -> void:
	_show_onboarding_carousel()

# ── Onboarding carousel ────────────────────────────────────────────────────
# Full-screen slides (option 1e). Slide 3 ("Reach the finish line") matches
# designs/02_onboarding_carousel.png; slides 1-2 keep the existing game-accurate
# copy (no screenshot supplied for them) restyled to the same chrome.

const GRID_LINE_COLOR := Color(0.9765, 0.6588, 0.8314, 0.1)  # from main README grid spec, not the tokens file
const DOT_ACTIVE   := Color("#d63384")
const DOT_INACTIVE := Color("#f9a8d4")

# Four tutorial slides. Wording is deliberately plain — someone who has never
# played a mobile game should understand it.
const SLIDES: Array[Dictionary] = [
	{
		"kind":  "logo",
		"title": "Welcome!",
		"body":  "Slide, dodge, and save your soap before it melts away!",
	},
	{
		"kind":  "steer",
		"title": "Hold left or right",
		"body":  "Hold the left half to go left. Hold the right half to go right.",
	},
	{
		"kind":  "obstacles",
		"title": "Do not touch these",
		"body":  "Bumping into one costs you soap. Go around them.",
	},
	{
		"kind":  "water",
		"title": "Reach the flag",
		"body":  "Water shrinks you. Green sparkles grow you back.",
	},
]

# Bottom sheet rhythm (all relative to the sheet's own top edge)
const SHEET_TOP  := 552.0
const HEAD_TOP   := 22.0
const BODY_TOP   := 66.0
const BODY_BOT   := 146.0
const DOTS_Y     := 156.0
const CTA_TOP    := 174.0

var _carousel_slide:      int  = 0
var _carousel_root:       Control
var _carousel_illus:      Control
var _carousel_headline:   Label
var _carousel_body:       Label
var _carousel_dots:       Array[Panel] = []
var _carousel_btn:        GradientPillButton
var _swipe_start_x:       float = 0.0

func _show_onboarding_carousel() -> void:
	_carousel_slide = 0
	_carousel_dots  = []

	var overlay := Control.new()
	overlay.anchor_right  = 1.0
	overlay.anchor_bottom = 1.0
	overlay.mouse_filter  = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	_carousel_root = overlay

	var bg := ColorRect.new()
	bg.color = C_BG  # color_bg_app
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(bg)

	_build_grid(overlay)

	# Skip
	var skip := Button.new()
	skip.text = "Skip"
	skip.flat = true
	skip.focus_mode = Control.FOCUS_NONE
	skip.add_theme_font_override("font", _nv(700))
	skip.add_theme_font_size_override("font_size", 14)
	skip.add_theme_color_override("font_color",       C_PINK)
	skip.add_theme_color_override("font_hover_color", C_PINK)
	skip.add_theme_stylebox_override("normal",  StyleBoxEmpty.new())
	skip.add_theme_stylebox_override("hover",   StyleBoxEmpty.new())
	skip.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	skip.add_theme_stylebox_override("focus",   StyleBoxEmpty.new())
	# Below the real safe-area inset. At the old fixed y=20 this sat in the
	# status bar / notch band — the first control a new player ever sees,
	# placed where the hardware can clip it.
	var skip_top := SafeArea.content_top(self)
	skip.anchor_left = 1.0; skip.anchor_right = 1.0
	skip.offset_left = -70.0; skip.offset_right = -20.0
	skip.offset_top  = skip_top;  skip.offset_bottom = skip_top + 28.0
	skip.pressed.connect(_skip_onboarding)
	overlay.add_child(skip)

	# Illustration area (swappable per slide)
	_carousel_illus = Control.new()
	_carousel_illus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_carousel_illus.anchor_right = 1.0
	_carousel_illus.offset_top    = maxf(60.0, skip_top + 36.0)
	_carousel_illus.offset_bottom = SHEET_TOP
	overlay.add_child(_carousel_illus)

	# Bottom sheet
	var sheet := Panel.new()
	var ssty := StyleBoxFlat.new()
	ssty.corner_radius_top_left  = 30
	ssty.corner_radius_top_right = 30
	ssty.bg_color = Color.WHITE
	sheet.add_theme_stylebox_override("panel", ssty)
	sheet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sheet.anchor_left  = 0.0; sheet.anchor_right  = 1.0
	sheet.anchor_bottom = 1.0
	sheet.offset_top    = SHEET_TOP
	overlay.add_child(sheet)

	_carousel_headline = Label.new()
	_carousel_headline.add_theme_font_override("font", Fonts.fredoka())
	_carousel_headline.add_theme_font_size_override("font_size", 26)  # Onboarding titles token
	_carousel_headline.add_theme_color_override("font_color", C_PINK)  # color_primary_pink
	_carousel_headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_carousel_headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_carousel_headline.anchor_left  = 0.0; _carousel_headline.anchor_right  = 1.0
	_carousel_headline.offset_left  = 20.0; _carousel_headline.offset_right = -20.0
	_carousel_headline.offset_top   = HEAD_TOP; _carousel_headline.offset_bottom = HEAD_TOP + 40.0
	sheet.add_child(_carousel_headline)

	_carousel_body = Label.new()
	_carousel_body.add_theme_font_override("font", _nv(400))
	_carousel_body.add_theme_font_size_override("font_size", 14)  # Body / instructions token
	_carousel_body.add_theme_color_override("font_color", Color("#6b7280"))  # Body / instructions token
	_carousel_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_carousel_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_carousel_body.anchor_left  = 0.0; _carousel_body.anchor_right  = 1.0
	_carousel_body.offset_left  = 32.0; _carousel_body.offset_right = -32.0
	_carousel_body.offset_top   = BODY_TOP; _carousel_body.offset_bottom = BODY_BOT
	sheet.add_child(_carousel_body)

	# Dot indicators
	for i in SLIDES.size():
		var dot := Panel.new()
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sheet.add_child(dot)
		_carousel_dots.append(dot)
	_refresh_dots()

	# Gradient CTA
	_carousel_btn = GradientPillButton.new()
	_carousel_btn.color_left  = C_PINK
	_carousel_btn.color_right = C_PURPLE
	_carousel_btn.anchor_left  = 0.0; _carousel_btn.anchor_right  = 1.0
	_carousel_btn.offset_left  = 24.0; _carousel_btn.offset_right = -24.0
	_carousel_btn.offset_top   = CTA_TOP; _carousel_btn.offset_bottom = CTA_TOP + 58.0
	sheet.add_child(_carousel_btn)
	_carousel_btn.set_font(_nv(700), 17)  # Button labels (Nunito) token
	_carousel_btn.pressed.connect(_carousel_next)

	_build_slide_content(_carousel_slide)

	overlay.gui_input.connect(_carousel_gui_input)

func _refresh_dots() -> void:
	# All pages are equal-size round dots; only the colour marks the current one.
	const GAP  := 14.0
	const SIZE := 9.0
	var total := GAP * float(_carousel_dots.size() - 1) + SIZE * float(_carousel_dots.size())
	var x := get_viewport().get_visible_rect().size.x * 0.5 - total * 0.5
	for i in _carousel_dots.size():
		var sty := StyleBoxFlat.new()
		sty.bg_color = DOT_ACTIVE if i == _carousel_slide else DOT_INACTIVE
		sty.set_corner_radius_all(int(SIZE * 0.5))
		var dot := _carousel_dots[i]
		dot.add_theme_stylebox_override("panel", sty)
		dot.position = Vector2(x, DOTS_Y)
		dot.size     = Vector2(SIZE, SIZE)
		x += SIZE + GAP

func _build_grid(parent: Control) -> void:
	var grid := Control.new()
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var gs := GDScript.new()
	gs.source_code = """extends Control
func _draw() -> void:
	var c := Color(%f, %f, %f, %f)
	var step := 22.0
	var x := 0.0
	while x < size.x:
		draw_line(Vector2(x, 0.0), Vector2(x, size.y), c, 1.0)
		x += step
	var y := 0.0
	while y < size.y:
		draw_line(Vector2(0.0, y), Vector2(size.x, y), c, 1.0)
		y += step
""" % [GRID_LINE_COLOR.r, GRID_LINE_COLOR.g, GRID_LINE_COLOR.b, GRID_LINE_COLOR.a]
	gs.reload()
	grid.set_script(gs)
	parent.add_child(grid)

func _build_slide_content(idx: int) -> void:
	for ch in _carousel_illus.get_children():
		ch.queue_free()

	var slide: Dictionary = SLIDES[idx]
	_carousel_headline.text = slide["title"]
	_carousel_body.text     = slide["body"]
	_carousel_btn.label_text = "Let's play!" if idx == SLIDES.size() - 1 else "Next"
	if _carousel_btn._label:
		_carousel_btn._label.text = _carousel_btn.label_text

	var art := TutorialArt.new()
	art.kind = str(slide["kind"])
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_carousel_illus.add_child(art)

func _skip_onboarding() -> void:
	SaveData.mark_onboarding_shown()
	_carousel_root.queue_free()

func _carousel_next() -> void:
	_carousel_slide += 1
	if _carousel_slide >= SLIDES.size():
		SaveData.mark_onboarding_shown()
		_carousel_root.queue_free()
	else:
		_build_slide_content(_carousel_slide)
		_refresh_dots()

func _carousel_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var e := event as InputEventScreenTouch
		if e.pressed:
			_swipe_start_x = e.position.x
		else:
			var dx := e.position.x - _swipe_start_x
			if dx < -40.0:
				_carousel_next()
			elif dx > 40.0 and _carousel_slide > 0:
				_carousel_slide -= 1
				_build_slide_content(_carousel_slide)
				_refresh_dots()

# ── Soap illustration via _draw() ──────────────────────────────────────────

func _draw_bubbles() -> void:
	var bubbles: Array[Dictionary] = [
		{"x": 0.14, "y": 0.28, "r": 18.0, "a": 0.25},
		{"x": 0.82, "y": 0.22, "r": 12.0, "a": 0.18},
		{"x": 0.10, "y": 0.62, "r": 24.0, "a": 0.14},
		{"x": 0.88, "y": 0.58, "r": 16.0, "a": 0.20},
		{"x": 0.70, "y": 0.72, "r": 10.0, "a": 0.16},
		{"x": 0.25, "y": 0.80, "r": 14.0, "a": 0.13},
	]
	for b in bubbles:
		var bx := float(b["x"]) * size.x
		var by := float(b["y"]) * size.y
		var br := float(b["r"])
		var ba := float(b["a"])
		draw_arc(Vector2(bx, by), br, 0.0, TAU, 20,
			Color(C_PURPLE.r, C_PURPLE.g, C_PURPLE.b, ba), 1.5, true)

# ── Polygon helpers ────────────────────────────────────────────────────────

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

# ── Helper ─────────────────────────────────────────────────────────────────

func _nv(weight: int) -> FontVariation:
	return Fonts.nunito(weight)
