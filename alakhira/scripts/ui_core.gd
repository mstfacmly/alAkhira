extends Control

signal start
signal quit

#onready var shifter = shift_script

var back : Object setget _set_back , _get_back
var parentnode

# variables
var az
var envanim
var anim_hlth = 0
var stage
var env
var menu:Array

var INPUT_CFG = []

var onOff = ['Off', 'On']
const dir = [ 'left', 'right' ]

const btns = []
const CFG_FILE = 'user://config.cfg'

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel") && _get_back() != null:
		_back_btn_pressed(_get_back())

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

func _back_btn_pressed(press):
	match press.name:
		'opts':
			_showhide()
			get_parent().get_node('menuList')._showhide()
		'back':
			_showhide()
			get_parent().get_node('opts')._showhide()

func _ui_btn_pressed(press):
	match press.name:
		'start':
			call_deferred('_load_complete')
		'rld':
			_unpause()
			get_tree().reload_current_scene()
		'quit':
			get_tree().quit()
		'rsm':
			_pause_menu(2)
			_pause_shift(env,1,1,0,0.11)
		
		# Menu Options
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
			_ui_btn_pressed(get_node('org/right/'+press.get_parent().name))
	
		'site':
			OS.shell_open('https://studioslune.com/')
		
		#Display Options
		'fs':
			OS.set_window_fullscreen(!OS.window_fullscreen)
			$org/right/disp._fs_set()
		'fxaa':
			get_viewport().set_use_fxaa(!get_viewport().fxaa)
			$org/right/disp._fxaa_set()
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

func _main_menu(show,hide):
	# Show/Hide Menu Items
	for i in $org/right/menuList.get_children():
		if !show.has(i.name):
			i.hide()
		else:
			i.show()
	
	for i in $org/right.get_children():
		if hide.has(i.name):
			i.hide()

func _hide_left():
	$org/left/dbg_print.hide()
	$org/left/over.hide()

func _hide_opts():
	$org/right/opts._showhide()
	
func _hide_menu():
	$org/right/menuList._showhide()

func _grab_menu():
	for i in get_children():
		"""if i.get_class() == 'HBoxContainer':#i.get_class() == 'ScrollContainer':
			menu.append(i.get_child(1))"""
		if i.get_class() == 'Button' && i.visible:
			menu.append(i)
	menu[0].grab_focus()
	_set_back(menu.back())
	return menu.clear()

func _set_back(back_item):
	back = back_item

func _get_back():
	return back

func _pause_menu(mode):
	Input.set_mouse_mode(mode)
	get_parent().set_visible(!get_parent().visible)
	$org/right/hlth.set_visible(!$org/right/hlth.visible)
	$org/right/menuList.set_visible(!$org/right/menuList.visible)
	get_tree().set_pause(!get_tree().paused)

func _unpause():
	_pause_menu(2)
	
	for i in [ 'menuList' ,'opts', 'langs', 'disp', 'ctrls', 'cam', 'dbg' ]:
		$org/right.get_node(i).hide()

func _pause_shift(environment, new_value, new_saturation, new_dof, duration):
	environment.environment.dof_blur_far_enabled = 1 if new_dof > 0 else 0

	$tween.interpolate_property(environment.environment, 'adjustment_brightness', environment.environment.get_adjustment_brightness(), new_value, duration, Tween.TRANS_CIRC )
	$tween.interpolate_property(environment.environment, 'adjustment_saturation', environment.environment.get_adjustment_saturation(), new_saturation, duration, Tween.TRANS_CUBIC )
	$tween.interpolate_property(environment.environment, 'dof_blur_far_amount', environment.environment.get_dof_blur_far_amount(), new_dof, duration, Tween.TRANS_QUAD )

func _clear_menu():
	menu.clear()

func _showhide():
	"""if !is_connected("draw",self,"_grab_menu"):
		connect("draw",self,"_grab_menu")
	if !is_connected("hide",self,'_clear_menu'):
		connect("hide",self,'_clear_menu')"""
	set_visible(!visible)
	set_process(visible)
	if visible:
		_grab_menu() 
	else:
		_set_back(menu.clear())
#	connect("draw", self, "_grab_menu") #if is_visible() else disconnect("draw",self, '_grab_menu')
#	_set_back(_grab_menu()) if is_visible() else _set_back(null)
