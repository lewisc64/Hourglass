@icon("uid://dqt6y88n6mco2")
class_name Stopwatch
extends Node

@export var autostart = false
@export var stop_while_paused = false

var _mutex = Mutex.new()
var _counting = false
var _resume_after_pause = false
var _start_stamp = 0
var _accumulation = 0


func start():
	_mutex.lock()
	if not _counting:
		_start_stamp = Time.get_ticks_usec()
		_counting = true
	_mutex.unlock()


func stop():
	_mutex.lock()
	if _counting:
		_accumulation += Time.get_ticks_usec() - _start_stamp
		_counting = false
	_mutex.unlock()


func reset():
	_mutex.lock()
	_counting = false
	_accumulation = 0
	_mutex.unlock()


func restart():
	_mutex.lock()
	_accumulation = 0
	_start_stamp = Time.get_ticks_usec()
	_counting = true
	_mutex.unlock()


func is_running():
	return _counting


func get_elapsed_microseconds() -> int:
	_mutex.lock()
	var result = _accumulation
	if _counting:
		result += Time.get_ticks_usec() - _start_stamp
	_mutex.unlock()
	return result


func get_elapsed_milliseconds() -> int:
	@warning_ignore("integer_division")
	return get_elapsed_microseconds() / 1000


func get_elapsed_seconds() -> float:
	return get_elapsed_microseconds() / 1000000.0


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if autostart:
		start()


func _process(_delta):
	if stop_while_paused:
		if get_tree().paused and _counting:
			stop()
			_resume_after_pause = true
		elif not get_tree().paused and _resume_after_pause:
			start()
			_resume_after_pause = false
