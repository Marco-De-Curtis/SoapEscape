class_name WetBubble
extends Polygon2D

var _speed:    float
var _top_y:    float
var _bottom_y: float

func setup(x: float, start_y: float, r: float, speed: float, zone_h: float) -> void:
	_speed    = speed
	_top_y    = -zone_h * 0.5 - r - 4.0
	_bottom_y =  zone_h * 0.5
	position  = Vector2(x, start_y)
	polygon   = _circle_pts(r)
	color     = Color(0.55, 0.82, 1.0, 0.28)

func _process(delta: float) -> void:
	position.y -= _speed * delta
	var t: float = clampf((position.y - _bottom_y) / (_top_y - _bottom_y), 0.0, 1.0)
	color.a = 0.28 * (1.0 - t * t)
	if position.y < _top_y:
		position.y = _bottom_y
		color.a    = 0.0

func _circle_pts(r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 10:
		var a: float = TAU * float(i) / 10.0
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts
