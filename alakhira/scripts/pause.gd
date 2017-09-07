extends Control

var paused = false
onready var t = get_node("timer")
onready var root = get_node("/root/")
onready var az = root.get_node("scene/az")
onready var ui = root.get_node("scene/az/ui/healthb")
onready var pmenu = get_node("pause_menu")

func _input(ev):
	var wait = 2
	var timer = t.set_wait_time(wait)

	var pause = ev.is_action_pressed("pause") && !ev.is_echo()

	if paused == false and pause:
		_on_pause()
	elif paused == true and pause:
		_on_unpause()

	if ev.is_action_pressed("pause"):
		if paused == true:
			t.start()
	elif ev.is_action("pause") && !ev.is_pressed():
		t.stop()
	else:
		timer

func _on_pause():
	pmenu.set_exclusive(true)
	pmenu.popup()
	get_tree().set_pause(true)
	az.hide()
	ui.hide()
	paused = true

func _on_unpause():
	pmenu.hide()
	get_tree().set_pause(false)
	az.show()
	ui.show()
	paused = false

func _on_timer_timeout():
	get_tree().quit()
	pass # replace with function body

func _ready():
	set_process_input(true)
