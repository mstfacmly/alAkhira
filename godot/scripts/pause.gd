extends Spatial

var paused = false
onready var t = get_node("timer")
onready var root = get_node("/root/")
onready var az = root.get_node("scene/player")
onready var ui = root.get_node("scene/player/scripts/healthb")

func _input(ev):
	var wait = 2
	var timer = t.set_wait_time(wait)

	var pause = ev.is_action_pressed("pause") && !ev.is_echo()

	if paused == false and pause:
		_on_pause()
	elif paused == true and pause:
		_on_unpause()

	if paused == true && ev.is_action_pressed("pause"):
		t.start()
	elif ev.is_action("pause") && !ev.is_pressed():
		t.stop()
	else:
		timer

func _on_pause():
	get_node("pause_menu").set_exclusive(true)
	get_node("pause_menu").popup()
	get_tree().set_pause(true)
	az.set_hidden(true)
	ui.set_hidden(true)
	paused = true

func _on_unpause():
	get_node("pause_menu").hide()
	get_tree().set_pause(false)
	az.set_hidden(false)
	ui.set_hidden(false)
	paused = false

func _on_timer_timeout():
	OS.get_main_loop().quit()
	pass # replace with function body

func _ready():
	set_process_input(true)
