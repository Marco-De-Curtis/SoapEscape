extends Node

var current_level_index: int = 0   # 0-based index into LevelData.LEVELS
var fail_reason: String = ""        # "dissolved" | "obstacle" | "too_small"
var last_stars: int = 0             # stars from most recent win
var level_accent:    Color = Color("#f9a8d4")  # current level accent color
var last_soap_pct:   float = 1.0             # soap size at finish (0-1)
var min_soap_pct:    float = 0.50            # threshold for "too_small" (set per level)
var prev_stars:      int   = 0               # best stars before this run (for "New record!" badge)

func do_haptic(style: int) -> void:
	# style: 0=light, 1=medium, 2=heavy
	if Engine.has_singleton("Haptic"):
		Engine.get_singleton("Haptic").impact(style)
	else:
		Input.vibrate_handheld(20 + style * 20)
