extends MarginContainer

signal start
signal quit

export (String, FILE) var test = 'res://env/test/testroom.tscn'

# Onready
onready var bar = $org/right/hlth
onready var tween = $tween
onready var t = $timer
#onready var debug = $org/left
onready var shifter = shift

# variables
var az
var envanim
var max_hlth
var paused = false
var anim_hlth = 0
var spd = 2

const languages = [
	'English',
]

const disp_rez = [
	320, 
	640,
	800,
	1024,
	1280,
	1366,
	1600,
	1920,
	2560,
	3200,
	3840
]

var ratio_div
const ratio = [
	'4:3',
	'16:9',
	'16:10',
]

const aalist = [
	'Disabled',
	'2x',
	'4x',
	'8x',
	'16x'
]

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

const CFG_FILE = 'user://config.cfg'
var acts
var btn

func _ready():
	$org/right/version.text = str(0.11)

#	_load_cfg()
	
	for acts in INPUT_CFG:
		var input_ev = InputMap.get_action_list(acts)[0]
		var btn = $org/right/ctrls.get_node(acts).get_node('btn')
		btn.text = input_ev.as_text()
#		btn.connect('pressed', self, 'wait_for_input', [acts])

	shifter.curr
	_signals()
	
	var ID = $org/right/disp/ratio/ratio.get_selected_id()
	_ratio_select(ID)
	
	if get_parent().get_name() == 'az':
		_gen_ui()
		envanim = az.get_parent().get_node('env/AnimationPlayer')
		az.set_physics_process(true)
		az.get_node('cam').set_enabled(true)
	else:
		_main_menu()
		
	_opts_container()
	set_process_input(true)

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
					InputMap.action_erase_event(acts, old_ev)
			InputMap.action_add_event(act_name, ev)

func _save_cfg(sect, key, val):
	var cfg = ConfigFile.new()
	var err = cfg.load(CFG_FILE)
	if err:
		print('Error on loading config file: ', err)
	else:
		cfg.set_value(sect, key, val)
		cfg.save(CFG_FILE)
	
func wait_for_input(bind):
	acts = bind
	btn = $org/right/ctrls.get_node(acts).get_node('btn')
	
	set_process_input(true)

func _input(ev):
	var wait = 2
	var timer = t.set_wait_time(wait)

	var pause = ev.is_action_pressed('pause') && !ev.is_echo()

	if get_parent().get_name() == 'az' && az.state != 1:
		if !paused && pause:
			_on_pause()
		elif paused && pause:
			_on_unpause()

	if ev.is_action_pressed('pause'):
		t.start()
	elif ev.is_action('pause') && !ev.is_pressed():
		t.stop()
	else:
		timer
		
	if Input.is_key_pressed(KEY_F11):
		OS.set_window_fullscreen(!OS.window_fullscreen)

func _signals():
	# Main Menu
	$org/right/menuList/rld.connect('pressed', self, '_ui_btn_pressed', ['rld'])
	$org/right/menuList/dbg.connect('pressed', self, '_ui_btn_pressed', ['dbg'])
	$org/right/menuList/rsm.connect('pressed', self, '_ui_btn_pressed', ['rsm'])
	$org/right/menuList/start.connect('pressed', self, '_ui_btn_pressed', ['start'])
	$org/right/menuList/opts.connect('pressed', self, '_ui_btn_pressed', ['opts'])
	$org/right/menuList/quit.connect('pressed', self, '_ui_btn_pressed', ['quit'])

	# Options Menu
	$org/right/opts/ctrls.connect('pressed', self, '_ui_btn_pressed', ['ctrls'])
	$org/right/opts/disp.connect('pressed', self, '_ui_btn_pressed', ['disp'])
	$org/right/opts/back.connect('pressed', self, '_opts_btn_pressed', ['back'])
	$org/right/disp/back.connect('pressed', self, '_opts_btn_pressed', ['disp_b'])
	$org/right/ctrls/back.connect('pressed', self, '_opts_btn_pressed', ['ctrls_b'])	
	$org/left/org/over/rld.connect('pressed', self, '_ui_btn_pressed', ['rld'])
	$org/left/org/over/quit.connect('pressed', self, '_ui_btn_pressed', ['quit'])
	
	$org/right/disp/vsync/vsync.connect('pressed', self, '_opts_btn_pressed', ['vsync'])
	$org/right/disp/fs/fullscreen.connect('pressed', self, '_opts_btn_pressed', ['fullscreen'])
	
	$org/right/disp/ratio/ratio.get_popup().connect('id_pressed', self, '_ratio_select')
	$org/right/disp/res/res.get_popup().connect('id_pressed', self, '_res_select')
	$org/right/disp/fsaa/aa.get_popup().connect('id_pressed', self, '_aa_select')
	
	$org/left/org/over/lune_site.connect('pressed', self, '_ui_btn_pressed', ['site'])

func _main_menu():
	# Show/Hide Menu Items
#	$org/left/debug_info.show()
	$org/left/dbg.hide()
	
	$org/right/menuList/dbg.hide()
	$org/right/menuList/contd.hide()
	$org/right/menuList/rld.hide()
	$org/right/menuList/start.show()
	$org/right/menuList/rsm.hide()
	$org/right/menuList/opts.show()
	$org/right/menuList/quit.show()
	$org/right/hlth.hide()
	$org/right/opts.hide()
	$org/right/disp.hide()
	$org/right/ctrls.hide()
	
	$org/left/org/over/thanks.hide()
	$org/left/org/over/rld.hide()
	$org/left/org/over/quit.hide()
	$org/left/org/over/lune_site.hide()

func _opts_container():
	$org/right/opts/lang.disabled = true
	
	var rat = $org/right/disp/ratio/ratio
	var res = $org/right/disp/res/res
	var aa = $org/right/disp/fsaa/aa
	
	if OS.is_window_fullscreen() != false:
		$org/right/disp/fs/fullscreen.text = 'On'
	else:
		$org/right/disp/fs/fullscreen.text = 'Off'
	
	if OS.is_vsync_enabled() != false:
		$org/right/disp/vsync/vsync.text = 'On'
	else:
		$org/right/disp/vsync/vsync.text = 'Off'
	
	for l in languages:
#		lang.add_item(str(l))
		pass

	for r in ratio:
		rat.add_item(str(r))

	for i in aalist:
		aa.add_item(i)

func _gen_ui():
	az = get_parent()
	if az.request_ready() != true:
		pass
	else:
		max_hlth = az.max_hlth
		bar.max_value = max_hlth
		updt_hlth(max_hlth)
		az.get_node('cam').set_enabled(true)
	
#	$org/left/debug_info.hide()
	$org/left/dbg.hide()
	
	$org/left/org/over.hide()
	$org/right/opts.hide()
	$org/right/disp.hide()
	$org/right/ctrls.hide()

	$org/right/menuList.hide()
	$org/right/version.hide()
	$org/right/menuList/dbg.show()
	$org/right/menuList/contd.hide()
	$org/right/menuList/rld.show()
	$org/right/menuList/start.hide()
	$org/right/menuList/rsm.show()

func _on_pause():
	az.hide()
	bar.hide()
	paused = true
	Input.set_mouse_mode(0)
	$org/right/menuList.show()
	get_tree().set_pause(true)

	if shifter.curr != 'spi':
		envanim.play('shift', -1, spd, (spd < 0))
		shifter.curr = 'spi'
	elif shifter.curr != 'phys':
		envanim.play('shift', -1, -spd, (-spd < 0))
		shifter.curr = 'phys'

func _on_unpause():
	az.show()
	bar.show()
	paused = false
	Input.set_mouse_mode(2)
	$org/right/menuList.hide()
	$org/right/opts.hide()
	$org/right/disp.hide()
	$org/right/ctrls.hide()
	get_tree().set_pause(false)
	
#	var type = $org/right/menuList.get_children()
#	for i in type:
#				i.disabled = false

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
		_gen_ui()
		get_node('/root/global').load_scene(test)
	
	if btn == 'rld':
		get_tree().set_pause(false)
		get_tree().reload_current_scene()
	
	if btn == 'opts':
		_opts_menu()
		
	if btn == 'disp':
		_disps()
		
	if btn == 'ctrls':
		_ctrls()
	
	if btn == 'quit':
		get_tree().quit()
	
	if btn == 'rsm':
		_on_unpause()
		
	if btn == 'dbg':
		_show_dbg()
	
	if btn == 'site':
		OS.shell_open('http://studioslune.com/')


func _opts_btn_pressed(btn):
	if btn == 'fullscreen':
		if OS.is_window_fullscreen() != true:
			OS.set_window_fullscreen(true)
			$org/right/disp/fs/fullscreen.text = 'On'
		else:
			OS.set_window_fullscreen(false)
			$org/right/disp/fs/fullscreen.text = 'Off'
	
	if btn == 'vsync':
		if OS.is_vsync_enabled() != true:
			OS.set_use_vsync(true)
			$org/right/disp/vsync/vsync.text = 'On'
		else:
			OS.set_use_vsync(false)
			$org/right/disp/vsync/vsync.text = 'Off'
	
	if btn == 'back':
		_opts_menu()
		
	if btn == 'disp_b':
		_disps()
		
	if btn == 'ctrls_b':
		_ctrls()

func _ratio_select(ID):
	if ID == 0:
		ratio_div = 1.333333333
	elif ID == 1:
		ratio_div = 1.777777778
	elif ID == 2:
		ratio_div = 1.6

	_res_calc()

func _res_calc():
	var res = $org/right/disp/res/res
	var i = 0
	res.clear()
	for x in disp_rez:
		var y = x / ratio_div
		res.add_item(str(x) + ' x ' + str(y))

func _res_select(ID):
	OS.set_window_size(Vector2(disp_rez[ID], disp_rez[ID] / ratio_div))
	
	if OS.window_fullscreen != true:
		pass
	else:
		OS.set_window_fullscreen(false)
		OS.set_window_fullscreen(true)

func _aa_select(ID):
	get_viewport().msaa = ID
	
func _opts_menu():
	var opts = $org/right/opts

	if opts.is_visible() != true:	
		opts.set_visible(true)
	else:
		opts.set_visible(false)
	
	var menu = $org/right/menuList
	if menu.is_visible() != true:	
		menu.set_visible(true)
	else:
		menu.set_visible(false)
#	var type = $org/right/menuList.get_children()
#	for i in type:
#		if i.get_class() == 'Button':
#			if i.disabled != true:
#				i.disabled = true
#			else:
#				i.disabled = false

func _disps():
	var opts = $org/right/opts
	var disp = $org/right/disp
	
	if disp.is_visible() != true:
		disp.set_visible(true)
	else:
		disp.set_visible(false)
		
	if opts.is_visible() != true:
		opts.set_visible(true)
	else:
		opts.set_visible(false)
		
func _ctrls():
	var opts = $org/right/opts
	var ctrls = $org/right/ctrls
	
	if ctrls.is_visible() != true:
		ctrls.set_visible(true)
	else:
		ctrls.set_visible(false)
		
	if opts.is_visible() != true:
		opts.set_visible(true)
	else:
		opts.set_visible(false)

func _show_dbg():
	var dbg_txt = $org/left/dbg

	if dbg_txt.is_visible() != true:
		dbg_txt.set_visible(true)
	else:
		dbg_txt.set_visible(false)

func _over():
	$org/right/menuList.hide()
	$org/left/dbg.hide()
	$org/left/org/over.show()
	$org/right/hlth.hide()
	az.hide()
	$'../../az_spi'.show()
	az.set_physics_process(false)
	az.set_process(false)
	az.get_node('cam').set_enabled(false)
	Input.set_mouse_mode(0)