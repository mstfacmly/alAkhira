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
#						i.connect('pressed', i, i.name+'_btn')
						i.connect('pressed', self, '_ui_btn_pressed', [i])
					else:
						for l in i.get_children():
							#if i.name == 'cam_'+['x','y']:
							#	l.connect('pressed', $org/right/cam, '_'+i.name+'_'+l.name)
							if l.get_class() == 'Button':
#								l.connect('pressed', i, i.name+'_'+l.name)
								l.connect('pressed', self, '_ui_btn_pressed', [l.get_parent()])
							elif l.get_class() == 'OptionButton':
								l.get_popup().connect('id_pressed', i.get_parent(), '_'+i.name+'_select')
							
	$org/right/cam/cam_spd/js_x/slide.connect('value_changed', $org/right/cam, '_set_sens_x')
	$org/right/cam/cam_spd/js_y/slide.connect('value_changed', $org/right/cam, '_set_sens_y')
	$org/right/cam/cam_spd/mouse/slide.connect('value_changed', $org/right/cam, '_set_sens_mouse')

func _ready():
	var scene_dict = {}
	env =  get_tree().current_scene.find_node('WorldEnv')
	if env != null:
		for i in env.environment.get_property_list():
			scene_dict[i] = scene_dict.size()
	
	if get_tree().current_scene.has_node('az'):
		_main_menu(['dbg', 'opts' ,'rld', 'rsm', 'quit'],['menuList','dbg','opts','langs','disp','ctrls','cam','version'])
		_hide_left()
		set_process(1)
		get_tree().current_scene.find_node('az').get_node('body/Skeleton/targets').set_visible(!$org/right/dbg.col_show)
		_update_health(get_tree().current_scene.find_node('az').max_hlth)
		get_tree().current_scene.find_node('az').set_physics_process(true)
		$org/right/dbg.call_deferred('_dbg')
	else:
		set_process(0)
		_main_menu(['start','opts','quit'],['dbg','opts','langs','disp','ctrls','cam','hlth'])
		_hide_left()
		stage = ResourceLoader.load(test)
	_signals()

func _input(ev):
	var wait = 2
	
	if get_parent().name == 'az':# && az.state != 1:
		if !get_tree().paused && ev.is_action_pressed('pause'):
			_pause_menu(0)
			_pause_shift(env, 0.5,0,0.11,0.33)
		elif get_tree().paused && ev.is_action_pressed('pause'):
			_unpause()
			_pause_shift(env,1,1,0,0.11)
	
	if ev.is_action_pressed('pause')  && ev.is_echo():
		$timer.start()
	else:
		$timer.stop()
		$timer.set_wait_time(wait)
	
	if Input.is_key_pressed(KEY_F11):
		OS.set_window_fullscreen(!OS.window_fullscreen)

func _on_timer_timeout():
	get_tree().quit()

func _on_hlth_chng(hlth):
	_update_health(hlth)

func _update_health(new_val):
	$org/right/hlth.max_value = new_val
	$tween.interpolate_property(self, 'anim_hlth', anim_hlth, new_val, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if !$tween.is_active():
		$tween.start()

func _process(_delta):
	$org/right/hlth.value = anim_hlth

func _load_complete():
#	stage = thread.wait_to_finish()
	global.load_scene(test)

