class_name Hourglass
extends Node2D

signal _processed_reset
signal _animation_ended

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _resetting = false
var _trickling = false
var _trickling_seconds = 0.0


func is_trickling():
	return _trickling


func set_time(seconds: float):
	_trickling_seconds = seconds


func flip():
	await reset()
	_trickling = false
	animation_player.speed_scale = 2
	animation_player.play("flip")
	await _animation_ended
	
	if _resetting:
		return

	animation_player.speed_scale = 1 / _trickling_seconds
	animation_player.play("trickle")
	_trickling = true
	await _animation_ended
	_trickling = false


func get_remaining_seconds() -> float:
	if not _trickling:
		return 0
	return (animation_player.current_animation_length - animation_player.current_animation_position) * _trickling_seconds


func reset():
	_resetting = true
	animation_player.play("RESET")
	_trickling = false
	
	# wait a frame for other awaited functions to drop out
	_processed_reset.emit.call_deferred()
	await _processed_reset
	_resetting = false


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	_animation_ended.emit()


func _on_animation_player_current_animation_changed(_name: String) -> void:
	_animation_ended.emit()
