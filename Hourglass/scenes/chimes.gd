extends Node

var _players: Array[AudioStreamPlayer] = []
var _rng := RandomNumberGenerator.new()
var _current_player: AudioStreamPlayer = null


func _ready():
	for child in get_children():
		if child is AudioStreamPlayer:
			_players.append(child)


func is_playing():
	return _current_player != null and _current_player.playing


func play():
	if _current_player != null:
		return
	_current_player = _players[_rng.randi_range(0, len(_players) - 1)]
	_current_player.play()


func stop():
	if _current_player != null:
		_current_player.stop()
		_current_player = null
