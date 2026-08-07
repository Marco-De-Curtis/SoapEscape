extends RefCounted

# Deliberately NOT a `class_name` global. Global classes resolve through
# .godot/global_script_class_cache.cfg, which is gitignored except for the one
# tracked copy, so a fresh CI checkout can carry a stale cache that predates
# this file and the identifier fails to resolve at export time. Consumers
# preload this script into a const instead, which always resolves by path.

# Real device safe-area insets, in the viewport units every screen lays out in.
#
# The screens used to draw their own black "Dynamic Island" pill and hardcode
# a 56-unit top margin under it. That came from the HTML design mockups, where
# the island was part of a *drawing of a phone*. On an actual phone it is
# wrong twice over: on a Dynamic Island device it double-draws the hardware
# that is already there, and on every device without one (SE, 8, 11, and the
# rest of the iOS 14+ range) it is a black blob floating on screen for no
# reason.
#
# DisplayServer.get_display_safe_area() is backed by UIView.safeAreaInsets on
# iOS, so it reports the true inset for whatever hardware the app is running
# on, including 0 where there is nothing to avoid.

## Minimum breathing room when the device reports no inset at all, so content
## never sits flush against the top edge.
const MIN_TOP: float = 12.0


## Top inset in viewport units. 0 on hardware with nothing to avoid.
static func top_raw(node: Node) -> float:
	var vp := node.get_viewport()
	if vp == null:
		return 0.0
	var win := DisplayServer.window_get_size()
	if win.y <= 0:
		return 0.0
	# get_display_safe_area() returns physical screen pixels, offset by the
	# screen's own origin, so the origin has to come back off before the
	# value means "inset".
	var safe := DisplayServer.get_display_safe_area()
	var inset_px := float(safe.position.y - DisplayServer.screen_get_position().y)
	if inset_px <= 0.0:
		return 0.0
	var units_per_px: float = vp.get_visible_rect().size.y / float(win.y)
	return inset_px * units_per_px


## Where top-anchored content should start. Never less than MIN_TOP.
static func content_top(node: Node) -> float:
	return maxf(top_raw(node), MIN_TOP)
