class_name WallVisual
extends Control

# The channel walls are the one place a themed bathroom is genuinely visible
# during play: they are wide, always on screen, and never overlap the lane.
#
# This is a Control (not a Node2D) purely for `clip_contents`: several patterns
# draw shapes larger than their tile — the deco sunburst spans the whole
# diagonal — and without clipping they escape the wall and cover the screen.

var level_index: int = 0

func setup(idx: int, r: Rect2) -> void:
	level_index   = idx
	position      = r.position
	size          = r.size
	clip_contents = true
	mouse_filter  = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	BathroomArt.paint(self, level_index, r, 1.0)
	# a touch darker than the lane, so the play area stays the brighter surface
	draw_rect(r, Color(0, 0, 0, 0.10))
