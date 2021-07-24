extends "res://scripts/ui_core.gd"

func _input(ev):
#	for i in InputMap.get_actions():
#		INPUT_CFG.append(i)
	var button
	for acts in INPUT_CFG:
		var input_ev = InputMap.get_action_list(acts)[ev_mod]
		button = get_node(acts).get_node('btn')
		if input_ev is InputEventJoypadButton || input_ev is InputEventJoypadMotion:
			button.set_text(Input.get_joy_button_string(input_ev.button_index))
			button.set_text(Input.get_joy_axis_string(input_ev.axis))
		elif input_ev is InputEventKey || input_ev is InputEventMouse:
			button.set_text(OS.get_scancode_string(input_ev.scancode))# + ' , ' + str(InputEventMouseButton.get_button_index()))

	if  button.is_connected('pressed', self, '_get_input') != true:
		button.connect('pressed', self, '_get_input', [acts])
	else:
		pass

	if ev.is_action_pressed('ui_cancel'):
		if back != null:
			if back.call_func() == '_main_menu' or back.call_func() == '_pause_menu':
				pass
			else:
				accept_event()
				_opts_menu()
		
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
