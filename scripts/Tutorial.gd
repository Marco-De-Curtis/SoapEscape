extends CanvasLayer

const C_PINK   := Color("#d63384")
const C_PURPLE := Color("#7c3aed")

const SLIDES: Array[Dictionary] = [
	{
		"emoji": "👆",
		"title": "Lean to steer",
		"body":  "Hold LEFT or RIGHT side of the screen\nto slide your soap sideways.",
		"hint":  "Tap anywhere to continue",
	},
	{
		"emoji": "⚠️",
		"title": "Watch out!",
		"body":  "An obstacle is ahead.\nTime your lean to dodge it.",
		"hint":  "",
	},
	{
		"emoji": "🛡️",
		"title": "Bubble shield!",
		"body":  "Grab the floating bubble —\nit absorbs one hit for you.",
		"hint":  "",
	},
]


var _level_id:           int   = 0
var _is_auto_dismiss:    bool  = false
var _auto_dismiss_timer: float = 0.0

func setup(level_id: int) -> void:
	_level_id        = level_id
	layer            = 20
	process_mode     = PROCESS_MODE_ALWAYS
	get_tree().paused = true

	var idx := clampi(level_id - 1, 0, SLIDES.size() - 1)
	var slide: Dictionary = SLIDES[idx]

	if level_id == 1:
		_is_auto_dismiss = false
	else:
		_is_auto_dismiss    = true
		_auto_dismiss_timer = 2.5

	_build_ui(slide)

func _build_ui(slide: Dictionary) -> void:
	# Dim overlay
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)

	var dim := ColorRect.new()
	dim.color        = Color(0.0, 0.0, 0.0, 0.55)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.anchor_right  = 1.0
	dim.anchor_bottom = 1.0
	root.add_child(dim)

	# Card
	var card := Panel.new()
	var csty := StyleBoxFlat.new()
	csty.set_corner_radius_all(24)
	csty.bg_color    = Color.WHITE
	csty.set_border_width_all(3)
	csty.border_color = GameData.level_accent
	card.add_theme_stylebox_override("panel", csty)
	card.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	card.anchor_left   = 0.0; card.anchor_right  = 1.0
	card.offset_left   = 36.0; card.offset_right = -36.0
	card.offset_top    = 280.0; card.offset_bottom = 500.0
	root.add_child(card)

	# Emoji
	var emoji := Label.new()
	emoji.text = slide.get("emoji", "💡")
	emoji.add_theme_font_size_override("font_size", 56)
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji.anchor_left  = 0.0; emoji.anchor_right  = 1.0
	emoji.offset_top   = 18.0; emoji.offset_bottom = 82.0
	card.add_child(emoji)

	# Title
	var title := Label.new()
	title.text = slide.get("title", "")
	title.add_theme_font_override("font", Fonts.fredoka())
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", C_PINK)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.anchor_left  = 0.0; title.anchor_right  = 1.0
	title.offset_top   = 86.0; title.offset_bottom = 126.0
	card.add_child(title)

	# Body
	var body := Label.new()
	body.text = slide.get("body", "")
	body.add_theme_font_override("font", _nv(400))
	body.add_theme_font_size_override("font_size", 15)
	body.add_theme_color_override("font_color", Color("#6b7280"))
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.anchor_left   = 0.0; body.anchor_right  = 1.0
	body.offset_left   = 16.0; body.offset_right = -16.0
	body.offset_top    = 132.0; body.offset_bottom = 192.0
	card.add_child(body)

	# Hint / auto-dismiss progress
	var hint_str: String = slide.get("hint", "")
	if _is_auto_dismiss:
		hint_str = "Dismissing automatically…"
	if hint_str.length() > 0:
		var hint := Label.new()
		hint.text = hint_str
		hint.add_theme_font_override("font", _nv(500))
		hint.add_theme_font_size_override("font_size", 12)
		hint.add_theme_color_override("font_color", Color("#9ca3af"))
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.anchor_left  = 0.0; hint.anchor_right  = 1.0
		hint.offset_top   = 194.0; hint.offset_bottom = 218.0
		card.add_child(hint)

func _process(delta: float) -> void:
	if _is_auto_dismiss:
		_auto_dismiss_timer -= delta
		if _auto_dismiss_timer <= 0.0:
			_dismiss()

func _input(event: InputEvent) -> void:
	if _is_auto_dismiss: return
	if event is InputEventScreenTouch:
		if (event as InputEventScreenTouch).pressed:
			_dismiss()
	elif event is InputEventMouseButton:
		if (event as InputEventMouseButton).pressed:
			_dismiss()

func _dismiss() -> void:
	get_tree().paused = false
	queue_free()

func _nv(weight: int) -> FontVariation:
	return Fonts.nunito(weight)
