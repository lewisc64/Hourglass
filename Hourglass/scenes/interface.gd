extends Control

@onready var text_edit_hours: TextEdit = %TextEditHours
@onready var text_edit_minutes: TextEdit = %TextEditMinutes
@onready var text_edit_seconds: TextEdit = %TextEditSeconds
@onready var label_remaining_time: Label = %LabelRemainingTime
@onready var hourglass: Hourglass = %Hourglass
@onready var button_flip: Button = %ButtonFlip
@onready var button_reset: Button = %ButtonReset
@onready var button_acknowledge: Button = %ButtonAcknowledge
@onready var hue_filter: ColorRect = %HueFilter
@onready var chimes: Node = %Chimes

var _reset_flag = false
var _shake_time = 0.0


func _ready():
	button_reset.disabled = true
	button_acknowledge.visible = false
	hue_filter.visible = false


func get_seconds() -> float:
	var seconds = 0.0
	seconds += float(text_edit_hours.text) * 3600
	seconds += float(text_edit_minutes.text) * 60
	seconds += float(text_edit_seconds.text)
	return seconds


func start():
	await reset()
	_reset_flag = false
	
	button_flip.disabled = true
	button_reset.disabled = false
	
	hourglass.set_time(get_seconds())
	await hourglass.flip()
	
	if not _reset_flag:
		alarm()

	button_flip.disabled = false
	button_reset.disabled = true


func reset():
	acknowledge()
	_reset_flag = true
	await hourglass.reset()
	button_flip.disabled = false
	button_reset.disabled = true


func alarm():
	chimes.play()
	button_acknowledge.visible = true
	hue_filter.visible = true


func acknowledge():
	chimes.stop()
	button_acknowledge.visible = false
	hue_filter.visible = false


func _on_button_flip_pressed() -> void:
	start()


func _on_button_reset_pressed() -> void:
	reset()


func _on_button_acknowledge_pressed() -> void:
	acknowledge()


func _process(delta):
	if chimes.is_playing():
		label_remaining_time.text = "Time's up!"
		hourglass.position.x = sin(_shake_time * 10) * 5
		hourglass.rotation = cos(_shake_time * 10) / 20
		_shake_time += delta
		return
	_shake_time = 0
	hourglass.position = Vector2.ZERO
	hourglass.rotation = 0
	
	var seconds = hourglass.get_remaining_seconds()
	var hours = int(seconds / 3600.0)
	seconds -= hours * 3600
	var minutes = int(seconds / 60)
	seconds -= minutes * 60
	
	var text: String
	if int(seconds) == 1:
		text = "1 second"
	else:
		text = "%d seconds" % seconds
	
	if minutes != 0:
		if minutes == 1:
			text = "1 minute, %s" % text
		else:
			text = "%d minutes, %s" % [minutes, text]
	if hours != 0:
		if hours == 1:
			text = "1 hour, %s" % text
		else:
			text = "%d hours, %s" % [hours, text]
	label_remaining_time.text = text
