extends MarginContainer

signal start
signal quit

export (String, FILE) var test = 'res://env/test/testroom.tscn'

func menu():
	# Show/Hide Menu Items
	$org/right/menuList/dbg.hide()
	$org/right/menuList/contd.hide()
	$org/right/menuList/rld.hide()
	$org/right/menuList/new_game.show()
	$org/right/menuList/rsm.hide()
	$org/right/menuList/options.show()
	$org/right/menuList/quit.show()
	$org/center/container/over/thanks.hide()
	$org/center/container/over/lune_site.show()
	
	$org/center/container/optionsMenu.hide()
	$org/center/container/over/quit.hide()
	
	$org/center/container/optionsMenu/lang.disabled = true
	$org/center/container/optionsMenu/ctrls.disabled = true
	$org/center/container/optionsMenu/res.disabled = true
	$org/center/container/optionsMenu/aa.disabled = true
	
	if OS.is_window_fullscreen() != false:
		$org/center/container/optionsMenu/fullscreen.set_pressed(true)
	if OS.is_vsync_enabled() != false:
		$org/center/container/optionsMenu/vsync.set_pressed(true)
	
	# Main Menu
	$org/right/menuList/new_game.connect("pressed", self, "ui_button_pressed", ['new_game'])
	$org/right/menuList/options.connect("pressed", self, "ui_button_pressed", ['options'])
	$org/right/menuList/quit.connect("pressed", self, "ui_button_pressed", ['quit'])
	$org/right/menuList/rld.connect("pressed", self, "ui_button_pressed", ['rld'])

	# Options Menu
	$org/center/container/optionsMenu/ctrls.connect("pressed", self, "options_button_pressed", ['ctrls'])
	$org/center/container/optionsMenu/vsync.connect("pressed", self, "options_button_pressed", ['vsync'])
	$org/center/container/optionsMenu/fullscreen.connect("pressed", self, "options_button_pressed", ['fullscreen'])
	$org/center/container/optionsMenu/back.connect("pressed", self, "options_button_pressed", ['back'])
	$org/center/container/over/quit.connect("pressed", self, "ui_button_pressed", ['quit'])
	
	$org/center/container/over/lune_site.connect("pressed", self, "ui_button_pressed", ['site'])

func show_msg(txt):
	$Label.text = txt
	$Label.show()

func end():
	show_msg("Thank you")
	pass
	
func ui_button_pressed(btn):
	if btn == 'new_game':
		self.hide()
		get_node("/root/global").load_scene(test)
	
	if btn == 'rld':
		get_tree().reload_current_scene()
	
	if btn == 'options':
		$org/center/container/over.hide()
		options_menu()
		
	if btn == 'debug':
		pass
	
	if btn == 'quit':
		get_tree().quit()
	pass
	
	if btn == 'site':
		print(btn)
		OS.shell_open('http://studioslune.com/')
	
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

func options_button_pressed(btn):
	if btn == 'fullscreen':
		if OS.is_window_fullscreen() != true:
			OS.set_window_fullscreen(true)
		else:
			OS.set_window_fullscreen(false)
	
	if btn == 'vsync':
		if OS.is_vsync_enabled() == true:
			OS.set_use_vsync(true)
		else:
			OS.set_use_vsync(false)
		print(OS.is_vsync_enabled())
	
	if btn == 'back':
		$org/center/container/over.show()
		options_menu()

func _ready():
	menu()

func _input(ev):
	if Input.is_key_pressed(KEY_F11):
		OS.set_window_fullscreen(!OS.window_fullscreen)
