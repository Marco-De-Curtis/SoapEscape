class_name FlagIcon
extends Node2D

# Small vector-drawn national flags, keyed by ISO 3166-1 alpha-2 code.
#
# LevelData used to hold the flag as an emoji character and every screen
# printed it inline with the level name. Fredoka/Nunito carry no emoji
# glyphs at all, and there is no reliable cross-platform emoji fallback —
# Windows in particular renders flag sequences as bare two-letter codes
# instead of an actual flag. Drawing the flags ourselves, the same way
# every other visual in this game is drawn, sidesteps font support
# entirely: it looks identical on every platform.

@export var country:      String = "GR"
@export var icon_width:   float  = 20.0
@export var icon_height:  float  = 14.0

func _draw() -> void:
	var hw: float = icon_width * 0.5
	var hh: float = icon_height * 0.5
	match country:
		"GR": _greece(hw, hh)
		"CO": _colombia(hw, hh)
		"IT": _italy(hw, hh)
		"NL": _netherlands(hw, hh)
		"DM": _dominica(hw, hh)
		"BW": _botswana(hw, hh)
		"FI": _finland(hw, hh)
		"JP": _japan(hw, hh)
		"AR": _argentina(hw, hh)
		"GB": _uk(hw, hh)
		_:
			draw_rect(Rect2(-hw, -hh, hw * 2.0, hh * 2.0), Color("#d1d5db"))
	draw_rect(Rect2(-hw, -hh, hw * 2.0, hh * 2.0), Color(0.0, 0.0, 0.0, 0.28), false, 1.0)

func _greece(hw: float, hh: float) -> void:
	var blue  := Color("#0D5EAF")
	var white := Color.WHITE
	var stripe_h: float = (hh * 2.0) / 5.0
	for i in 5:
		draw_rect(Rect2(-hw, -hh + stripe_h * i, hw * 2.0, stripe_h), blue if i % 2 == 0 else white)

func _colombia(hw: float, hh: float) -> void:
	var h: float = hh * 2.0
	draw_rect(Rect2(-hw, -hh,               hw * 2.0, h * 0.5),  Color("#FCD116"))
	draw_rect(Rect2(-hw, -hh + h * 0.5,      hw * 2.0, h * 0.25), Color("#003893"))
	draw_rect(Rect2(-hw, -hh + h * 0.75,     hw * 2.0, h * 0.25), Color("#CE1126"))

func _italy(hw: float, hh: float) -> void:
	var w3: float = (hw * 2.0) / 3.0
	draw_rect(Rect2(-hw,             -hh, w3, hh * 2.0), Color("#008C45"))
	draw_rect(Rect2(-hw + w3,        -hh, w3, hh * 2.0), Color.WHITE)
	draw_rect(Rect2(-hw + w3 * 2.0,  -hh, w3, hh * 2.0), Color("#CD212A"))

func _netherlands(hw: float, hh: float) -> void:
	var h3: float = (hh * 2.0) / 3.0
	draw_rect(Rect2(-hw, -hh,              hw * 2.0, h3), Color("#AE1C28"))
	draw_rect(Rect2(-hw, -hh + h3,         hw * 2.0, h3), Color.WHITE)
	draw_rect(Rect2(-hw, -hh + h3 * 2.0,   hw * 2.0, h3), Color("#21468B"))

func _dominica(hw: float, hh: float) -> void:
	# Full flag (parrot, ten stars, tri-colour cross) doesn't survive at
	# icon size — keep the part that reads at a glance: green field, a
	# yellow/black/white cross, red disc at the centre.
	draw_rect(Rect2(-hw, -hh, hw * 2.0, hh * 2.0), Color("#006B3F"))
	var bar_w: float = hw
	var third_v: float = bar_w / 3.0
	draw_rect(Rect2(-third_v * 1.5,               -hh, third_v, hh * 2.0), Color("#FCD116"))
	draw_rect(Rect2(-third_v * 1.5 + third_v,      -hh, third_v, hh * 2.0), Color.BLACK)
	draw_rect(Rect2(-third_v * 1.5 + third_v * 2.0, -hh, third_v, hh * 2.0), Color.WHITE)
	var third_h: float = hh / 3.0
	draw_rect(Rect2(-hw, -third_h * 1.5,               hw * 2.0, third_h), Color("#FCD116"))
	draw_rect(Rect2(-hw, -third_h * 1.5 + third_h,      hw * 2.0, third_h), Color.BLACK)
	draw_rect(Rect2(-hw, -third_h * 1.5 + third_h * 2.0, hw * 2.0, third_h), Color.WHITE)
	draw_circle(Vector2.ZERO, hh * 0.35, Color("#CE1126"))

func _botswana(hw: float, hh: float) -> void:
	draw_rect(Rect2(-hw, -hh, hw * 2.0, hh * 2.0), Color("#75AADB"))
	var band_h: float = hh * 0.75
	draw_rect(Rect2(-hw, -band_h * 0.5,                       hw * 2.0, band_h),        Color.BLACK)
	draw_rect(Rect2(-hw, -band_h * 0.5 + band_h * 0.18,       hw * 2.0, band_h * 0.64), Color.WHITE)

func _finland(hw: float, hh: float) -> void:
	draw_rect(Rect2(-hw, -hh, hw * 2.0, hh * 2.0), Color.WHITE)
	var blue := Color("#003580")
	var cross_x: float = -hw * 0.15
	var thick_v: float = hw * 0.34
	var thick_h: float = hh * 0.34
	draw_rect(Rect2(cross_x - thick_v * 0.5, -hh, thick_v, hh * 2.0), blue)
	draw_rect(Rect2(-hw, -thick_h * 0.5, hw * 2.0, thick_h), blue)

func _japan(hw: float, hh: float) -> void:
	draw_rect(Rect2(-hw, -hh, hw * 2.0, hh * 2.0), Color.WHITE)
	draw_circle(Vector2.ZERO, hh * 0.55, Color("#BC002D"))

func _argentina(hw: float, hh: float) -> void:
	var h3: float = (hh * 2.0) / 3.0
	var light_blue := Color("#74ACDF")
	draw_rect(Rect2(-hw, -hh,             hw * 2.0, h3), light_blue)
	draw_rect(Rect2(-hw, -hh + h3,        hw * 2.0, h3), Color.WHITE)
	draw_rect(Rect2(-hw, -hh + h3 * 2.0,  hw * 2.0, h3), light_blue)
	draw_circle(Vector2.ZERO, hh * 0.22, Color("#F6B40E"))

func _uk(hw: float, hh: float) -> void:
	var navy  := Color("#00247D")
	var white := Color.WHITE
	var red   := Color("#CF142B")
	draw_rect(Rect2(-hw, -hh, hw * 2.0, hh * 2.0), navy)
	draw_line(Vector2(-hw, -hh), Vector2(hw, hh), white, hh * 0.55, false)
	draw_line(Vector2(-hw, hh),  Vector2(hw, -hh), white, hh * 0.55, false)
	draw_line(Vector2(-hw, -hh), Vector2(hw, hh), red, hh * 0.22, false)
	draw_line(Vector2(-hw, hh),  Vector2(hw, -hh), red, hh * 0.22, false)
	draw_rect(Rect2(-hw * 0.18, -hh, hw * 0.36, hh * 2.0), white)
	draw_rect(Rect2(-hw, -hh * 0.28, hw * 2.0, hh * 0.56), white)
	draw_rect(Rect2(-hw * 0.09, -hh, hw * 0.18, hh * 2.0), red)
	draw_rect(Rect2(-hw, -hh * 0.14, hw * 2.0, hh * 0.28), red)
