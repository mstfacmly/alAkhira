extends 'res://scripts/ui_core.gd'

export (String, FILE) var test = 'res://env/test/testroom.tscn'

func _signals():
	# Main Menu
	for lr in dir:
		for m in $org.get_node(lr).get_children():
			if m.get_class() == 'VBoxContainer':
				for i in m.get_children():
					if i.get_class() == 'Button':
						i.connect('pressed', self, '_ui_btn_pressed', [i.get_name()])
					else:
						for l in i.get_children():
							if l.get_class() == 'Button':
								l.connect('pressed', self, '_ui_btn_pressed', [l.get_parent().get_name()])
							elif l.get_class() == 'OptionButton':
								l.get_popup().connect('id_pressed', i.get_parent(), '_'+i.get_name()+'_select')
							
	$org/right/cam/cam_x/btn.connect('pressed', $org/right/cam, '_cam_btn', ['x'])
	$org/right/cam/cam_y/btn.connect('pressed', $org/right/cam, '_cam_btn', ['y'])
	$org/right/cam/cam_x_spd/slide.connect('value_changed', $org/right/cam, '_set_sens', ['x'])
	$org/right/cam/cam_y_spd/slide.connect('value_changed', $org/right/cam, '_set_sens', ['y'])
	$org/right/cam/cam_mouse/slide.connect('value_changed', $org/right/cam, '_set_sens', ['m'])

func _ready():
	bar = $org/right/hlth
	tween = $tween
	t = $timer
	
#	shifter.curr
	_signals()
	
	if get_parent().get_name() == 'az':
		az = get_parent()
		_gen_ui()
		envanim = az.get_parent().get_node('env/AnimationPlayer')
		az.set_physics_process(true)
		az.get_node('cam').set_enabled(true)
	else:
		_main_menu()
		stage = ResourceLoader.load(test)

func _input(ev):
	var wait = 2
	var timer = t.set_wait_time(wait)
	var pause = ev.is_action_pressed('pause') && !ev.is_echo()
	var btn
	
	if get_parent().get_name() == 'az':# && az.state != 1:
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
	
	if ev is InputEventKey or ev is InputEventMouse:
		ev_mod = 0
	elif ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
		ev_mod = 1

func _main_menu():
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
	
	$org/left/dbg.hide()
	$org/left/over/thanks.hide()
	$org/left/over/rld.hide()
	$org/left/over/quit.hide()
	$org/left/over/site.hide()
	
	_grab_menu()

func _gen_ui():
	if az.request_ready() != true:
		pass
	else:
		max_hlth = az.max_hlth
		bar.max_value = max_hlth
		_updt_hlth(max_hlth)
		az.get_node('cam').set_enabled(true)
		$org/right/dbg.call_deferred('_dbg')
		
	var menlist = ['dbg', 'opts' ,'rld', 'rsm', 'quit']
	
	$org/left/dbg.hide()
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
	tween.interpolate_property(self, 'anim_hlth', anim_hlth, new_val, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if !tween.is_active():
		tween.start()

func _process(delta):
	bar.value = anim_hlth

func _ld_cplt():
	stage = thread.wait_to_finish()
	global.load_scene(test)
