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

func _ready():
	$org/right/version.text = str(0.11)
	shifter.curr
	_signals()
	
	var ID = $org/center/disp_opt/ratio/ratio.get_selected_id()
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
	$org/center/opts/ctrls.connect('pressed', self, '_opts_btn_pressed', ['ctrls'])
	$org/center/opts/disp_opt.connect('pressed', self, '_ui_btn_pressed', ['disp'])
	$org/center/opts/back.connect('pressed', self, '_opts_btn_pressed', ['back'])
	$org/center/disp_opt/back.connect('pressed', self, '_opts_btn_pressed', ['disp_b'])
	$org/center/over/rld.connect('pressed', self, '_ui_btn_pressed', ['rld'])
	$org/center/over/quit.connect('pressed', self, '_ui_btn_pressed', ['quit'])
	
	$org/center/disp_opt/vsync/vsync.connect('pressed', self, '_opts_btn_pressed', ['vsync'])
	$org/center/disp_opt/fs/fullscreen.connect('pressed', self, '_opts_btn_pressed', ['fullscreen'])
	
	$org/center/disp_opt/ratio/ratio.get_popup().connect('id_pressed', self, '_ratio_select')
	$org/center/disp_opt/res/res.get_popup().connect('id_pressed', self, '_res_select')
	$org/center/disp_opt/fsaa/aa.get_popup().connect('id_pressed', self, '_aa_select')
	
	$org/center/over/lune_site.connect('pressed', self, '_ui_btn_pressed', ['site'])

func _main_menu():
	# Show/Hide Menu Items
	$org/left/debug_info.show()
	
	$org/right/menuList/dbg.hide()
	$org/right/menuList/contd.hide()
	$org/right/menuList/rld.hide()
	$org/right/menuList/start.show()
	$org/right/menuList/rsm.hide()
	$org/right/menuList/opts.show()
	$org/right/menuList/quit.show()
	$org/right/hlth.hide()
	
	$org/center/opts.hide()
	$org/center/disp_opt.hide()
	$org/center/ctrls.hide()
	$org/center/over/thanks.hide()
	$org/center/over/rld.hide()
	$org/center/over/quit.hide()
	$org/center/over/lune_site.hide()

func _opts_container():
	$org/center/opts/ctrls.disabled = true
	var lang = $org/center/opts/lang/lang
	var rat = $org/center/disp_opt/ratio/ratio
	var res = $org/center/disp_opt/res/res
	var aa = $org/center/disp_opt/fsaa/aa
	
	if OS.is_window_fullscreen() != false:
		$org/center/disp_opt/fs/fullscreen.set_pressed(true)
	if OS.is_vsync_enabled() != false:
		$org/center/disp_opt/vsync/vsync.set_pressed(true)
		
	for l in languages:
		lang.add_item(str(l))

	for r in ratio:
		rat.add_item(str(r))

#	for d in disp_rez:
#		var d2 = d / ratio_div
#		res.add_item(str(d) + ' x ' + str(d2))

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
	
	$org/left/debug_info.hide()

	$org/center/over.hide()
	$org/center/opts.hide()
	$org/center/disp_opt.hide()

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
	$org/center/opts.hide()
	get_tree().set_pause(false)
	
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
	if btn == 'start':
		_gen_ui()
		get_node('/root/global').load_scene(test)
	
	if btn == 'rld':
		get_tree().set_pause(false)
		get_tree().reload_current_scene()
	
	if btn == 'opts':
		_opts_menu()
		
	if btn == 'disp':
		_disp_opts()
	
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

func _ratio_select(ID):
	if ID == 0:
		ratio_div = 1.333333333
	elif ID == 1:
		ratio_div = 1.777777778
	elif ID == 2:
		ratio_div = 1.6

	_res_calc()

func _res_calc():
	var res = $org/center/disp_opt/res/res
	var i = 0
	res.clear()
	for x in disp_rez:
		var y = x / ratio_div
		res.add_item(str(x) + ' x ' + str(y))

func _res_select(ID):
	print(disp_rez[ID], disp_rez[ID] / ratio_div)
	OS.set_window_size(Vector2(disp_rez[ID], disp_rez[ID] / ratio_div))

#	$org/center/disp_opt/res/res.get_popup().get_index()
#	print($org/center/disp_opt/res/res.get_popup().get_item_text(ID))
#	pass

func _aa_select(ID):
	get_viewport().msaa = ID
	
func _opts_menu():
	var menu = $org/center/opts

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

func _disp_opts():
	var opts = $org/center/opts
	var disp = $org/center/disp_opt
	
	if disp.is_visible() != true:
		disp.set_visible(true)
	else:
		disp.set_visible(false)
		
	if opts.is_visible() != true:
		opts.set_visible(true)
	else:
		opts.set_visible(false)

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
	
	if btn == 'back':
		_opts_menu()
		
	if btn == 'disp_b':
		_disp_opts()

func _show_debug():
	var dbg_txt = $org/left/debug_info

	if dbg_txt.is_visible() != true:	
		dbg_txt.set_visible(true)
	else:
		dbg_txt.set_visible(false)

func _over():
	$org/right/menuList.hide()
	$org/center/over.show()
	az.hide()
	$'../../az_spi'.show()
	az.set_physics_process(false)
	az.set_process(false)
	az.get_node('cam').set_enabled(false)
	Input.set_mouse_mode(0)