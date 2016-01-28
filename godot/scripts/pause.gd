extends Spatial

var paused = false
onready var t = get_node("timer")
onready var root = get_node("/root/")
onready var az = root.get_node("scene/player")

func _input(ev):
	var wait = 2
	var timer = t.set_wait_time(wait)
	
	var pause = ev.is_action_pressed("pause") && !ev.is_echo()
	
	if paused == false and pause:
		_on_pause()
		paused = true
	elif paused == true and pause:
		_on_unpause()
		paused = false
			
	if ev.is_action("pause") && ev.is_pressed():
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

func _on_unpause():
	get_node("pause_menu").hide()
	get_tree().set_pause(false)
	az.set_hidden(false)

func _on_timer_timeout():
	OS.get_main_loop().quit()
	pass # replace with function body

func _ready():
	set_process_input(true)
