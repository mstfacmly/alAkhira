extends MarginContainer

signal start
signal quit

func menu():
	# Hide Menu Items
	$org/right/menuList/dbg.hide()
	$org/right/menuList/contd.hide()
	$org/right/menuList/new_game.show()
	$org/right/menuList/res.hide()
	$org/right/menuList/options.show()
	$org/right/menuList/quit.show()
	
	$org/center/container/optionsMenu.hide()
	$org/center/container/optionsMenu/lang.disabled = true
	$org/center/container/optionsMenu/ctrls.disabled = true
	
	if OS.is_window_fullscreen() != false:
		$org/center/container/optionsMenu/fullscreen.set_pressed(true)
	
	# Main Menu
	$org/right/menuList/new_game.connect("pressed", self, "ui_button_pressed", ['new_game'])
	$org/right/menuList/options.connect("pressed", self, "ui_button_pressed", ['options'])
	$org/right/menuList/quit.connect("pressed", self, "ui_button_pressed", ['quit'])

	# Options Menu
	$org/center/container/optionsMenu/ctrls.connect("pressed", self, "options_button_pressed", ['ctrls'])
	$org/center/container/optionsMenu/vsync.connect("pressed", self, "options_button_pressed", ['vsync'])
	$org/center/container/optionsMenu/fullscreen.connect("pressed", self, "options_button_pressed", ['fullscreen'])
	$org/center/container/optionsMenu/back.connect("pressed", self, "options_button_pressed", ['back'])

func show_msg(txt):
	$Label.text = txt
	$Label.show()

func end():
	show_msg("Thank you")
	pass
	
func ui_button_pressed(button_name):
	if button_name == 'new_game':
		print(button_name)
	
	if button_name == 'options':
		options_menu()
	
	if button_name == 'quit':
		get_tree().quit()
	pass
	
func options_menu():
	var menu = $org/center/container/optionsMenu

	if menu.is_visible() != true:	
		menu.set_visible(true)
	else:
		menu.set_visible(false)
		
	var type = $org/right/menuList.get_children()
	for i in type:
		if i.get_class() == 'Button':
			if i.disabled != true:
				i.disabled = true
			else:
				i.disabled = false
				
func options_button_pressed(button_name):
	if button_name == 'fullscreen':
		if OS.is_window_fullscreen() != true:
			OS.set_window_fullscreen(true)
		else:
			OS.set_window_fullscreen(false)


	
	if button_name == 'vsync':
		if OS.is_vsync_enabled() != true:
			OS.set_use_vsync(true)
		else:
			OS.set_use_vsync(false)
		print(OS.is_vsync_enabled())
	
	if button_name == 'back':
		options_menu()

func _ready():
	menu()
	pass
