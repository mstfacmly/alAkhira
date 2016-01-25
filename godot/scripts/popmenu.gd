
extends PopupPanel

func _on_buttons_button_selected( button ):
	var quit = (button == 3)
	
	if quit: #and Input.is_action_pressed("ui_accept"):
		OS.get_main_loop().quit()
