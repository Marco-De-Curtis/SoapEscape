class_name Soap
extends CharacterBody2D

# Body/face sizes and colours live in SoapArt — the single source of truth
# shared with every UI screen. Only gameplay-side constants belong here.
const BASE_WIDTH:    float = SoapArt.BASE_WIDTH
const BASE_HEIGHT:   float = SoapArt.BASE_HEIGHT
const LATERAL_SCALE: float = 60.0
const EASE_RATE:     float = 0.060
const SHRINK_RATE:   float = 0.012

# Distance in points a finger has to drag, from wherever it first touched
# down, to swing steering from where a tap left it to fully the other way.
# Deliberately relative to the touch's OWN start point, not the screen's
# centre: a rightward swipe must always ease toward/into a rightward lean,
# even if the whole swipe happens on the left half of the screen and never
# crosses the middle. This is the number to retune first if steering feels
# too twitchy (lower it) or too heavy (raise it) once tested on a real
# device.
const STEER_DRAG_RADIUS: float = 90.0

const OUTLINE_COLOR := SoapArt.OUTLINE_COLOR

var size:           float = 1.0
var lean_magnitude: float = 0.0
# Continuous, [-1, 1]: how far, and which way, the player is currently
# steering. -1 / 0 / 1 remain valid (Game.gd's reset and the screenshot
# rig in _shots.gd both assign those directly).
var lean_direction: float = 0.0
var has_shield:     bool  = false
var is_dead:        bool  = false
var victory:        bool  = false
var forward_speed:    float = 165.0
var lane_half:        float = 130.0
var obstacle_damage:  float = 0.25

var _in_wet_zone_count: int   = 0
var _wet_t:             float = 0.0
var _steer_touch_index: int   = -1  # -1 = no active steering touch
var _steer_anchor_x:    float = 0.0 # where that touch first landed
var _steer_tap_bias:    float = 0.0 # instant lean from which half it was on

signal died(reason: String)
signal size_changed(new_size: float)
signal wet_zone_changed(in_zone: bool)

# Scene nodes
@onready var soap_body:     Polygon2D        = $SoapBody
@onready var shield_bubble: Polygon2D        = $ShieldBubble
@onready var face_node:     Node2D           = $Face
@onready var left_eye:      Polygon2D        = $Face/LeftEye
@onready var right_eye:     Polygon2D        = $Face/RightEye
@onready var mouth:         Line2D           = $Face/Mouth
@onready var col_shape:     CollisionShape2D = $CollisionShape2D

# Created in _ready
var _soap_fill:   Polygon2D
var _soap_shine:  Polygon2D
var _left_cheek:  Polygon2D
var _right_cheek: Polygon2D
var _left_eye_shine:  Polygon2D
var _right_eye_shine: Polygon2D
var _left_eye_spark:  Polygon2D
var _right_eye_spark: Polygon2D
var _speed_lines: Array[Line2D] = []

func _ready() -> void:
	# Outline body stays as SoapBody (dark, renders first/behind)
	soap_body.color = OUTLINE_COLOR
	soap_body.z_index = 0

	# Fill layer — same shape but inset ~15%, renders on top of outline
	_soap_fill = Polygon2D.new()
	_soap_fill.color   = SoapArt.FILL_COLORS[0]
	_soap_fill.z_index = 1
	add_child(_soap_fill)

	# Specular highlight — top-left of body
	_soap_shine = Polygon2D.new()
	_soap_shine.color   = SoapArt.SHEEN_COLOR
	_soap_shine.z_index = 2
	add_child(_soap_shine)

	# Face must render above the fill (z=1) and shine (z=2) layers, otherwise
	# the fill polygon completely hides the eyes/mouth.
	face_node.z_index = 3

	# Cheeks — children of face so they move with face offset.
	# move_child(…, 0) keeps them *behind* the eyes and mouth.
	_left_cheek = Polygon2D.new()
	_left_cheek.color = SoapArt.CHEEK_COLOR
	face_node.add_child(_left_cheek)
	face_node.move_child(_left_cheek, 0)

	_right_cheek = Polygon2D.new()
	_right_cheek.color = SoapArt.CHEEK_COLOR
	face_node.add_child(_right_cheek)
	face_node.move_child(_right_cheek, 1)

	# Eye shine dots — "Dolce e morbida" calm-face refresh
	_left_eye_shine = Polygon2D.new()
	_left_eye_shine.color = SoapArt.SHINE_COLOR
	face_node.add_child(_left_eye_shine)

	_right_eye_shine = Polygon2D.new()
	_right_eye_shine.color = SoapArt.SHINE_COLOR
	face_node.add_child(_right_eye_shine)

	# Second, smaller sparkle — the classic kawaii two-highlight eye
	_left_eye_spark = Polygon2D.new()
	_left_eye_spark.color = SoapArt.SPARK_COLOR
	face_node.add_child(_left_eye_spark)

	_right_eye_spark = Polygon2D.new()
	_right_eye_spark.color = SoapArt.SPARK_COLOR
	face_node.add_child(_right_eye_spark)

	for i in 6:
		var ln := Line2D.new()
		ln.width = 1.8
		ln.default_color = Color.WHITE
		add_child(ln)
		_speed_lines.append(ln)

	shield_bubble.hide()
	mouth.width         = 2.8
	mouth.default_color = OUTLINE_COLOR
	left_eye.color      = OUTLINE_COLOR
	right_eye.color     = OUTLINE_COLOR

# ── Input ──────────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if is_dead: return

	# Steering used to be decided once, at the moment a finger touched down
	# (by which half of the screen it landed on), and then ignored for the
	# rest of that touch. That meant a swipe from the left half toward the
	# right — without ever crossing the screen's physical centre — produced
	# no change at all: it was still "the left half" the whole way.
	#
	# A tap still gives the old instant full-strength lean, from which half
	# it landed on (_steer_tap_bias). Dragging then adds a continuous offset
	# measured from THIS TOUCH'S OWN starting point, not the screen centre,
	# so a rightward swipe always eases toward and past a rightward lean,
	# regardless of which half of the screen it happens on.
	if event is InputEventScreenTouch:
		var e := event as InputEventScreenTouch
		if e.pressed:
			if _steer_touch_index == -1:
				_steer_touch_index = e.index
				_steer_anchor_x    = e.position.x
				var centre := get_viewport().get_visible_rect().size.x * 0.5
				_steer_tap_bias = -1.0 if e.position.x < centre else 1.0
				lean_direction  = _steer_tap_bias
			# A second simultaneous touch is ignored rather than fought over;
			# only the touch that started steering can change it.
		elif e.index == _steer_touch_index:
			_steer_touch_index = -1
			lean_direction = 0.0
	elif event is InputEventScreenDrag:
		var e := event as InputEventScreenDrag
		if e.index == _steer_touch_index:
			var offset := e.position.x - _steer_anchor_x
			lean_direction = clampf(_steer_tap_bias + offset / STEER_DRAG_RADIUS, -1.0, 1.0)

# ── Physics ────────────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	if is_dead: return

	if _steer_touch_index == -1:
		if   Input.is_action_pressed("lean_left"):  lean_direction = -1.0
		elif Input.is_action_pressed("lean_right"): lean_direction = 1.0
		else:                                        lean_direction = 0.0

	_apply_lateral_physics()
	velocity.y = forward_speed
	move_and_slide()

	position.x = clampf(position.x,
		-lane_half + get_width() * 0.5,
		lane_half - get_width() * 0.5)

	if get_slide_collision_count() > 0:
		velocity.x     = 0.0
		lean_magnitude = 0.0

	if _in_wet_zone_count > 0:
		size = maxf(0.0, size - SHRINK_RATE * delta)
		size_changed.emit(size)
		if size <= 0.0 and not is_dead:
			_trigger_death("dissolved")

	if _in_wet_zone_count > 0:
		_wet_t += delta
	else:
		_wet_t = 0.0

	_update_collision_shape()
	_update_visuals()
	_update_speed_lines()

func _apply_lateral_physics() -> void:
	var build_rate: float = 0.028 + size * 0.042
	var max_vel:    float = 2.0   + size * 2.2
	if lean_direction != 0.0:
		lean_magnitude = clampf(lean_magnitude + build_rate, 0.0, 1.0)
	else:
		lean_magnitude = maxf(0.0, lean_magnitude - EASE_RATE)
	velocity.x += lean_direction * lean_magnitude * max_vel * 0.13
	velocity.x *= 0.80
	velocity.x  = clampf(velocity.x, -max_vel, max_vel)
	velocity.x *= LATERAL_SCALE

# ── Size helpers ───────────────────────────────────────────────────────────

func get_width()  -> float: return maxf(10.0, BASE_WIDTH  * size)
func get_height() -> float: return maxf(6.0,  BASE_HEIGHT * size)

func restore(amount: float) -> void:
	size = minf(1.0, size + amount)
	size_changed.emit(size)

func get_face_state() -> int:
	if victory:    return 4
	if size > 0.6: return 0
	if size > 0.4: return 1
	if size > 0.2: return 2
	return 3

# ── Zone / pickup / obstacle callbacks ─────────────────────────────────────

func enter_wet_zone() -> void:
	_in_wet_zone_count += 1
	if _in_wet_zone_count == 1:
		AudioManager.play("enter_wet")
		AudioManager.play_loop("shrink_loop")
		wet_zone_changed.emit(true)

func exit_wet_zone() -> void:
	_in_wet_zone_count = maxi(0, _in_wet_zone_count - 1)
	if _in_wet_zone_count == 0:
		AudioManager.stop_loop("shrink_loop")
		wet_zone_changed.emit(false)

func collect_pickup(type: String) -> void:
	if type == "soap_sliver":
		restore(0.12)
		AudioManager.play("pickup_sliver")
		GameData.do_haptic(0)
	elif type == "bubble_shield":
		has_shield = true
		shield_bubble.show()
		shield_bubble.modulate.a = 1.0
		AudioManager.play("pickup_shield")
		GameData.do_haptic(0)

func handle_obstacle_hit() -> void:
	if is_dead: return
	if has_shield:
		has_shield = false
		AudioManager.play("shield_break")
		GameData.do_haptic(1)
		var tw := create_tween()
		tw.tween_property(shield_bubble, "modulate:a", 0.0, 0.3)
		tw.tween_callback(shield_bubble.hide)
	else:
		AudioManager.play("obstacle_hit")
		GameData.do_haptic(2)
		size = maxf(0.0, size - obstacle_damage)
		size_changed.emit(size)
		var tw := create_tween()
		tw.tween_property(_soap_fill, "modulate", Color(1.0, 0.3, 0.3, 1.0), 0.05)
		tw.tween_property(_soap_fill, "modulate", Color.WHITE, 0.15)
		if size <= 0.0:
			if _in_wet_zone_count > 0:
				_trigger_death("dissolved")
			else:
				_trigger_death("obstacle")

func _trigger_death(reason: String) -> void:
	if is_dead: return
	is_dead = true
	died.emit(reason)

# ── Visuals ────────────────────────────────────────────────────────────────

func _update_collision_shape() -> void:
	if col_shape.shape is RectangleShape2D:
		(col_shape.shape as RectangleShape2D).size = Vector2(get_width(), get_height())

func _update_visuals() -> void:
	var w := get_width()
	var h := get_height()
	var state := get_face_state()

	_update_body(w, h, state)
	_update_shield(w, h)
	_update_squash()
	_update_face(w, h, state)

func _update_body(w: float, h: float, state: int) -> void:
	var hw := w * 0.5
	var hh := h * 0.5

	soap_body.polygon  = SoapArt.body_outline(hw, hh)
	_soap_fill.polygon = SoapArt.body_fill(hw, hh)

	var base_color: Color = SoapArt.fill_color(state)
	if _in_wet_zone_count > 0:
		var pulse := 0.5 + 0.5 * sin(_wet_t * TAU * 1.5)
		base_color = base_color.lerp(Color(0.55, 0.82, 1.0), 0.25 + pulse * 0.25)
	_soap_fill.color = _soap_fill.color.lerp(base_color, 0.08)

	_soap_shine.polygon = SoapArt.sheen(hw, hh)

func _update_shield(w: float, h: float) -> void:
	if shield_bubble.visible:
		var r: float = maxf(w, h) * 0.65
		shield_bubble.polygon = SoapArt.circle(Vector2.ZERO, r, 24)
		shield_bubble.color   = Color(0.4, 0.85, 1.0, 0.3)

func _update_squash() -> void:
	var t := lean_magnitude * absf(float(lean_direction))
	if lean_direction != 0:
		soap_body.scale  = soap_body.scale.lerp(Vector2(1.08, 0.95), 0.20)
		_soap_fill.scale = soap_body.scale
	else:
		soap_body.scale  = soap_body.scale.lerp(Vector2.ONE, 0.15)
		_soap_fill.scale = soap_body.scale

func _update_face(w: float, h: float, state: int) -> void:
	# Every metric comes from SoapArt so the in-game character and the menu
	# screens can never drift apart again.
	var eo := SoapArt.eye_offset(w, h)
	var ey := eo.y
	if state == SoapArt.PANICKED:
		ey -= h * 0.02
	var er   := SoapArt.eye_radius(w, state)
	var segs := SoapArt.eye_segments(state)
	var l_eye := Vector2(-eo.x, ey)
	var r_eye := Vector2( eo.x, ey)

	mouth.width  = SoapArt.mouth_width(w)
	mouth.points = SoapArt.mouth_points(w, h, state)

	if state == SoapArt.VICTORY:
		left_eye.polygon  = SoapArt.star(l_eye, er, er * 0.45, 5)
		right_eye.polygon = SoapArt.star(r_eye, er, er * 0.45, 5)
		left_eye.color    = SoapArt.STAR_EYE_COLOR
		right_eye.color   = SoapArt.STAR_EYE_COLOR
	else:
		left_eye.polygon  = SoapArt.circle(l_eye, er, segs)
		right_eye.polygon = SoapArt.circle(r_eye, er, segs)
		left_eye.color    = SoapArt.OUTLINE_COLOR
		right_eye.color   = SoapArt.OUTLINE_COLOR

	if SoapArt.has_eye_shine(state):
		_left_eye_shine.polygon  = SoapArt.eye_shine(l_eye, er)
		_right_eye_shine.polygon = SoapArt.eye_shine(r_eye, er)
		_left_eye_spark.polygon  = SoapArt.eye_spark(l_eye, er)
		_right_eye_spark.polygon = SoapArt.eye_spark(r_eye, er)
	else:
		_clear_eye_shine()

	_set_cheeks(w, h, state)

func _set_cheeks(w: float, h: float, state: int) -> void:
	var cc := SoapArt.cheek_centre(w, h)
	var cr := SoapArt.cheek_radius(w)
	_left_cheek.polygon  = SoapArt.circle(Vector2(-cc.x, cc.y), cr, 10)
	_right_cheek.polygon = SoapArt.circle(Vector2( cc.x, cc.y), cr, 10)
	_left_cheek.color    = SoapArt.cheek_color(state)
	_right_cheek.color   = _left_cheek.color

func _clear_eye_shine() -> void:
	_left_eye_shine.polygon  = PackedVector2Array()
	_right_eye_shine.polygon = PackedVector2Array()
	_left_eye_spark.polygon  = PackedVector2Array()
	_right_eye_spark.polygon = PackedVector2Array()

func _update_speed_lines() -> void:
	var hw        := get_width() * 0.5
	var hh        := get_height() * 0.5
	var base_t    := clampf(forward_speed / 200.0, 0.5, 1.0)
	var lean_t    := lean_magnitude * absf(float(lean_direction))
	var intensity := base_t * (0.3 + lean_t * 0.7)
	var gap       := hw + 5.0
	var a         := 0.55 * intensity
	var yo0: float = -hh * 0.50; var len0: float = 16.0 * intensity
	var yo1: float =  hh * 0.08; var len1: float = 11.0 * intensity
	var yo2: float =  hh * 0.55; var len2: float =  7.0 * intensity
	_speed_lines[0].points = PackedVector2Array([Vector2(-gap, yo0), Vector2(-gap - len0, yo0)])
	_speed_lines[3].points = PackedVector2Array([Vector2( gap, yo0), Vector2( gap + len0, yo0)])
	_speed_lines[1].points = PackedVector2Array([Vector2(-gap, yo1), Vector2(-gap - len1, yo1)])
	_speed_lines[4].points = PackedVector2Array([Vector2( gap, yo1), Vector2( gap + len1, yo1)])
	_speed_lines[2].points = PackedVector2Array([Vector2(-gap, yo2), Vector2(-gap - len2, yo2)])
	_speed_lines[5].points = PackedVector2Array([Vector2( gap, yo2), Vector2( gap + len2, yo2)])
	for ln: Line2D in _speed_lines:
		ln.default_color = Color(1.0, 1.0, 1.0, a)

# ── Colour constants kept for the shield only ─────────────────────────────
