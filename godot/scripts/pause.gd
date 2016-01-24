extends Spatial

var paused = false
onready var t = get_node("timer")
var time = 3
var timeout = false


func _input(event):
	if paused == false and event.is_action_pressed("pause") && !event.is_echo():
		_on_pause()
	elif paused == true and event.is_action_pressed("pause") && !event.is_echo():
		_on_unpause()
		
	var timer = t.set_wait_time(time)	
		
	if (event.is_action_pressed("pause")):
		t.start()
	else:
		t.set_wait_time(time)

func _on_pause():
	get_node("pause_menu").set_exclusive(true)
	get_node("pause_menu").popup()
	get_tree().set_pause(true)
	paused = true

func _on_unpause():
	get_node("pause_menu").hide()
	get_tree().set_pause(false)
	paused = false
	
func _ready():
	set_process_input(true)

func _on_timer_timeout():
	OS.get_main_loop().quit()
	pass # replace with function body
