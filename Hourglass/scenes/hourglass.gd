class_name Hourglass
extends Node2D

signal _processed_reset
signal _animation_ended
signal _timeout

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stopwatch: Stopwatch = $Stopwatch

var _resetting = false
var _trickling = false
var _timeout_seconds = 0.0


func is_trickling():
	return _trickling


func set_time(seconds: float):
	_timeout_seconds = seconds


func flip():
	await reset()
	_trickling = false
	animation_player.speed_scale = 2
	animation_player.play("flip")
	await _animation_ended

	if _resetting:
		return

	animation_player.speed_scale = 1 / _timeout_seconds
	animation_player.play("trickle")
	_trickling = true

	stopwatch.restart()
	await _timeout
	stopwatch.reset()
	animation_player.play("RESET")
	_trickling = false


func get_remaining_seconds() -> float:
	if not _trickling:
		return 0
	return _timeout_seconds - stopwatch.get_elapsed_seconds()


func reset():
	_resetting = true
	_timeout.emit()

	# wait a frame for other awaited functions to drop out
	_processed_reset.emit.call_deferred()
	await _processed_reset
	_resetting = false


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	_animation_ended.emit()


func _on_animation_player_current_animation_changed(_name: String) -> void:
	_animation_ended.emit()


func _on_anim_resync_timer_timeout() -> void:
	if _trickling and animation_player.current_animation == "trickle":
		animation_player.seek(0, false)
		animation_player.seek(stopwatch.get_elapsed_seconds() / _timeout_seconds, true)


func _process(_delta: float) -> void:
	if _trickling:
		var current_duration = stopwatch.get_elapsed_seconds()
		if current_duration >= _timeout_seconds:
			_timeout.emit()
