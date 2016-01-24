extends Spatial

var paused = false

func _process(p):
	if paused == false and Input.is_action_pressed("pause"):
		_on_pause()
	elif paused == true and Input.is_action_pressed("pause"):
		_on_unpause()
	
	print(paused)

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
	set_process(true)