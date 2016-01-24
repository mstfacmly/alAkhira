extends Spatial

var paused = false
onready var t = get_node("timer")

func _input(event):
	var wait = 2
	var timer = t.set_wait_time(wait)
	
	if paused == false and event.is_action_pressed("pause") && !event.is_echo():
		_on_pause()
		paused = true
	elif paused == true and event.is_action_pressed("pause") && !event.is_echo():
		_on_unpause()
		paused = false
			
	if event.is_action("pause") && event.is_pressed():
		t.start()
	elif event.is_action("pause") && !event.is_pressed():
		t.stop()
	else: 
		timer

func _on_pause():
	get_node("pause_menu").set_exclusive(true)
	get_node("pause_menu").popup()
	get_tree().set_pause(true)

func _on_unpause():
	get_node("pause_menu").hide()
	get_tree().set_pause(false)

func _on_timer_timeout():
	OS.get_main_loop().quit()
	pass # replace with function body

func _ready():
	set_process_input(true)
