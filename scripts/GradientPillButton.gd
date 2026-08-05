class_name GradientPillButton
extends Control

signal pressed

@export var label_text:   String = ""
@export var color_left:   Color  = Color("#d63384")
@export var color_right:  Color  = Color("#7c3aed")
@export var corner_radius: float = 29.0
@export var interactive:  bool   = true  # false = purely decorative fill (e.g. progress bars); no input capture, no label

var _label: Label
var _btn:   Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE if not interactive else Control.MOUSE_FILTER_STOP

	if interactive:
		_btn = Button.new()
		_btn.flat        = true
		_btn.focus_mode  = Control.FOCUS_NONE
		_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_btn.add_theme_stylebox_override("normal",  StyleBoxEmpty.new())
		_btn.add_theme_stylebox_override("hover",   StyleBoxEmpty.new())
		_btn.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
		_btn.add_theme_stylebox_override("focus",   StyleBoxEmpty.new())
		_btn.pressed.connect(func(): pressed.emit())
		add_child(_btn)

		_label = Label.new()
		_label.text = label_text
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		_label.add_theme_color_override("font_color", Color.WHITE)
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(_label)

	resized.connect(queue_redraw)
	queue_redraw()

func set_font(font: Font, size: int) -> void:
	if not interactive: return
	if not _label:
		await ready
	_label.add_theme_font_override("font", font)
	_label.add_theme_font_size_override("font_size", size)

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0: return
	var hw := size.x * 0.5
	var hh := size.y * 0.5
	var r  := minf(corner_radius, minf(hw, hh))
	var pts := _rrect_pts(hw, hh, r)
	var colors := PackedColorArray()
	for p in pts:
		var t: float = clampf(p.x / size.x, 0.0, 1.0)
		colors.append(color_left.lerp(color_right, t))
	draw_polygon(pts, colors)

func _rrect_pts(hw: float, hh: float, r: float) -> PackedVector2Array:
	r = minf(r, minf(hw, hh) * 0.99)
	var pts := PackedVector2Array()
	var ccx := PackedFloat32Array([-hw + r, hw - r, hw - r, -hw + r])
	var ccy := PackedFloat32Array([-hh + r, -hh + r, hh - r, hh - r])
	var ca0 := PackedFloat32Array([PI, -PI * 0.5, 0.0, PI * 0.5])
	for i in 4:
		for j in 4:
			var a: float = ca0[i] + PI * 0.5 * float(j) / 3.0
			pts.append(Vector2(hw + ccx[i] + cos(a) * r, hh + ccy[i] + sin(a) * r))
	return pts
