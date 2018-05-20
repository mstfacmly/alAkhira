extends MarginContainer

signal start
signal quit

export (String, FILE) var test = 'res://env/test/testroom.tscn'

# Onready
onready var bar = $org/right/hlth
onready var tween = $tween
onready var t = $timer
onready var debug = $org/left
onready var shifter = shift

# variables
var az
var envanim
var max_hlth
var paused = false
var anim_hlth = 0
var spd = 2

func _ready():
	shifter.curr
	_signals()
	
	if get_parent().get_name() == 'az':
		_gen_ui()
		envanim = az.get_parent().get_node('env/AnimationPlayer')
	else:
		_main_menu()
		
	_opts_container()
		
	set_process_input(true)

func _input(ev):
	var wait = 2
	var timer = t.set_wait_time(wait)

	var pause = ev.is_action_pressed("pause") && !ev.is_echo()

	if get_parent().get_name() == 'az':
		if !paused && pause:
			_on_pause()
		elif paused && pause:
			_on_unpause()

	if ev.is_action_pressed("pause"):
		t.start()
	elif ev.is_action("pause") && !ev.is_pressed():
		t.stop()
	else:
		timer
		
	if Input.is_key_pressed(KEY_F11):
		OS.set_window_fullscreen(!OS.window_fullscreen)

func _signals():
	# Main Menu
	$org/right/menuList/rld.connect("pressed", self, "_ui_btn_pressed", ['rld'])
	$org/right/menuList/dbg.connect("pressed", self, "_ui_btn_pressed", ['dbg'])
	$org/right/menuList/rsm.connect("pressed", self, "_ui_btn_pressed", ['rsm'])
	$org/right/menuList/start.connect("pressed", self, "_ui_btn_pressed", ['start'])
	$org/right/menuList/options.connect("pressed", self, "_ui_btn_pressed", ['options'])
	$org/right/menuList/quit.connect("pressed", self, "_ui_btn_pressed", ['quit'])

	# Options Menu
	$org/center/container/options/ctrls.connect("pressed", self, "_opts_btn_pressed", ['ctrls'])
	$org/center/container/options/vsync.connect("pressed", self, "_opts_btn_pressed", ['vsync'])
	$org/center/container/options/fullscreen.connect("pressed", self, "_opts_btn_pressed", ['fullscreen'])
	$org/center/container/options/back.connect("pressed", self, "_opts_btn_pressed", ['back'])
	$org/center/container/over/quit.connect("pressed", self, "_ui_btn_pressed", ['quit'])
	
	$org/center/container/over/lune_site.connect("pressed", self, "_ui_btn_pressed", ['site'])

func _main_menu():
	# Show/Hide Menu Items
	$org/left/debug_info.show()
	
	$org/right/menuList/dbg.hide()
	$org/right/menuList/contd.hide()
	$org/right/menuList/rld.hide()
	$org/right/menuList/start.show()
	$org/right/menuList/rsm.hide()
	$org/right/menuList/options.show()
	$org/right/menuList/quit.show()
	$org/right/hlth.hide()
	
	$org/center/container/options.hide()
	$org/center/container/over/thanks.hide()
	$org/center/container/over/quit.hide()
	$org/center/container/over/lune_site.show()

func _opts_container():
	$org/center/container/options/lang.disabled = true
	$org/center/container/options/ctrls.disabled = true
	$org/center/container/options/res.disabled = true
	$org/center/container/options/aa.disabled = true
	
	if OS.is_window_fullscreen() != false:
		$org/center/container/options/fullscreen.set_pressed(true)
	if OS.is_vsync_enabled() != false:
		$org/center/container/options/vsync.set_pressed(true)

func _gen_ui():
	az = get_parent()
	if az.request_ready() != true:
		pass
	else:
		max_hlth = az.max_hlth
		bar.max_value = max_hlth
		updt_hlth(max_hlth)
	
		az.connect('hlth_chng', self, '_on_hlth_chng')
		az.connect("died", self, "_over")
		
	$org/left/debug_info.hide()

#	$org/center/container/over/logo.hide()
	$org/center/container/over.hide()
	$org/center/container/options.hide()

	$org/right/menuList.hide()
	$org/right/version.hide()
	$org/right/menuList/dbg.show()
	$org/right/menuList/contd.hide()
	$org/right/menuList/rld.show()
	$org/right/menuList/start.hide()
	$org/right/menuList/rsm.show()

func _on_pause():
	get_tree().set_pause(true)
	if get_parent().get_name() == 'az':
		az.hide()
	bar.hide()
	paused = true
	Input.set_mouse_mode(0)
	$org/right/menuList.show()

	if shifter.curr != 'spi':
		envanim.play('shift', -1, spd, (spd < 0))
		shifter.curr = 'spi'
	elif shifter.curr != 'phys':
		envanim.play('shift', -1, -spd, (-spd < 0))
		shifter.curr = 'phys'

func _on_unpause():
	get_tree().set_pause(false)
	if get_parent().get_name() == 'az':
		az.show()
	bar.show()
	paused = false
	Input.set_mouse_mode(2)
	$org/right/menuList.hide()
	$org/center/container/options.hide()
	
	var type = $org/right/menuList.get_children()
	for i in type:
				i.disabled = false

	if shifter.curr != 'phys':
		envanim.play('shift', -1, -spd, (-spd < 0))
		shifter.curr = 'phys'
	elif shifter.curr != 'spi':
		envanim.play('shift', -1, spd, (spd < 0))
		shifter.curr = 'spi'

func _on_timer_timeout():
	get_tree().quit()
	
func _on_hlth_chng(hlth):
	_updt_hlth(hlth)
	
func _updt_hlth(new_val):
	tween.interpolate_property(self, 'anim_hlth', anim_hlth, new_val, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if !tween.is_active():
		tween.start()
		
func _process(delta):
	bar.value = anim_hlth

func _ui_btn_pressed(btn):
#	print(btn)
	if btn == 'start':
#		self.hide()
		_gen_ui()
		get_node("/root/global").load_scene(test)
	
	if btn == 'rld':
		get_tree().reload_current_scene()
		get_tree().set_pause(false)
	
	if btn == 'options':
		_opts_menu()
		
	if btn == 'debug':
		pass
	
	if btn == 'quit':
		get_tree().quit()
	pass
	
	if btn == 'site':
		OS.shell_open('http://studioslune.com/')
	
	if btn == 'rsm':
		_on_unpause()
		
	if btn == 'dbg':
		_show_debug()

func _opts_menu():
	var menu = $org/center/container/options

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

func _opts_btn_pressed(btn):
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
#		print(OS.is_vsync_enabled())
	
	if btn == 'back':
		_opts_menu()

func _show_debug():
	var dbg_txt = $org/left/debug_info
#	print(dbg_txt.is_visible())

	if dbg_txt.is_visible() != true:	
		dbg_txt.set_visible(true)
	else:
		dbg_txt.set_visible(false)

func _show_msg(txt):
	$Label.text = txt
	$Label.show()

func _end():
	show_msg("Thank you")
	pass

func _over():
	$org/right.hide()
	$org/center/container/over/thanks.show()
	$org/center/container/over/lune_site.show()
	$org/center/container/over/quit.show()
	az.hide()
	az.get_node('cam').set_enabled(false)
	Input.set_mouse_mode(0)