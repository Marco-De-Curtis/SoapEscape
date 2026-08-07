extends CanvasLayer

const SafeArea = preload("res://scripts/SafeArea.gd")

# Set from the device's real safe-area inset in _ready. Was hardcoded to 56
# to clear an on-screen Dynamic Island the app drew itself; on hardware
# without one that reserved a band for nothing.
var TOP_Y      := 56.0
const TOP_H    := 48.0
const BOT_H    := 52.0


# Top bar refs
var _top_border:  ColorRect
var _level_label: Label
var _prog_bg:     ColorRect
var _prog_fill:   ColorRect
var _prog_label:  Label

# Bottom bar refs
var _size_bg:    ColorRect
var _size_fill:  ColorRect
var _size_label: Label

func _ready() -> void:
	TOP_Y = SafeArea.content_top(self)
	var root: Control = $HUDRoot
	_build_top_bar(root)
	_build_bottom_bar(root)


# ── Top bar ────────────────────────────────────────────────────────────────

func _build_top_bar(root: Control) -> void:
	var bar := ColorRect.new()
	bar.color        = Color(1.0, 1.0, 1.0, 0.88)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.anchor_left   = 0.0
	bar.anchor_right  = 1.0
	bar.anchor_top    = 0.0
	bar.anchor_bottom = 0.0
	bar.offset_top    = TOP_Y
	bar.offset_bottom = TOP_Y + TOP_H
	root.add_child(bar)

	# Level name — left
	_level_label = Label.new()
	_level_label.add_theme_font_override("font", _nv(700))
	_level_label.add_theme_font_size_override("font_size", 13)
	_level_label.add_theme_color_override("font_color", Color("#d63384"))
	_level_label.anchor_left   = 0.0
	_level_label.anchor_right  = 0.55
	_level_label.anchor_top    = 0.0
	_level_label.anchor_bottom = 1.0
	_level_label.offset_left   = 14.0
	_level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bar.add_child(_level_label)

	# Progress bar background
	_prog_bg = ColorRect.new()
	_prog_bg.color        = Color("#fce7f3")
	_prog_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prog_bg.anchor_left   = 1.0
	_prog_bg.anchor_right  = 1.0
	_prog_bg.anchor_top    = 0.5
	_prog_bg.anchor_bottom = 0.5
	_prog_bg.offset_left   = -130.0
	_prog_bg.offset_right  = -48.0
	_prog_bg.offset_top    = -4.0
	_prog_bg.offset_bottom =  4.0
	bar.add_child(_prog_bg)

	# Progress fill (shrinks left→right as progress goes 0→1)
	_prog_fill = ColorRect.new()
	_prog_fill.color        = Color("#d63384")
	_prog_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prog_fill.anchor_left   = 0.0
	_prog_fill.anchor_right  = 0.0   # updated each frame
	_prog_fill.anchor_top    = 0.0
	_prog_fill.anchor_bottom = 1.0
	_prog_bg.add_child(_prog_fill)

	# Progress % label
	_prog_label = Label.new()
	_prog_label.text = "0%"
	_prog_label.add_theme_font_override("font", _nv(700))
	_prog_label.add_theme_font_size_override("font_size", 13)
	_prog_label.add_theme_color_override("font_color", Color("#7c3aed"))
	_prog_label.anchor_left   = 1.0
	_prog_label.anchor_right  = 1.0
	_prog_label.anchor_top    = 0.0
	_prog_label.anchor_bottom = 1.0
	_prog_label.offset_left   = -46.0
	_prog_label.offset_right  = -6.0
	_prog_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_prog_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	bar.add_child(_prog_label)

	# Accent bottom border
	_top_border = ColorRect.new()
	_top_border.color        = Color("#f9a8d4")
	_top_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_border.anchor_left   = 0.0
	_top_border.anchor_right  = 1.0
	_top_border.anchor_top    = 1.0
	_top_border.anchor_bottom = 1.0
	_top_border.offset_top    = -2.0
	bar.add_child(_top_border)

# ── Bottom soap bar ────────────────────────────────────────────────────────

func _build_bottom_bar(root: Control) -> void:
	var bar := ColorRect.new()
	bar.color        = Color(1.0, 1.0, 1.0, 0.88)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.anchor_left   = 0.0
	bar.anchor_right  = 1.0
	bar.anchor_top    = 1.0
	bar.anchor_bottom = 1.0
	bar.offset_top    = -BOT_H
	root.add_child(bar)

	# Soap emoji
	var emoji := Label.new()
	emoji.text = "🧼"
	emoji.add_theme_font_size_override("font_size", 26)
	emoji.anchor_left   = 0.0
	emoji.anchor_right  = 0.0
	emoji.anchor_top    = 0.0
	emoji.anchor_bottom = 1.0
	emoji.offset_left   = 10.0
	emoji.offset_right  = 44.0
	emoji.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bar.add_child(emoji)

	# Size bar background
	_size_bg = ColorRect.new()
	_size_bg.color        = Color("#fce7f3")
	_size_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_size_bg.anchor_left   = 0.0
	_size_bg.anchor_right  = 1.0
	_size_bg.anchor_top    = 0.5
	_size_bg.anchor_bottom = 0.5
	_size_bg.offset_left   = 52.0
	_size_bg.offset_right  = -58.0
	_size_bg.offset_top    = -5.0
	_size_bg.offset_bottom =  5.0
	bar.add_child(_size_bg)

	# Size fill (right anchor shrinks as soap shrinks)
	_size_fill = ColorRect.new()
	_size_fill.color        = Color("#4ade80")
	_size_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_size_fill.anchor_left   = 0.0
	_size_fill.anchor_right  = 1.0   # starts full
	_size_fill.anchor_top    = 0.0
	_size_fill.anchor_bottom = 1.0
	_size_bg.add_child(_size_fill)

	# Size % label
	_size_label = Label.new()
	_size_label.text = "100%"
	_size_label.add_theme_font_override("font", Fonts.fredoka())
	_size_label.add_theme_font_size_override("font_size", 13)  # Soap % label token
	_size_label.add_theme_color_override("font_color", Color("#d63384"))
	_size_label.anchor_left   = 1.0
	_size_label.anchor_right  = 1.0
	_size_label.anchor_top    = 0.0
	_size_label.anchor_bottom = 1.0
	_size_label.offset_left   = -56.0
	_size_label.offset_right  = -8.0
	_size_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_size_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	bar.add_child(_size_label)

# ── Public API ─────────────────────────────────────────────────────────────

func set_level_name(n: String) -> void:
	var idx := GameData.current_level_index + 1
	_level_label.text = "Level %d — %s" % [idx, n]

func set_accent(accent: Color) -> void:
	if _top_border: _top_border.color = accent
	if _prog_fill:  _prog_fill.color  = accent

func update_size(s: float) -> void:
	var pct := clampf(s, 0.0, 1.0)
	_size_fill.anchor_right = pct
	if   s > 0.50: _size_fill.color = Color("#4ade80")
	elif s > 0.25: _size_fill.color = Color("#facc15")
	else:          _size_fill.color = Color("#f87171")
	_size_label.text = "%d%%" % roundi(s * 100.0)

func update_progress(pct: float) -> void:
	var p := clampf(pct, 0.0, 1.0)
	_prog_fill.anchor_right = p
	_prog_label.text = "%d%%" % roundi(p * 100.0)

# ── Helper ─────────────────────────────────────────────────────────────────

func _nv(weight: int) -> FontVariation:
	return Fonts.nunito(weight)
