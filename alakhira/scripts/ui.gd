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
#	Input.add_joy_mapping("030000005e040000ea02000008040000,Controller (Xbox One) - Wired,a:b0,b:b1,back:b6,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftshoulder:b4,leftstick:b8,lefttrigger:a2,leftx:a0,lefty:a1,rightshoulder:b5,rightstick:b9,righttrigger:a5,rightx:a3,righty:a4,start:b7,x:b2,y:b3,platform:Linux,",true)
	
	if get_parent().name == 'az':
		get_parent().get_node('body/Skeleton/targets').set_visible(!$org/right/dbg.col_show)
		set_process(1)
		_updt_hlth(get_parent().max_hlth)
		_main_menu(['dbg', 'opts' ,'rld', 'rsm', 'quit'],['menuList','dbg','opts','langs','disp','ctrls','cam','version'])
		_hide_left()
		envanim = get_parent().get_parent().get_node('env/AnimationPlayer')
		get_parent().set_physics_process(true)
		get_parent().get_node('cam').set_enabled(true)
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
		elif get_tree().paused && ev.is_action_pressed('pause'):
			_unpause()
	
	if ev.is_action_pressed('pause')  && ev.is_echo():
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
