class_name Fonts
extends RefCounted

# SINGLE SOURCE OF TRUTH for typography.
#
# Godot's FontVariation.variation_opentype needs the OpenType axis as an
# INTEGER tag. Passing {"wght": 700} — the obvious-looking string form — is
# silently ignored, so every label in the project rendered at the font's
# default weight (Fredoka 300 Light, Nunito 200 ExtraLight). Always go through
# these helpers rather than building a FontVariation by hand.

const FREDOKA: FontFile = preload("res://fonts/Fredoka-VariableFont.ttf.ttf")
const NUNITO:  FontFile = preload("res://fonts/Nunito-VariableFont_wght.ttf")

# Fredoka: wght 300..700, wdth 75..125.  Nunito: wght 200..1000.
# Heavy + slightly wide echoes the mascot's own wide, rounded silhouette.
const DISPLAY_WEIGHT := 700
const DISPLAY_WIDTH  := 115

static var _tag_wght: int = 0
static var _tag_wdth: int = 0
static var _cache: Dictionary = {}

static func _init_tags() -> void:
	if _tag_wght == 0:
		var ts := TextServerManager.get_primary_interface()
		_tag_wght = ts.name_to_tag("weight")
		_tag_wdth = ts.name_to_tag("width")

## Body / UI text.
static func nunito(weight: int) -> FontVariation:
	return _make(NUNITO, weight, 0)

## Display / headings / wordmark.
static func fredoka(weight: int = DISPLAY_WEIGHT, width: int = DISPLAY_WIDTH) -> FontVariation:
	return _make(FREDOKA, weight, width)

static func _make(base: FontFile, weight: int, width: int) -> FontVariation:
	_init_tags()
	var key := "%s|%d|%d" % [base.resource_path, weight, width]
	if _cache.has(key):
		return _cache[key]
	var fv := FontVariation.new()
	fv.base_font = base
	var axes := {_tag_wght: float(weight)}
	if width > 0:
		axes[_tag_wdth] = float(width)
	fv.variation_opentype = axes
	_cache[key] = fv
	return fv
