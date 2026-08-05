extends Node

const POOL_SIZE := 8

var _players: Array[AudioStreamPlayer] = []
var _loops: Dictionary = {}  # key → AudioStreamPlayer (looping sfx)

func _ready() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)

func play(key: String) -> void:
	var path := "res://assets/audio/sfx/%s.wav" % key
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/sfx/%s.ogg" % key
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	for p in _players:
		if not p.playing:
			p.stream = stream
			p.play()
			return
	# All busy — steal oldest (first player)
	_players[0].stop()
	_players[0].stream = stream
	_players[0].play()

func play_loop(key: String) -> void:
	# Audio file must have loop enabled in its Godot import settings.
	if _loops.has(key):
		return
	var path := "res://assets/audio/sfx/%s.wav" % key
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/sfx/%s.ogg" % key
	if not ResourceLoader.exists(path):
		return
	var p := AudioStreamPlayer.new()
	add_child(p)
	p.stream = load(path)
	p.play()
	_loops[key] = p

func stop_loop(key: String) -> void:
	if _loops.has(key):
		_loops[key].stop()
		_loops[key].queue_free()
		_loops.erase(key)

func stop_all() -> void:
	for p in _players:
		p.stop()
	for k in _loops:
		_loops[k].stop()
		_loops[k].queue_free()
	_loops.clear()
