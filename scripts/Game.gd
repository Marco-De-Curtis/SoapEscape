class_name Game
extends Node2D

const SHAKE_FRAMES := 12
const FLASH_DURATION := 0.35

var _lv: Dictionary
var _soap: Soap
var _spawner: Spawner
var _hud  # HUD CanvasLayer — untyped so GDScript resolves script methods
var _death_handled := false
var _finish_handled := false
var _shake_timer := 0
var _shake_strength := 0.0
var _flash_node:   ColorRect
var _wet_vignette: ColorRect

func _ready() -> void:
	_soap    = $Soap
	_spawner = $Spawner
	_hud     = $HUD

	var cvl := CanvasLayer.new()
	cvl.layer = 10

	_wet_vignette = ColorRect.new()
	_wet_vignette.color        = Color(0.35, 0.72, 1.0, 0.0)
	_wet_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wet_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cvl.add_child(_wet_vignette)  # added first = renders behind flash

	_flash_node = ColorRect.new()
	_flash_node.color        = Color(1, 0, 0, 0)
	_flash_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cvl.add_child(_flash_node)    # added second = renders on top

	add_child(cvl)

	_soap.died.connect(_on_soap_died)
	_soap.size_changed.connect(_on_size_changed)
	_soap.wet_zone_changed.connect(_on_wet_zone_changed)
	start_level(GameData.current_level_index)

func start_level(level_index: int) -> void:
	_lv = LevelData.LEVELS[level_index]
	GameData.current_level_index = level_index
	_death_handled   = false
	_finish_handled  = false

	var theme := LevelData.get_theme(level_index)
	RenderingServer.set_default_clear_color(BathroomArt.theme(level_index).wall)
	GameData.level_accent = theme.accent
	if _hud.has_method("set_accent"):
		_hud.set_accent(theme.accent)

	_soap.size            = 1.0
	_soap.lean_magnitude  = 0.0
	_soap.lean_direction  = 0
	_soap.has_shield      = false
	_soap.is_dead         = false
	_soap.forward_speed   = float(_lv.get("forward_speed", 165.0))
	_soap.lane_half       = float(_lv.get("channel_half", 130.0))
	_soap.obstacle_damage = float(_lv.get("obstacle_damage", 0.25))
	_soap.position        = Vector2(0.0, 60.0)
	_soap.velocity        = Vector2.ZERO
	_soap._drag_dx        = 0.0
	_soap._dragging       = false
	_soap._in_wet_zone_count = 0

	_spawner.setup($World, _soap)
	_spawner.build_level(_lv)

	_connect_finish_line()
	_update_camera_limits()

	if _hud.has_method("set_level_name"):
		_hud.set_level_name(str(_lv.get("name", "")))

	_maybe_show_tutorial()

func _connect_finish_line() -> void:
	await get_tree().process_frame
	for fl in get_tree().get_nodes_in_group("finish_line"):
		if not fl.body_entered.is_connected(_on_finish_reached):
			fl.body_entered.connect(_on_finish_reached)

func _update_camera_limits() -> void:
	var cam: Camera2D = _soap.get_node("GameCamera")
	var ch: float = float(_lv.get("channel_half", 130.0))
	var ll: float = float(_lv.get("level_length", 2000.0))
	cam.limit_left   = -int(ch + 50)
	cam.limit_right  =  int(ch + 50)
	cam.limit_top    = -200
	cam.limit_bottom =  int(ll + 300)

# ── Win / fail ─────────────────────────────────────────────────────────────

func _on_finish_reached(body: Node) -> void:
	if body != _soap or _finish_handled: return
	_finish_handled = true
	var ms: float = float(_lv.get("min_soap", 0.5))
	if _soap.size >= ms:
		_win()
	else:
		GameData.min_soap_pct = ms
		_fail("too_small")

func _on_soap_died(reason: String) -> void:
	if _death_handled: return
	_death_handled = true
	_start_screen_shake(10.0)
	_flash(Color(1, 0.2, 0.2, 0.35))
	# Clear wet vignette on death so it doesn't persist into FailScreen
	create_tween().tween_property(_wet_vignette, "color:a", 0.0, 0.2)
	# Melting away in water gets its own cue on top of the generic fail sting
	if reason == "dissolved":
		AudioManager.play("dissolved")
	AudioManager.play("level_fail")
	await get_tree().create_timer(0.7).timeout
	_fail(reason)

func _win() -> void:
	_soap.victory = true
	var stars := 1
	if   _soap.size >= 0.70: stars = 3
	elif _soap.size >= 0.45: stars = 2
	var lid: int = int(_lv.get("id", 1))
	GameData.prev_stars = SaveData.get_stars(lid)
	SaveData.save_level_result(lid, stars)
	GameData.last_stars    = stars
	GameData.last_soap_pct = _soap.size
	AudioManager.stop_all()
	AudioManager.play("level_win")
	if lid == 3 or lid == 7:
		if Engine.has_singleton("InAppReview"):
			Engine.get_singleton("InAppReview").request_review()
	get_tree().change_scene_to_file.call_deferred("res://scenes/WinScreen.tscn")

func _fail(reason: String) -> void:
	GameData.fail_reason = reason
	AudioManager.stop_all()
	get_tree().change_scene_to_file.call_deferred("res://scenes/FailScreen.tscn")

# ── Size changed (HUD update) ──────────────────────────────────────────────

func _on_size_changed(new_size: float) -> void:
	if _hud.has_method("update_size"):
		_hud.update_size(new_size)

func _on_wet_zone_changed(in_zone: bool) -> void:
	var tw := create_tween()
	tw.tween_property(_wet_vignette, "color:a", 0.18 if in_zone else 0.0, 0.3)

# ── Juice ──────────────────────────────────────────────────────────────────

func _process(_delta: float) -> void:
	_tick_shake()
	var ll := float(_lv.get("level_length", 2000.0))
	var pct := clampf((_soap.position.y - 60.0) / (ll - 60.0), 0.0, 1.0)
	if _hud.has_method("update_progress"):
		_hud.update_progress(pct)

func _start_screen_shake(strength: float) -> void:
	_shake_timer    = SHAKE_FRAMES
	_shake_strength = strength

func _tick_shake() -> void:
	if _shake_timer <= 0: return
	_shake_timer -= 1
	var cam: Camera2D = _soap.get_node("GameCamera")
	var t: float = float(_shake_timer) / float(SHAKE_FRAMES)
	cam.offset.x = randf_range(-_shake_strength, _shake_strength) * t
	cam.offset.y = 126.0 + randf_range(-_shake_strength, _shake_strength) * t
	if _shake_timer == 0:
		cam.offset = Vector2(0.0, 126.0)

func _flash(color: Color) -> void:
	_flash_node.color = color
	var tw := create_tween()
	tw.tween_property(_flash_node, "color:a", 0.0, FLASH_DURATION)

# ── Tutorial ───────────────────────────────────────────────────────────────

func _maybe_show_tutorial() -> void:
	var lid: int = int(_lv.get("id", 1))
	if lid > 3: return
	if SaveData.is_tutorial_shown(lid): return
	SaveData.mark_tutorial_shown(lid)
	await get_tree().process_frame
	var tut := preload("res://scenes/Tutorial.tscn").instantiate()
	add_child(tut)
	tut.setup(lid)
