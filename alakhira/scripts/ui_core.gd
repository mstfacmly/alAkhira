extends Container

signal start
signal quit

# Onready
#onready var shifter = shift_script
var bar

# variables
var az
var envanim
var paused = false
var anim_hlth = 0
var spd = 2
var ev_mod = 0
var stage
var back = null
var pressed = {}

const INPUT_CFG = [
	'mv_f', 
	'mv_b',
	'mv_l',
	'mv_r',
	'arm_l',
	'arm_r',
	'head',
	'feet',
	'cast',
	'act',
]

const dir = [ 'left', 'right' ]

var acts
#var btn
var ctrls_men = false
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
	
"""func _get_input(bind):
	acts = bind
	btn = $org/right/ctrls.get_node(acts).get_node('btn')
	
	set_process_input(true)"""

func _gui_input(ev):
	if ev.is_action_pressed('ui_down'):
		focus_next
		accept_event()
	if ev.is_action_pressed('ui_up'):
		focus_previous
		accept_event()
	if ev.is_action_pressed('ui_accept'):
		_ui_btn_pressed(ev)
		accept_event()

func _on_timer_timeout():
	get_tree().quit()

func _populate(menu):
#	print(menu.name)
	for i in menu.get_children():
		pressed[i.name] = pressed.size()

func _ui_btn_pressed(press):
	if press.name == 'start':
		call_deferred('_ld_cplt')
	
	if press.name == 'rld':
		get_tree().set_pause(false)
		get_tree().reload_current_scene()
		
	match press.name:
		'opts':
			$org/right/opts/._opts_menu()
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
	
		'quit':
			get_tree().quit()
		'rsm':
			_unpause()
		
		'site':
			OS.shell_open('https://studioslune.com/')
	
		'fs':
			OS.set_window_fullscreen(!OS.window_fullscreen)
			if OS.is_window_fullscreen():
				$org/right/disp/fs/btn.text = 'On'
			else:
				$org/right/disp/fs/btn.text = 'Off'
	
		'vsync':
#		OS.vsync_enabled = !OS.vsync_enabled
			if OS.is_vsync_enabled() != true:
				OS.set_use_vsync(true)
				$org/right/disp/vsync/btn.text = 'On'
			else:
				OS.set_use_vsync(false)
				$org/right/disp/vsync/btn.text = 'Off'
			
		'info':
			#_show_dbg()
			$org/left/dbg_print.visible = false if $org/left/dbg_print.visible else true
			if $org/left/dbg_print.is_visible() != true:
				$org/right/dbg/info/btn.text = 'Off'
			else:
				$org/right/dbg/info/btn.text = 'On' 
	
		'col_ind':
			#_show_col()
			az.get_node('body/Skeleton/targets/ptarget/Sprite3D').visible = false if az.get_node('body/Skeleton/targets/ptarget/Sprite3D').visible else true
		
			if az.get_node('body/Skeleton/targets/ptarget/Sprite3D').visible != true:
				$org/right/dbg/col_ind/btn.text = 'Hide'
			else:
				$org/right/dbg/col_ind/btn.text = 'Show'
	
		'hlth_drn':
			$org/right/dbg._health_drain()
#			az.hlth_drain = !az.hlth_drain

		'hlth_full':
			az.hlth = az.max_hlth
	
		'hlth_nil':
			az.hlth = 0
	"""
		if az.hlth_drain != false:
			az.hlth_drain = false
			$org/right/dbg/hlth_drn/btn.text = 'Disabled'
		else:
			az.hlth_drain = true
			$org/right/dbg/hlth_drn/btn.text = 'Enabled'
	"""

func _hide_opts():
	var opts = $org/right/opts
	
	if opts.is_visible() != true:
		opts.set_visible(true)
		back = funcref(self, '_opts_menu')
	else:
		opts.set_visible(false)
	
	_grab_menu()

func _hide_menu():
	var menu = $org/right/menuList
	if menu.is_visible() != true:
		menu.set_visible(true)
	else:
		menu.set_visible(false)
	
	_grab_menu()

#	var type = $org/right/menuList.get_children()
#	for i in type:
#		if i.get_class() == 'Button':
#			if i.disabled != true:
#				i.disabled = true
#			else:
#				i.disabled = false

func _grab_menu():
	var menlistr = [ 'menuList', 'opts', 'langs', 'disp', 'ctrls', 'cam', 'dbg' ]
	var d = get_parent().name
	if d == 'left':
		for b in find_node('over').get_children():
			btns.clear()
			if b.is_visible() != false && b.get_focus_mode():
				btns.append(b)
				btns[0].grab_focus()
	elif d == 'right':
		if !menlistr.has(name):
			for m in menlistr:
				var men = get_node(m)
				if men != null && men.is_visible() != false:
					btns.clear()
					for b in men.get_children():
						if b.is_visible() != false && b.get_focus_mode():
							btns.append(b)
							btns[0].grab_focus()

func _pause_menu():
	az.hide()
	bar.hide()
	Input.set_mouse_mode(0)
	$org/right/menuList.show()
	_grab_menu()

func _pause():
	_pause_menu()
#	_pause_shift()
	paused = true
	get_tree().set_pause(true)

func _unpause():
	az.show()
	bar.show()
	paused = false
	Input.set_mouse_mode(2)
	for i in [ 'menuList', 'opts', 'langs', 'disp', 'ctrls', 'cam', 'dbg' ]:
		$org/right.get_node(i).hide()
#	_pause_shift()
	get_tree().set_pause(false)

#func _pause_shift():
#	if shifter.curr != 'spi':
#		envanim.play('shift', -1, spd, (spd < 0))
#		shifter.curr = 'spi'
#	elif shifter.curr != 'phys':
#		envanim.play('shift', -1, -spd, (-spd < 0))
#		shifter.curr = 'phys'

func _showhide():
	if is_visible() != true:
		set_visible(true)
		back = funcref(self, '_showhide')
	else:
		set_visible(false)
	
	_grab_menu()
