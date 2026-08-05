extends Node

const SAVE_PATH := "user://save.cfg"

var _cfg: ConfigFile = ConfigFile.new()

func _ready() -> void:
	_cfg.load(SAVE_PATH)

func save_level_result(level_id: int, stars: int) -> void:
	var s := "level_%d" % level_id
	var prev: int = _cfg.get_value(s, "stars", 0)
	_cfg.set_value(s, "stars", max(stars, prev))
	_cfg.set_value(s, "complete", true)
	_cfg.save(SAVE_PATH)

func is_level_complete(level_id: int) -> bool:
	return bool(_cfg.get_value("level_%d" % level_id, "complete", false))

func get_stars(level_id: int) -> int:
	return int(_cfg.get_value("level_%d" % level_id, "stars", 0))

func is_tutorial_shown(level_id: int) -> bool:
	return bool(_cfg.get_value("tutorial", "shown_%d" % level_id, false))

func mark_tutorial_shown(level_id: int) -> void:
	_cfg.set_value("tutorial", "shown_%d" % level_id, true)
	_cfg.save(SAVE_PATH)

func is_ads_removed() -> bool:
	return bool(_cfg.get_value("purchases", "remove_ads", false))

func set_ads_removed() -> void:
	_cfg.set_value("purchases", "remove_ads", true)
	_cfg.save(SAVE_PATH)

func is_onboarding_shown() -> bool:
	return bool(_cfg.get_value("meta", "onboarding_shown", false))

func mark_onboarding_shown() -> void:
	_cfg.set_value("meta", "onboarding_shown", true)
	_cfg.save(SAVE_PATH)

func reset_all() -> void:
	_cfg = ConfigFile.new()
	_cfg.save(SAVE_PATH)
