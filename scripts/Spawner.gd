class_name Spawner
extends Node

const OUTLINE_COLOR   := Color("#1a1a2e")
const WET_COLOR       := Color(0.38, 0.65, 0.98, 0.22)

# Obstacle palette
const DUCK_Y      := Color("#fde047")
const DUCK_Y2     := Color("#fef08a")
const BEAK        := Color("#fb923c")
const GREY_L      := Color("#6b7280")
const GREY_D      := Color("#4b5563")
const GREY_XD     := Color("#1f2937")
const SPONGE_Y    := Color("#fde047")
const SPONGE_G    := Color("#bef264")
const SPONGE_PORE := Color("#ca8a04")
const COMB        := Color("#2dd4bf")
const COMB_D      := Color("#14b8a6")
const HAIR        := Color("#4a4340")
const HAIR_L      := Color("#6b625c")
const BLUSH       := Color(0.95, 0.56, 0.70, 0.5)
const CORRIDOR_HALF: float = 36.0 * 0.7 * 1.35 * 0.5

var _world: Node2D
var _soap: Soap

func setup(world: Node2D, soap: Soap) -> void:
	_world = world
	_soap  = soap

func build_level(lv: Dictionary) -> void:
	_clear_world()
	_spawn_walls(lv)

	if bool(lv.get("procedural", false)):
		_build_procedural(lv)
	else:
		for z: Dictionary in lv.get("wet_zones", []):
			_spawn_wet_zone(0.0, float(z.get("y", 0.0)), float(lv.get("channel_half", 130.0)) * 2.0, float(z.get("height", 100.0)))
		for o: Dictionary in lv.get("obstacles", []):
			_spawn_obstacle(float(o.get("x", 0.0)), float(o.get("y", 0.0)), float(o.get("radius", 22.0)))
		for p: Dictionary in lv.get("pickups", []):
			_spawn_pickup(str(p.get("type", "")), float(p.get("x", 0.0)), float(p.get("y", 0.0)))

	_spawn_finish_line(float(lv.get("channel_half", 130.0)), float(lv.get("level_length", 2000.0)))

# ── Private helpers ────────────────────────────────────────────────────────

func _clear_world() -> void:
	for c in _world.get_children():
		c.queue_free()

func _spawn_walls(lv: Dictionary) -> void:
	var length: float = float(lv.get("level_length", 2000.0)) + 200.0
	var hw: float     = float(lv.get("channel_half", 130.0))
	var accent: Color = GameData.level_accent

	# Lane fill + accent side-stroke + dashed centreline (added first = renders behind everything)
	_spawn_lane_fill(hw, length, accent)
	_spawn_centerline(length, accent)

	# Walls run from the lane edge to beyond the screen edge (half of 390 is 195;
	# 240 leaves margin for screen shake), so a narrower lane simply means more
	# visible bathroom rather than more empty background.
	const WALL_OUTER := 240.0
	var wall_w: float = maxf(44.0, WALL_OUTER - hw)
	var wall_cx: float = hw + wall_w * 0.5
	_make_wall(Vector2(-wall_cx, length * 0.5 - 100.0), Vector2(wall_w, length), accent)
	_make_wall(Vector2( wall_cx, length * 0.5 - 100.0), Vector2(wall_w, length), accent)

func _spawn_lane_fill(hw: float, length: float, accent: Color) -> void:
	var top    := -60.0
	var bottom := length + 60.0
	var lane := ColorRect.new()
	lane.position = Vector2(-hw, top)
	lane.size     = Vector2(hw * 2.0, bottom - top)
	lane.color    = Color(1.0, 1.0, 1.0, 0.92)
	lane.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world.add_child(lane)

	for side in [-1.0, 1.0]:
		var stroke := ColorRect.new()
		stroke.position = Vector2(side * hw - (1.5 if side > 0.0 else 0.0), top)
		stroke.size     = Vector2(1.5, bottom - top)
		stroke.color    = Color(accent.r, accent.g, accent.b, 0.9)
		stroke.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_world.add_child(stroke)

func _spawn_centerline(length: float, accent: Color) -> void:
	var dash_len := 12.0
	var gap_len  := 10.0
	var y      := -40.0
	var bottom := length + 60.0
	var is_dash := true
	while y < bottom - 0.5:
		var step := minf(dash_len if is_dash else gap_len, bottom - y)
		if is_dash:
			var seg := Line2D.new()
			seg.width = 2.0
			seg.default_color = Color(accent.r, accent.g, accent.b, 0.4)
			seg.add_point(Vector2(0.0, y))
			seg.add_point(Vector2(0.0, y + step))
			_world.add_child(seg)
		y += step
		is_dash = not is_dash

func _make_wall(pos: Vector2, sz: Vector2, accent: Color) -> void:
	var wall := StaticBody2D.new()
	wall.collision_layer = 2
	wall.collision_mask  = 0
	wall.add_to_group("wall")
	wall.position = pos

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = sz
	col.shape = shape
	wall.add_child(col)

	# Wall visual: the level's bathroom tiling, plus a thin accent edge facing
	# the lane so the play area still reads as clearly bounded.
	var art := WallVisual.new()
	art.setup(GameData.current_level_index, Rect2(-sz * 0.5, sz))
	wall.add_child(art)

	var edge := ColorRect.new()
	edge.size     = Vector2(3.0, sz.y)
	edge.position = Vector2(-sz.x * 0.5 if pos.x > 0.0 else sz.x * 0.5 - 3.0, -sz.y * 0.5)
	edge.color    = accent
	wall.add_child(edge)

	_world.add_child(wall)

func _spawn_wet_zone(cx: float, y: float, width: float, height: float) -> void:
	var zone := Area2D.new()
	zone.collision_layer = 8
	zone.collision_mask  = 1
	zone.position        = Vector2(cx, y + height * 0.5)

	var col   := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	col.shape  = shape
	zone.add_child(col)

	# Blue tint fill
	var fill := ColorRect.new()
	fill.size     = Vector2(width, height)
	fill.position = Vector2(-width * 0.5, -height * 0.5)
	fill.color    = WET_COLOR
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zone.add_child(fill)

	# "WET ZONE AHEAD" label pill at the entry edge
	var pill := Panel.new()
	var psty := StyleBoxFlat.new()
	psty.bg_color = Color(0.855, 0.918, 0.996, 0.9)
	psty.set_corner_radius_all(10)
	pill.add_theme_stylebox_override("panel", psty)
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.position = Vector2(-70.0, -height * 0.5 + 8.0)
	pill.size     = Vector2(140.0, 22.0)
	zone.add_child(pill)
	var pill_lbl := Label.new()
	pill_lbl.text = "💧 WET ZONE AHEAD"
	pill_lbl.add_theme_font_size_override("font_size", 10)
	pill_lbl.add_theme_color_override("font_color", Color("#1d4ed8"))
	pill_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pill_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	pill_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pill.add_child(pill_lbl)

	# Animated rising bubbles
	var rng2 := RandomNumberGenerator.new()
	rng2.seed = int(y * 7 + width)
	var n_bubbles := int(width / 28.0)
	for _bi in n_bubbles:
		var r     := rng2.randf_range(3.0, 7.0)
		var speed := rng2.randf_range(18.0, 38.0)
		var bx    := rng2.randf_range(-width * 0.46, width * 0.46)
		var by    := rng2.randf_range(-height * 0.5, height * 0.5)
		var bub: WetBubble = WetBubble.new()
		bub.setup(bx, by, r, speed, height)
		zone.add_child(bub)

	zone.body_entered.connect(func(b: Node): if b == _soap: _soap.enter_wet_zone())
	zone.body_exited.connect(func(b: Node):  if b == _soap: _soap.exit_wet_zone())
	_world.add_child(zone)

func _spawn_obstacle(x: float, y: float, radius: float) -> void:
	var obs := StaticBody2D.new()
	obs.collision_layer = 0
	obs.collision_mask  = 0
	obs.position        = Vector2(x, y)

	# Pick type deterministically from position (0=duck 1=grate 2=sponge 3=comb)
	var obs_type := int(abs(x * 3.0 + y * 1.7)) % 4
	var art := ObstacleVisual.new()
	art.setup(obs_type, radius)
	obs.add_child(art)

	# Kill zone (shared for all types)
	var kz     := Area2D.new()
	kz.collision_layer = 0
	kz.collision_mask  = 1
	var kshape := CollisionShape2D.new()
	var circ   := CircleShape2D.new()
	circ.radius = radius + 2.0
	kshape.shape = circ
	kz.add_child(kshape)
	kz.body_entered.connect(func(b: Node): if b == _soap: _soap.handle_obstacle_hit())
	obs.add_child(kz)
	_world.add_child(obs)

func _spawn_pickup(type: String, x: float, y: float) -> void:
	var pick := Area2D.new()
	pick.collision_layer = 16
	pick.collision_mask  = 1
	pick.position        = Vector2(x, y)

	var col  := CollisionShape2D.new()
	var circ := CircleShape2D.new()
	circ.radius = 20.0
	col.shape   = circ
	pick.add_child(col)

	var is_shield := type == "bubble_shield"
	var orb_color := Color("#86efac") if not is_shield else Color("#fde047")
	# Glow ring (outer)
	var glow := Polygon2D.new()
	glow.polygon = _circle_poly(Vector2.ZERO, 22.0, 16)
	glow.color   = Color(orb_color.r, orb_color.g, orb_color.b, 0.28)
	pick.add_child(glow)

	# Orb body
	var orb := Polygon2D.new()
	orb.polygon = _circle_poly(Vector2.ZERO, 17.0, 14)
	orb.color   = Color(orb_color.r, orb_color.g, orb_color.b, 0.88)
	pick.add_child(orb)

	# Emoji label centred
	var lbl := Label.new()
	lbl.text = "🫧" if is_shield else "✨"
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.position = Vector2(-14.0, -14.0)
	lbl.size     = Vector2(28.0, 28.0)
	pick.add_child(lbl)

	pick.body_entered.connect(func(b: Node):
		if b == _soap:
			_soap.collect_pickup(type)
			pick.queue_free()
	)
	_world.add_child(pick)

func _spawn_finish_line(channel_half: float, y: float) -> void:
	var line := Area2D.new()
	line.collision_layer = 32
	line.collision_mask  = 1
	line.position        = Vector2(0.0, y)

	var col   := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(channel_half * 2.0, 24.0)
	col.shape  = shape
	line.add_child(col)

	# Checkered pattern — 18×18px tiles, pink + white
	var tile_size := 18.0
	var total_w   := channel_half * 2.0
	var total_h   := 24.0
	var n_cols := int(ceil(total_w / tile_size))
	var n_rows := int(ceil(total_h / tile_size))
	for tr in n_rows:
		for tc in n_cols:
			var even := (tr + tc) % 2 == 0
			var tile := ColorRect.new()
			tile.size     = Vector2(tile_size, tile_size)
			tile.position = Vector2(-total_w * 0.5 + float(tc) * tile_size,
			-total_h * 0.5 + float(tr) * tile_size)
			tile.color    = Color("#d63384") if even else Color.WHITE
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
			line.add_child(tile)

	# "🏁 FINISH LINE" label pill
	var lbl := Label.new()
	lbl.text = "🏁  FINISH LINE"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color("#1a1a2e"))
	lbl.position  = Vector2(-channel_half, -10.0)
	lbl.size      = Vector2(channel_half * 2.0, 20.0)
	line.add_child(lbl)

	line.add_to_group("finish_line")
	_world.add_child(line)

# ── Procedural generation (levels 6-10) ───────────────────────────────────

func _build_procedural(lv: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(lv.get("proc_seed", 1001))

	var length: float  = float(lv.get("level_length", 2000.0))
	var hw: float      = float(lv.get("channel_half", 100.0))
	var width: float   = hw * 2.0

	var n_zones: int      = int(lv.get("proc_wet_zone_count", 4))
	var zh_min: float     = float(lv.get("proc_wet_zone_height_min", 250.0))
	var zh_max: float     = float(lv.get("proc_wet_zone_height_max", 400.0))
	var zone_spacing: float = (length - 300.0) / float(n_zones + 1)
	var zone_y: float = 200.0
	for _i in n_zones:
		zone_y += zone_spacing * rng.randf_range(0.7, 1.3)
		var zh: float = rng.randf_range(zh_min, zh_max)
		_spawn_wet_zone(0.0, zone_y, width, zh)
		zone_y += zh

	var n_obs: int        = int(lv.get("proc_obstacle_count", 10))
	var r_min: float      = float(lv.get("proc_obstacle_radius_min", 23.0))
	var r_max: float      = float(lv.get("proc_obstacle_radius_max", 28.0))
	var obs_spacing: float = (length - 300.0) / float(n_obs + 1)
	var obs_y: float = 250.0
	for _i in n_obs:
		obs_y += obs_spacing * rng.randf_range(0.6, 1.4)
		var radius: float = rng.randf_range(r_min, r_max)
		var side: float   = 1.0 if rng.randf() > 0.5 else -1.0
		var min_x: float  = CORRIDOR_HALF + radius + 4.0
		var max_x: float  = hw - radius - 4.0
		var x: float
		if max_x < min_x:
			x = side * ((min_x + max_x) * 0.5)
		else:
			x = side * rng.randf_range(min_x, max_x)
		_spawn_obstacle(x, obs_y, radius)

	var n_pick: int = int(lv.get("proc_pickup_count", 2))
	var types: Array[String] = ["soap_sliver", "bubble_shield"]
	for i in n_pick:
		var py: float = (length * 0.2) + (length * 0.6) * float(i + 1) / float(n_pick + 1)
		var px: float = rng.randf_range(-hw * 0.5, hw * 0.5)
		_spawn_pickup(types[i % 2], px, py)

# ── Polygon helpers ────────────────────────────────────────────────────────

func _rounded_rect(centre: Vector2, hw: float, hh: float, r: float) -> PackedVector2Array:
	r = minf(r, minf(hw, hh) * 0.99)
	var pts := PackedVector2Array()
	var ccx := PackedFloat32Array([-hw+r, hw-r, hw-r, -hw+r])
	var ccy := PackedFloat32Array([-hh+r, -hh+r, hh-r, hh-r])
	var ca0 := PackedFloat32Array([PI, -PI*0.5, 0.0, PI*0.5])
	for i in 4:
		for j in 3:
			var a: float = ca0[i] + PI * 0.5 * float(j) / 2.0
			pts.append(Vector2(centre.x + ccx[i] + cos(a) * r, centre.y + ccy[i] + sin(a) * r))
	return pts

func _circle_poly(centre: Vector2, radius: float, steps: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in steps:
		var a: float = TAU * float(i) / float(steps)
		pts.append(centre + Vector2(cos(a), sin(a)) * radius)
	return pts
