class_name ObstacleVisual
extends Node2D

# Draws one obstacle via ObstacleArt. Replaces the pile of Polygon2D/Line2D
# children the Spawner used to build by hand, so the art lives in one place.

@export var kind: int = ObstacleArt.DUCK
@export var radius: float = 24.0

func setup(k: int, r: float) -> void:
	kind = k
	radius = r
	queue_redraw()

func _draw() -> void:
	ObstacleArt.paint(self, kind, Vector2.ZERO, radius)
