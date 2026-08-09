class_name MiniSoapIcon
extends Node2D

# Thin wrapper around SoapArt so UI can drop a soap character anywhere.
# All appearance lives in SoapArt — do not draw the character by hand here.

@export var body_scale:  float = 3.0
@export var state:       int   = SoapArt.VICTORY
@export var fill_override: Color = Color(0, 0, 0, 0)

# Optional decorative texture drawn over the fill (used by the skins gallery).
# "none" | "dots" | "stripes" | "swirl" | "gradient"
@export var texture_type: String = "none"
@export var texture_gradient: Gradient

func _draw() -> void:
	var w := SoapArt.BASE_WIDTH * body_scale
	var h := SoapArt.BASE_HEIGHT * body_scale
	var hw := w * 0.5
	var hh := h * 0.5

	if texture_type == "gradient" and texture_gradient:
		# Gradient skins replace the flat fill, then the face is painted on top.
		draw_colored_polygon(SoapArt.body_outline(hw, hh), SoapArt.OUTLINE_COLOR)
		draw_colored_polygon(SoapArt.body_violet(hw, hh), SoapArt.VIOLET_BAND_COLOR)
		draw_colored_polygon(SoapArt.body_white(hw, hh), SoapArt.WHITE_BAND_COLOR)
		_draw_gradient_fill(hw, hh)
		_draw_texture(hw, hh)
		SoapArt.paint_face_only(self, Vector2.ZERO, body_scale, state)
	elif texture_type != "none":
		draw_colored_polygon(SoapArt.body_outline(hw, hh), SoapArt.OUTLINE_COLOR)
		draw_colored_polygon(SoapArt.body_violet(hw, hh), SoapArt.VIOLET_BAND_COLOR)
		draw_colored_polygon(SoapArt.body_white(hw, hh), SoapArt.WHITE_BAND_COLOR)
		draw_colored_polygon(SoapArt.body_fill(hw, hh), _fill())
		_draw_texture(hw, hh)
		SoapArt.paint_face_only(self, Vector2.ZERO, body_scale, state)
	else:
		SoapArt.paint(self, Vector2.ZERO, body_scale, state, fill_override)

func _fill() -> Color:
	return fill_override if fill_override.a > 0.0 else SoapArt.fill_color(state)

func _draw_gradient_fill(hw: float, hh: float) -> void:
	var pts := SoapArt.body_fill(hw, hh)
	var colors := PackedColorArray()
	for p in pts:
		var t: float = clampf((p.x + hw) / (hw * 2.0), 0.0, 1.0)
		colors.append(texture_gradient.sample(t))
	draw_polygon(pts, colors)

func _draw_texture(hw: float, hh: float) -> void:
	match texture_type:
		"dots":
			var pts: Array[Vector2] = [
				Vector2(-hw * 0.42, -hh * 0.40), Vector2(hw * 0.10, -hh * 0.50),
				Vector2(-hw * 0.10,  hh * 0.05), Vector2(hw * 0.44,  hh * 0.10),
				Vector2(-hw * 0.46,  hh * 0.40), Vector2(hw * 0.05, -hh * 0.10),
			]
			for p in pts:
				draw_colored_polygon(SoapArt.circle(p, hw * 0.05, 8), Color(1.0, 1.0, 1.0, 0.55))
		"stripes":
			var x := -hw
			while x < hw:
				draw_line(Vector2(x, -hh), Vector2(x + hh * 1.4, hh), Color(1.0, 1.0, 1.0, 0.35), hw * 0.09, true)
				x += hw * 0.36
		"swirl":
			for i in 3:
				var pts2 := PackedVector2Array()
				var yo: float = -hh * 0.4 + hh * 0.4 * float(i)
				for j in 9:
					var t: float = float(j) / 8.0
					pts2.append(Vector2(-hw * 0.7 + hw * 1.4 * t, yo + sin(t * PI * 2.0 + float(i)) * hh * 0.12))
				draw_polyline(pts2, Color(0.6, 0.65, 0.72, 0.4), 1.4, true)
