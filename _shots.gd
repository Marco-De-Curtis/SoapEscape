extends Node

# App Store screenshot director. Drives the real game into specific states and
# captures the full framebuffer, so every shot is the actual running app rather
# than a mock-up.
#
#   godot --path . --resolution 1320x2868 _shots.tscn
#
# Underscore-prefixed so the export preset's "_*.gd" / "_*.tscn" filters keep
# both this and its scene out of shipped builds.

const OUT := "user://shots"

# Camera2D on the soap uses offset.y = 126, and at 1320x2868 the canvas_items
# stretch shows ~847 world units vertically, so the visible band runs from
# roughly soap.y - 297 to soap.y + 550.
#
# The hazards are physically bigger than the soap (radius 24-38 against a
# 36x20 body), which is true to the game but means a widely spaced frame
# reads as "some shapes in a corridor". Holding the hazard ~210 below puts it
# just under the soap, close enough that the near-miss is the subject.
const LOOKAHEAD := 210.0

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	await get_tree().process_frame

	SaveData.mark_onboarding_shown()
	for lid in range(1, 4):
		SaveData.mark_tutorial_shown(lid)

	await _shot_gameplay("01_steer", 3, 0.98, false, false)
	await _shot_gameplay("02_nearmiss", 6, 0.40, false, true)
	await _shot_win("03_win")
	await _shot_map("04_map")
	await _shot_home("05_home")
	await _shot_fail("06_fail")

	print("ALL SHOTS DONE -> ", ProjectSettings.globalize_path(OUT))
	get_tree().quit()

# ── Gameplay shots ─────────────────────────────────────────────────────────

func _shot_gameplay(name: String, level_no: int, size: float, shield: bool = false, in_wet: bool = true) -> void:
	GameData.current_level_index = level_no - 1
	var game := preload("res://scenes/Game.tscn").instantiate()
	add_child(game)

	# Game.start_level() runs in _ready and the spawner builds on the same
	# frame; the finish-line hookup awaits one frame, so give it two.
	await get_tree().process_frame
	await get_tree().process_frame

	var soap: Soap = game.get_node("Soap")
	var world: Node2D = game.get_node("World")

	var target_y := _find_photogenic_y(world, in_wet)
	var pos := Vector2(_lane_x_for(world, target_y), target_y)

	# The shield bubble roughly doubles the soap's visual footprint, which both
	# shows a real mechanic and makes the character findable: at 33% size the
	# bare soap is ~12 world units wide and all but disappears in the frame.
	if shield:
		soap.has_shield = true
		soap.get_node("ShieldBubble").show()
		soap.get_node("ShieldBubble").modulate.a = 1.0

	# Freeze forward motion. Left running, the soap covers ~200px/s and simply
	# drives into the hazard we framed it against, arriving at the capture with
	# a chunk bitten out of it and a meter that contradicts the size we set.
	soap.forward_speed = 0.0

	# Hold position outright: with lean applied, lateral velocity would still
	# walk the soap into the wall over the settle frames.
	for i in 70:
		soap.position = pos
		soap.velocity = Vector2.ZERO
		# Lean for the last stretch only, so the body squash and the speed
		# lines are mid-motion at capture. A level soap looks like a menu
		# asset; a leaning one looks like it is being played.
		if i > 52:
			soap.lean_direction = -1
			soap.lean_magnitude = 0.90
		await get_tree().physics_frame

	# Set size last. The wet zone nibbles at it every frame it sits there, and
	# the HUD meter tweens, so apply then let the bar catch up.
	soap.size = size
	soap.size_changed.emit(size)
	for i in 24:
		soap.position = pos
		soap.lean_direction = -1
		soap.lean_magnitude = 0.90
		await get_tree().physics_frame

	await _capture(name)
	game.queue_free()
	await get_tree().process_frame

## Score every position along the level and take the best frame, rather than
## the first one that roughly fits. Taking the first match put the soap
## directly on top of a duck, which reads as a crash rather than a dodge, and
## left a drain grate colliding with the Dynamic Island.
func _find_photogenic_y(world: Node2D, in_wet: bool) -> float:
	var obstacles: Array[float] = []
	var zones: Array[Vector2] = []   # (top, bottom)
	for c in world.get_children():
		if c is StaticBody2D and not c.is_in_group("wall"):
			obstacles.append(c.position.y)
		elif c is Area2D and c.collision_layer == 8:
			var shape := (c.get_child(0) as CollisionShape2D).shape as RectangleShape2D
			zones.append(Vector2(c.position.y - shape.size.y * 0.5,
								 c.position.y + shape.size.y * 0.5))
	obstacles.sort()
	if obstacles.is_empty():
		return 900.0

	var best_y := obstacles[obstacles.size() / 2] - LOOKAHEAD
	var best_score := -1e9

	var cy := 700.0                      # before this the lane is still empty
	while cy < obstacles[obstacles.size() - 1]:
		cy += 15.0
		var score := 0.0

		# Wet zones matter for the story, but Soap.gd lerps the body fill toward
		# light blue while the soap is inside one, which drops it to roughly
		# 1.2:1 against the blue tint and makes it vanish at thumbnail size.
		# For the hero shot, sit the soap on the dry white lane with the zone
		# just ahead: same story, lavender soap, far more contrast.
		var in_zone := false
		var zone_ahead := false
		for z in zones:
			if cy > z.x + 60.0 and cy < z.y - 60.0:
				in_zone = true
			if z.x - cy > 120.0 and z.x - cy < 430.0:
				zone_ahead = true
		if in_wet:
			if not in_zone:
				continue
		else:
			if in_zone or not zone_ahead:
				continue

		# Penalties, not rejections. The late levels pack 32 to 44 obstacles
		# into 4300 units, an average gap of ~134, so any hard "nothing within
		# 150" rule is unsatisfiable there and every candidate gets thrown out,
		# leaving an unvetted fallback that lands the soap on top of a sponge.
		var nearest_below := 1e9
		for oy in obstacles:
			var d := oy - cy
			if absf(d) < 155.0:
				# Overlaps the soap: reads as a collision, not a dodge.
				score -= 400.0 - absf(d) * 2.0
			if d < -190.0 and d > -300.0:
				score -= 90.0            # collides with the Dynamic Island
			if d > 0.0 and d < nearest_below:
				nearest_below = d

		# Hazard just under the soap is the whole point of the frame.
		if nearest_below > 165.0 and nearest_below < 280.0:
			score += 120.0 - absf(nearest_below - 215.0)

		# A second hazard further down adds depth without crowding.
		for oy in obstacles:
			var d2 := oy - cy
			if d2 > 330.0 and d2 < 545.0:
				score += 25.0

		if score > best_score:
			best_score = score
			best_y = cy

	return best_y

## Put the soap on the opposite side of the hazard it is about to meet, well
## off the centreline, so the frame reads as a dodge in progress rather than a
## bar of soap parked in a corridor.
func _lane_x_for(world: Node2D, y: float) -> float:
	for c in world.get_children():
		if c is StaticBody2D and not c.is_in_group("wall"):
			if absf(c.position.y - (y + LOOKAHEAD)) < 70.0:
				var side := -signf(c.position.x)
				if side == 0.0:
					side = -1.0
				return side * 52.0
	return -40.0

# ── UI shots ───────────────────────────────────────────────────────────────

func _shot_win(name: String) -> void:
	GameData.current_level_index = 4
	GameData.last_stars   = 3
	GameData.prev_stars   = 2
	GameData.last_soap_pct = 0.82
	GameData.level_accent  = LevelData.get_theme(4).accent
	await _show_scene("res://scenes/WinScreen.tscn", name, 70)

func _shot_fail(name: String) -> void:
	GameData.current_level_index = 6
	GameData.fail_reason  = "dissolved"
	GameData.min_soap_pct = 0.35
	GameData.last_soap_pct = 0.0
	GameData.level_accent  = LevelData.get_theme(6).accent
	await _show_scene("res://scenes/FailScreen.tscn", name, 70)

func _shot_map(name: String) -> void:
	# A map with real progress sells the game far better than an empty one.
	for entry in [[1, 3], [2, 3], [3, 3], [4, 2], [5, 3], [6, 3], [7, 2], [8, 3], [9, 1]]:
		SaveData.save_level_result(entry[0], entry[1])
	GameData.current_level_index = 9
	await _show_scene("res://scenes/MapScreen.tscn", name, 60)

func _shot_home(name: String) -> void:
	for entry in [[1, 3], [2, 3], [3, 3], [4, 2], [5, 3], [6, 3], [7, 2], [8, 3], [9, 1]]:
		SaveData.save_level_result(entry[0], entry[1])
	# The logo bobs on a sine; hold past the first frames so it is mid-drift
	# rather than snapped to its starting position.
	await _show_scene("res://scenes/HomeScreen.tscn", name, 100)

func _show_scene(path: String, name: String, frames: int) -> void:
	var scn: Node = load(path).instantiate()
	add_child(scn)
	if scn is Control:
		(scn as Control).set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for i in frames:
		await get_tree().process_frame
	await _capture(name)
	scn.queue_free()
	await get_tree().process_frame

# ── Capture ────────────────────────────────────────────────────────────────

func _capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [OUT, name]
	var err := img.save_png(path)
	print("SHOT %s -> %dx%d err=%d" % [name, img.get_width(), img.get_height(), err])
