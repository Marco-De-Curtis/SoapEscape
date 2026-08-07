extends Control

# Static visual gallery only — no unlock tracking, no persistence, no gameplay
# effect. None of the skin-specific colors below come from the tokens file
# (it doesn't cover this screen); they're read off designs/soap_skins screenshot.

const C_OUTLINE := Color("#1a1a2e")
const C_PINK    := Color("#d63384")
const C_PURPLE  := Color("#7c3aed")
const C_GOLD    := Color("#f59e0b")  # color_star_gold token — used for the Rainbow skin only

const SKINS: Array[Dictionary] = [
	{"name": "Classic",  "caption": "DEFAULT",      "status": "Default",      "fill": Color("#c4b5fd"), "texture": "none",
		"status_bg": Color("#ede9fe"), "status_fg": Color("#7c3aed")},
	{"name": "Citrus",   "caption": "COMPLETE L3",  "status": "Level 3",      "fill": Color("#fde047"), "texture": "dots",
		"status_bg": Color("#fef9c3"), "status_fg": Color("#a16207")},
	{"name": "Rose",     "caption": "COMPLETE L5",  "status": "Level 5",      "fill": Color("#fbcfe8"), "texture": "stripes",
		"status_bg": Color("#fce7f3"), "status_fg": Color("#be185d")},
	{"name": "Charcoal", "caption": "COMPLETE L7",  "status": "Level 7",      "fill": Color("#1f2937"), "texture": "none",
		"status_bg": Color("#e5e7eb"), "status_fg": Color("#374151"), "eye_color": Color("#e5e7eb")},
	{"name": "Marble",   "caption": "COMPLETE L9",  "status": "Level 9",      "fill": Color("#f8fafc"), "texture": "swirl",
		"status_bg": Color("#e2e8f0"), "status_fg": Color("#475569")},
	{"name": "Rainbow",  "caption": "ALL 10 +",     "status": "All 10 levels","fill": Color("#fde047"), "texture": "gradient",
		"status_bg": Color("#fed7aa"), "status_fg": Color("#c2410c")},
]


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#ffffff")  # color_white
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_build_header()
	_build_gallery()


func _build_header() -> void:
	var back := Button.new()
	back.text = "← Back"
	back.flat = true
	back.focus_mode = Control.FOCUS_NONE
	back.add_theme_font_override("font", _nv(700))
	back.add_theme_font_size_override("font_size", 14)
	back.add_theme_color_override("font_color",       C_PURPLE)
	back.add_theme_color_override("font_hover_color", C_PURPLE)
	back.add_theme_stylebox_override("normal",  StyleBoxEmpty.new())
	back.add_theme_stylebox_override("hover",   StyleBoxEmpty.new())
	back.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	back.add_theme_stylebox_override("focus",   StyleBoxEmpty.new())
	back.anchor_left = 0.0; back.anchor_right = 0.0
	back.offset_left = 20.0; back.offset_right = 90.0
	back.offset_top  = 64.0; back.offset_bottom = 88.0
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/HomeScreen.tscn"))
	add_child(back)

	var title := Label.new()
	title.text = "Soap Skins"
	title.add_theme_font_override("font", Fonts.fredoka())
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", C_PINK)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.anchor_left  = 0.0; title.anchor_right  = 1.0
	title.offset_top   = 98.0; title.offset_bottom = 138.0
	add_child(title)

func _build_gallery() -> void:
	var scroll := ScrollContainer.new()
	scroll.anchor_left  = 0.0; scroll.anchor_right  = 1.0
	scroll.offset_top    = 160.0
	scroll.offset_bottom = 380.0
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	scroll.add_child(row)

	var spacer_l := Control.new()
	spacer_l.custom_minimum_size = Vector2(12.0, 1.0)
	row.add_child(spacer_l)

	for skin: Dictionary in SKINS:
		row.add_child(_build_card(skin))

	var spacer_r := Control.new()
	spacer_r.custom_minimum_size = Vector2(12.0, 1.0)
	row.add_child(spacer_r)

func _build_card(skin: Dictionary) -> Control:
	var card := VBoxContainer.new()
	card.custom_minimum_size = Vector2(150.0, 210.0)
	card.alignment = BoxContainer.ALIGNMENT_BEGIN
	card.add_theme_constant_override("separation", 8)

	var is_rainbow: bool = str(skin["name"]) == "Rainbow"

	var caption := Label.new()
	caption.text = str(skin["caption"])
	caption.add_theme_font_override("font", _nv(700))
	caption.add_theme_font_size_override("font_size", 10)
	caption.add_theme_color_override("font_color", C_GOLD if is_rainbow else Color("#9ca3af"))
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(caption)

	var icon_wrap := Control.new()
	icon_wrap.custom_minimum_size = Vector2(150.0, 76.0)
	var icon := MiniSoapIcon.new()
	icon.body_scale  = 1.9
	icon.state         = SoapArt.CALM
	icon.fill_override = skin["fill"]
	icon.texture_type = str(skin["texture"])
	icon.position = Vector2(75.0, 38.0)
	if icon.texture_type == "gradient":
		var grad := Gradient.new()
		grad.set_color(0, Color("#fb923c"))
		grad.add_point(0.33, Color("#4ade80"))
		grad.add_point(0.66, Color("#38bdf8"))
		grad.set_color(1, Color("#c084fc"))
		icon.texture_gradient = grad
	icon_wrap.add_child(icon)
	card.add_child(icon_wrap)

	var name_lbl := Label.new()
	name_lbl.text = str(skin["name"])
	name_lbl.add_theme_font_override("font", Fonts.fredoka())
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override("font_color", C_GOLD if is_rainbow else C_PURPLE)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(name_lbl)

	var pill := Panel.new()
	var psty := StyleBoxFlat.new()
	psty.bg_color = skin["status_bg"]
	psty.set_corner_radius_all(10)
	pill.add_theme_stylebox_override("panel", psty)
	pill.custom_minimum_size = Vector2(0.0, 22.0)
	var pill_lbl := Label.new()
	pill_lbl.text = str(skin["status"])
	pill_lbl.add_theme_font_override("font", _nv(700))
	pill_lbl.add_theme_font_size_override("font_size", 11)
	pill_lbl.add_theme_color_override("font_color", skin["status_fg"])
	pill_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pill_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	pill_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pill.add_child(pill_lbl)
	var pill_wrap := CenterContainer.new()
	pill_wrap.add_child(pill)
	card.add_child(pill_wrap)

	return card

func _nv(weight: int) -> FontVariation:
	return Fonts.nunito(weight)
