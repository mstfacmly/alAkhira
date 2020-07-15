extends Container

signal start
signal quit

# Onready
#onready var shifter = shift_script
var bar
var tween
var t

# variables
var az
var envanim
var max_hlth
var paused = false
var anim_hlth = 0
var spd = 2
var ev_mod = 0
var thread = Thread.new()
var stage
var back = null

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
var btn
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
	
func _get_input(bind):
	acts = bind
	btn = $org/right/ctrls.get_node(acts).get_node('btn')
	
	set_process_input(true)

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

func _ui_btn_pressed(btn):
	if btn == 'start':
		call_deferred('_ld_cplt')
	
	if btn == 'rld':
		get_tree().set_pause(false)
		get_tree().reload_current_scene()
	
	if btn == 'opts' or btn == 'opts_b':
		_opts_menu()
	if btn == 'langs' or btn == 'langs_b':
		$org/right/langs.call_deferred('_showhide')
		_hide_opts()
	if btn == 'disp' or btn == 'disp_b':
		$org/right/disp.call_deferred('_showhide')
		_hide_opts()
	if btn == 'ctrls' or btn == 'ctrls_b':
		$org/right/ctrls.call_deferred('_showhide')
		_hide_opts()
	if btn == 'cam' or btn == 'cam_b':
		$org/right/cam.call_deferred('_showhide')
		_hide_opts()
	if btn == 'dbg' or btn == 'dbg_b':
		$org/right/dbg.call_deferred('_showhide')
		_hide_menu()
	
	if btn == 'quit':
		get_tree().quit()
	if btn == 'rsm':
		_on_unpause()
		
	if btn == 'site':
		OS.shell_open('https://studioslune.com/')
	
	if btn == 'fs':
		OS.window_fullscreen = !OS.window_fullscreen
		if OS.is_window_fullscreen() == true:
			$org/right/disp/fs/btn.text = 'On'
		else:
			$org/right/disp/fs/btn.text = 'Off'
	
	if btn == 'vsync':
#		OS.vsync_enabled = !OS.vsync_enabled
		if OS.is_vsync_enabled() != true:
			OS.set_use_vsync(true)
			$org/right/disp/vsync/btn.text = 'On'
		else:
			OS.set_use_vsync(false)
			$org/right/disp/vsync/btn.text = 'Off'
			
	if btn == 'info':
		#_show_dbg()
		if $org/left/dbg.is_visible() != true:
			$org/right/dbg/info/btn.text = 'Off'
		else:
			$org/right/dbg/info/btn.text = 'On' 
	
	if btn == 'col_ind':
		#_show_col()
		if az.get_node('body/Skeleton/targets/ptarget/Sprite3D').is_visible() != true:
			$org/right/dbg/col_ind/btn.text = 'Hide'
		else:
			$org/right/dbg/col_ind/btn.text = 'Show'
	
	if btn == 'hlth_drn':
		if az.hlth_drn != false:
			az.hlth_drn = false
			$org/right/dbg/hlth_drn/btn.text = 'Disabled'
		else:
			az.hlth_drn = true
			$org/right/dbg/hlth_drn/btn.text = 'Enabled'
	
	if btn == 'hlth_full':
		az.hlth = az.max_hlth
	
	if btn == 'hlth_nil':
		az.hlth = 0
		

func _hide_opts():
	var opts = $org/right/opts
	
	if opts.is_visible() != true:
		opts.set_visible(true)
		back = funcref(self, '_opts_menu')
	else:
		opts.set_visible(false)
	
	_grab_menu()

func _opts_menu():
	var opts = $org/right/opts
	var menu = $org/right/menuList
	
	if opts.is_visible() != true:
		opts.set_visible(true)
		back = funcref(self, '_opts_menu')
	else:
		opts.set_visible(false)
		if az != null:
			back = funcref(self, '_pause_menu')
		else:
			back = funcref(self, '_main_menu')
	
	if menu.is_visible() != true:	
		menu.set_visible(true)
		back = funcref(self, '_opts_menu')
	else:
		menu.set_visible(false)
	
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
	var menlist = [ 'menuList', 'opts', 'langs', 'disp', 'ctrls', 'cam', 'dbg' ]
	var d = get_parent().name
	if d == 'left':
		for b in find_node('over').get_children():
			btns.clear()
			if b.is_visible() != false && b.get_focus_mode():
				btns.append(b)
				btns[0].grab_focus()
	elif d == 'right':
		for m in menlist:
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

func _on_pause():
	_pause_menu()
#	_pause_shift()
	paused = true
	get_tree().set_pause(true)

func _on_unpause():
	az.show()
	bar.show()
	paused = false
	Input.set_mouse_mode(2)
	$org/right/menuList.hide()
#	_pause_shift()
	get_tree().set_pause(false)

#func _pause_shift():
#	if shifter.curr != 'spi':
#		envanim.play('shift', -1, spd, (spd < 0))
#		shifter.curr = 'spi'
#	elif shifter.curr != 'phys':
#		envanim.play('shift', -1, -spd, (-spd < 0))
#		shifter.curr = 'phys'
