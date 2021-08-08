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
						i.connect('pressed', self, '_ui_btn_pressed', [i])
					else:
						for l in i.get_children():
							#if i.name == 'cam_*':
							#	l.connect('pressed', $org/right/cam, '_'+i.name+'_'+l.name)
							if l.get_class() == 'Button':
#								l.connect('pressed', i, i.name+'_'+l.name)
								l.connect('pressed', self, '_ui_btn_pressed', [l.get_parent()])
							elif l.get_class() == 'OptionButton':
								l.get_popup().connect('id_pressed', i.get_parent(), '_'+i.name+'_select')
							
	$org/right/cam/cam_x/btn.connect('pressed', $org/right/cam, '_cam_x_btn')
	$org/right/cam/cam_y/btn.connect('pressed', $org/right/cam, '_cam_y_btn')
	$org/right/cam/cam_x_spd/slide.connect('value_changed', $org/right/cam, '_set_sens', ['x'])
	$org/right/cam/cam_y_spd/slide.connect('value_changed', $org/right/cam, '_set_sens', ['y'])
	$org/right/cam/cam_mouse/slide.connect('value_changed', $org/right/cam, '_set_sens', ['m'])

func _ready():
#	Input.add_joy_mapping("030000005e040000ea02000008040000,Controller (Xbox One) - Wired,a:b0,b:b1,back:b6,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftshoulder:b4,leftstick:b8,lefttrigger:a2,leftx:a0,lefty:a1,rightshoulder:b5,rightstick:b9,righttrigger:a5,rightx:a3,righty:a4,start:b7,x:b2,y:b3,platform:Linux,",true)
#	print(get_children(),' , ',get_child_count())
	
	if get_parent().name == 'az':
#		az = get_parent()
#		bar = $org/right/hlth
		set_process(1)
		_gen_ui(['dbg', 'opts' ,'rld', 'rsm', 'quit'],['dbg','opts','langs','disp','ctrls','cam','hlth'])
		envanim = get_parent().get_parent().get_node('env/AnimationPlayer')
		get_parent().set_physics_process(true)
		get_parent().get_node('cam').set_enabled(true)
	else:
		set_process(0)
		_main_menu(['start','opts','quit'],['dbg','opts','langs','disp','ctrls','cam','hlth'])
		stage = ResourceLoader.load(test)
	_signals()

func _input(ev):
	var wait = 2
	var pause = ev.is_action_pressed('pause') && !ev.is_echo()
#	var btn
	
	if get_parent().name == 'az':# && az.state != 1:
		if !paused && pause:
			_pause()
		elif paused && pause:
			_unpause()
	
	if ev.is_action_pressed('pause'):
		$timer.start()
	else:
		$timer.stop()
		$timer.set_wait_time(wait)
	
	if Input.is_key_pressed(KEY_F11):
		OS.set_window_fullscreen(!OS.window_fullscreen)
	
	if ev is InputEventKey or ev is InputEventMouse:
		ev_mod = 0
	elif ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
		ev_mod = 1

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
	
	_hide_left()
	_grab_menu()

func _gen_ui(show,hide):
	_updt_hlth(get_parent().max_hlth)
	get_parent().get_node('cam').set_enabled(1)
	$org/right/dbg.call_deferred('_dbg')
	
	for i in $org/right/menuList.get_children():
		if !show.has(i.name):
			i.hide()
		else:
			i.show()

	$org/right/menuList.move_child(find_node('opts'),1)
	$org/right/menuList.hide()
	
	for i in $org/right.get_children():
		if hide.has(i.name):
			i.hide()
	_hide_left()	
	_grab_menu()

func _hide_left():
	$org/left/dbg_print.hide()
	$org/left/over.hide()

func _on_timer_timeout():
	get_tree().quit()

func _on_hlth_chng(hlth):
	_updt_hlth(hlth)

func _updt_hlth(new_val):
	$org/right/hlth.max_value = new_val
	$tween.interpolate_property(self, 'anim_hlth', anim_hlth, new_val, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if !$tween.is_active():
		$tween.start()

func _process(_delta):
	$org/right/hlth.value = anim_hlth

func _ld_cplt():
	stage = thread.wait_to_finish()
	global.load_scene(test)
