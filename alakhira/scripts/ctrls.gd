extends "res://scripts/ui_core.gd"

func _input(ev):
	var ev_mod
	ev_mod = 1 if ev == InputEventJoypadButton || ev == InputEventJoypadMotion else 0

	var button
	for acts in INPUT_CFG:
		var input_ev = InputMap.get_action_list(acts)[ev_mod]
		button = get_node(acts).get_node('btn')
		if input_ev is InputEventJoypadButton || input_ev is InputEventJoypadMotion:
			button.set_text(Input.get_joy_button_string(input_ev.button_index))
			button.set_text(Input.get_joy_axis_string(input_ev.axis))
		elif input_ev is InputEventKey || input_ev is InputEventMouse:
			button.set_text(OS.get_scancode_string(input_ev.scancode))# + ' , ' + str(InputEventMouseButton.get_button_index()))

#	if  !button.is_connected('pressed', self, '_get_input'):
#		button.connect('pressed', self, '_get_input', [acts])

	"""if ev.is_action_pressed('ui_cancel'):
		if back != null:
			if back.call_func() == '_main_menu' or back.call_func() == '_pause_menu':
				pass
			else:
				accept_event()
				$org/right/opts._opts_menu()"""
		
#	if ev is InputEventKey:
#		get_tree().set_input_as_handled()
#		set_process_input(false)
#		if !ev.is_action('ui_cancel'):
#			var scancode = OS.get_scancode_string(ev.scancode)
#			btn.text = scancode
#			for old_ev in InputMap.get_action_list(acts):
#				InputMap.action_erase_event(acts, old_ev)
#			InputMap.action_add_event(acts, ev)
#			_save_cfg('input', acts, scancode)


func _ready():
#	Input.add_joy_mapping("030000005e040000ea02000008040000,Controller (Xbox One) - Wired,a:b0,b:b1,back:b6,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftshoulder:b4,leftstick:b8,lefttrigger:a2,leftx:a0,lefty:a1,rightshoulder:b5,rightstick:b9,righttrigger:a5,rightx:a3,righty:a4,start:b7,x:b2,y:b3,platform:Linux,",true)
	INPUT_CFG = [
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
