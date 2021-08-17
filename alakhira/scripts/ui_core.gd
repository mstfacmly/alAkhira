extends Container

signal start
signal quit

# Onready
#onready var shifter = shift_script
#var bar

# variables
var az
var envanim
var paused = false
var anim_hlth = 0
var spd = 2
var ev_mod = 0
var stage
var back = null
#var pressed = {}

var INPUT_CFG = []

const dir = [ 'left', 'right' ]

#var acts
#var btn
const btns = []
const CFG_FILE = 'user://config.cfg'

func _load_cfg():
	var cfg = ConfigFile.new()
	var err = cfg.load(CFG_FILE)
	
	if err:
		for act_name in INPUT_CFG:
			var act_list = InputMap.get_action_list(act_name)
			var scancode = OS.get_scancode_string(act_list[0].scancode)
			cfg.set_value('input', act_name, scancode)
		cfg.save(CFG_FILE)
	else:
		for act_name in cfg.get_section_keys('input'):
			var scancode = OS.find_scancode_from_string(cfg.get_value('input', act_name))
			var ev = InputEventKey.new()
			ev.scancode = scancode
			for old_ev in InputMap.get_action_list(act_name):
				if old_ev is InputEventKey:
					InputMap.action_erase_event(act_name, old_ev)
			InputMap.action_add_event(act_name, ev)

func _save_cfg(sect, key, val):
	var cfg = ConfigFile.new()
	var err = cfg.load(CFG_FILE)
	if err:
		print('Error on loading config file: ', err)
	else:
		cfg.set_value(sect, key, val)
		cfg.save(CFG_FILE)

func _on_timer_timeout():
	get_tree().quit()

"""func _populate(menu):
#	print(menu.name)
	for i in menu.get_children():
		pressed[i.name] = pressed.size()"""

func _ui_btn_pressed(press):
	match press.name:
		'start':
			call_deferred('_ld_cplt')
		'rld':
			get_tree().set_pause(false)
			get_tree().reload_current_scene()
		'quit':
			get_tree().quit()
		'rsm':
			_unpause()
		
		'opts':
			$org/right/opts/._showhide()
			_hide_menu()
		'langs':
			$org/right/langs._showhide()
			_hide_opts()
		'disp':
			$org/right/disp._showhide()
			_hide_opts()
		'ctrls':
			$org/right/ctrls._showhide()
			_hide_opts()
		'cam':
			$org/right/cam._showhide()
			_hide_opts()
		'dbg':
			$org/right/dbg._showhide()
			_hide_menu()
		'back':
			get_node('org/right/'+press.get_parent().name)._showhide()
			_hide_opts()
	
		'site':
			OS.shell_open('https://studioslune.com/')
	
		'fs':
			OS.set_window_fullscreen(!OS.window_fullscreen)
			$org/right/disp._fs_set()
		'vsync':
			OS.set_use_vsync(!OS.vsync_enabled)
			$org/right/disp._vsync_set()
		
		'info':
			$org/left/dbg_print.set_visible(!$org/left/dbg_print.visible)
			$org/right/dbg._dbg_txt_set()
		'col_ind':
			$org/right/dbg._show_collision(!$org/right/dbg.col_show)
			get_parent().get_node('body/Skeleton/targets').set_visible(!$org/right/dbg.col_show)
		'hlth_drn':
			$org/right/dbg._set_draining(!$org/right/dbg.draining)
		'hlth_full':
			az.hlth = az.max_hlth
		'hlth_nil':
			az.hlth = 0

func _hide_opts():
	$org/right/opts.set_visible(!$org/right/opts.is_visible())
#	_grab_menu()
	
func _hide_menu():
	$org/right/menuList.set_visible(!$org/right/menuList.is_visible())
#	_grab_menu()

func _grab_menu():
#	print(get_children())
	var menu = []
	for i in get_children():
		if i.get_class() == 'Button' && i.visible:
			menu.append(i)
	menu[0].grab_focus()

func _pause_menu(mode):
	get_parent().set_visible(!get_parent().visible)
	$org/right/hlth.set_visible(!$org/right/hlth.visible)
	Input.set_mouse_mode(mode)
	$org/right/menuList.set_visible(!$org/right/menuList.visible)
	paused = !paused
	get_tree().set_pause(paused)
	
#	_grab_menu()

func _pause():
	_pause_menu(0)

func _unpause():
	_pause_menu(2)
	
	for i in [ 'menuList' ,'opts', 'langs', 'disp', 'ctrls', 'cam', 'dbg' ]:
		$org/right.get_node(i).hide()
#	_pause_shift()

"""func _pause_shift():
	if shifter.curr != 'spi':
		envanim.play('shift', -1, spd, (spd < 0))
		shifter.curr = 'spi'
	elif shifter.curr != 'phys':
		envanim.play('shift', -1, -spd, (-spd < 0))
		shifter.curr = 'phys'"""

func _showhide():
	connect("draw",self,"_grab_menu")
	set_visible(!is_visible())	
#	_grab_menu()
