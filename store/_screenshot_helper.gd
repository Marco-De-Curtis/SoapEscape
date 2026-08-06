extends Node

# Dev-only tool for capturing App Store screenshots at full framebuffer size.
#
# Register temporarily as an autoload, play to the frame you want, press F12:
#
#   [autoload]
#   ScreenshotHelper="*res://store/_screenshot_helper.gd"
#
# Remove that line before an iOS release build. The leading underscore in the
# filename means the export preset's "_*.gd" exclude filter strips this file
# from the package, so a shipped build with the autoload still registered would
# fail to start.
#
# Run the game at the target size so the capture comes out correctly sized:
#   SoapEscape.exe --resolution 1320x2868
#
# An OS screenshot tool cannot do this job: when the window is taller than the
# monitor it only captures the visible portion. Reading the viewport texture
# gets the whole framebuffer regardless of what fits on screen.

const OUTPUT_DIR := "user://screenshots"

var _counter: int = 0

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)

func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key := event as InputEventKey
	if key.pressed and not key.echo and key.keycode == KEY_F12:
		_capture()

func _capture() -> void:
	# Wait one frame so the capture includes everything drawn this frame.
	await RenderingServer.frame_post_draw

	var img := get_viewport().get_texture().get_image()
	var stamp := Time.get_datetime_string_from_system().replace(":", "-")
	_counter += 1
	var path := "%s/shot_%02d_%s.png" % [OUTPUT_DIR, _counter, stamp]

	var err := img.save_png(path)
	if err == OK:
		print("Screenshot saved: %s (%d x %d)" % [
			ProjectSettings.globalize_path(path), img.get_width(), img.get_height()])
	else:
		push_error("Screenshot failed (error %d): %s" % [err, path])
