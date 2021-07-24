extends 'res://scripts/ui_core.gd'

var thread = Thread.new()

export (String, FILE) var test = 'res://env/test/testroom.tscn'

func _signals():
	# Main Menu
	for lr in dir:
		for m in $org.get_node(lr).get_children():
			if m.get_class() == 'VBoxContainer':
				for i in m.get_children():
					if i.get_class() == 'Button':
#						i.connect('pressed', self, i.name+'_btn')
						i.connect('pressed', self, '_ui_btn_pressed', [i.get_name()])
					else:
						for l in i.get_children():
							#if i.name == 'cam_*':
							#	l.connect('pressed', $org/right/cam, '_'+i.name+'_'+l.name)
							if l.get_class() == 'Button':
#								l.connect('pressed', i, i.name+'_'+l.name)
								l.connect('pressed', self, '_ui_btn_pressed', [l.get_parent().get_name()])
							elif l.get_class() == 'OptionButton':
								l.get_popup().connect('id_pressed', i.get_parent(), '_'+i.get_name()+'_select')
							
	$org/right/cam/cam_x/btn.connect('pressed', $org/right/cam, '_cam_x_btn')
	$org/right/cam/cam_y/btn.connect('pressed', $org/right/cam, '_cam_y_btn')
	$org/right/cam/cam_x_spd/slide.connect('value_changed', $org/right/cam, '_set_sens', ['x'])
	$org/right/cam/cam_y_spd/slide.connect('value_changed', $org/right/cam, '_set_sens', ['y'])
	$org/right/cam/cam_mouse/slide.connect('value_changed', $org/right/cam, '_set_sens', ['m'])

func _ready():
#	Input.add_joy_mapping("030000005e040000ea02000008040000,Controller (Xbox One) - Wired,a:b0,b:b1,back:b6,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftshoulder:b4,leftstick:b8,lefttrigger:a2,leftx:a0,lefty:a1,rightshoulder:b5,rightstick:b9,righttrigger:a5,rightx:a3,righty:a4,start:b7,x:b2,y:b3,platform:Linux,",true)
#	print(get_children(),' , ',get_child_count())
	
	if get_parent().name == 'az':
		az = get_parent()
		bar = $org/right/hlth
		set_process(1)
		_gen_ui()
		envanim = get_parent().get_parent().get_node('env/AnimationPlayer')
		get_parent().set_physics_process(true)
		get_parent().get_node('cam').set_enabled(true)
	else:
		set_process(0)
		_main_menu()
		stage = ResourceLoader.load(test)
	_signals()


func _input(ev):
	var wait = 2
	var pause = ev.is_action_pressed('pause') && !ev.is_echo()
#	var btn
	
	if get_parent().get_name() == 'az':# && az.state != 1:
		if !paused && pause:
			_pause()
		elif paused && pause:
			_unpause()
	
	if ev.is_action_pressed('pause'):
		$timer.start()
	elif ev.is_action('pause') && !ev.is_pressed():
		$timer.stop()
	else:
		$timer.set_wait_time(wait)
	
	if Input.is_key_pressed(KEY_F11):
		OS.set_window_fullscreen(!OS.window_fullscreen)
	
	if ev is InputEventKey or ev is InputEventMouse:
		ev_mod = 0
	elif ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
		ev_mod = 1

func _main_menu():
	_populate($org/right/menuList)
	# Show/Hide Menu Items
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
	$org/right/langs.hide()
	$org/right/cam.hide()
	$org/right/dbg.hide()
	
	$org/left/dbg_print.hide()
	$org/left/over/thanks.hide()
	$org/left/over/rld.hide()
	$org/left/over/quit.hide()
	$org/left/over/site.hide()
	
	_grab_menu()

func _gen_ui():
	if az.request_ready() != true:
		pass
	else:
	#	max_hlth = az.max_hlth
		bar.max_value = az.max_hlth
		_updt_hlth(az.max_hlth)
		az.get_node('cam').set_enabled(true)
		$org/right/dbg.call_deferred('_dbg')
		
#	var menlist = ['dbg', 'opts' ,'rld', 'rsm', 'quit']
	
	$org/left/dbg_print.hide()
	$org/left/over.hide()
	
	$org/right/opts.hide()
	$org/right/disp.hide()
	$org/right/ctrls.hide()
	$org/right/langs.hide()
	$org/right/cam.hide()
	$org/right/dbg.hide()

	$org/right/menuList.hide()
	$org/right/version.hide()
	$org/right/menuList/dbg.show()
	$org/right/menuList/opts.show()
	$org/right/menuList.move_child(find_node('opts'),1)
	$org/right/menuList/contd.hide()
	$org/right/menuList/rld.show()
	$org/right/menuList/start.hide()
	$org/right/menuList/rsm.show()
	$org/right/menuList/quit.show()
	
	_grab_menu()

func _on_timer_timeout():
	get_tree().quit()

func _on_hlth_chng(hlth):
	_updt_hlth(hlth)

func _updt_hlth(new_val):
	$tween.interpolate_property(self, 'anim_hlth', anim_hlth, new_val, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if !$tween.is_active():
		$tween.start()

func _process(_delta):
	bar.value = anim_hlth

func _ld_cplt():
	stage = thread.wait_to_finish()
	global.load_scene(test)
