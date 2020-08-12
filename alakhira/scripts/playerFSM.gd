extends StateMachine

func _ready():
	parent.get_node('timer').start(0.2)
	add_state('idle')
	add_state('move')
#	add_state('run')
#	add_state('sprint')
	add_state('dash')
	add_state('jump')
	add_state('fall')
	add_state('ledge')
	add_state('wall')
	add_state('walljump')
	add_state('wallrun')
#	add_state('land')
#	add_state('parry')
#	add_state('block')
	add_state('alive')
	add_state('dead')
	add_state('gone')
	
	call_deferred('set_state', states.idle)

func _input(ev):
#	parent.get_node('inputtext').text = str(Input)
	
	parent.act = Input.is_action_just_pressed('act')
	parent.cast = Input.is_action_pressed('cast')
	
	if parent.is_on_floor():
		parent.mv_z = Input.get_action_strength('mv_f') - Input.get_action_strength('mv_b')
		parent.mv_x = Input.get_action_strength('mv_r') - Input.get_action_strength('mv_l')
		if [states.idle,states.move].has(state):
			if Input.is_action_just_released('feet'):
				parent._jump()
	if [states.wall].has(state):
		if Input.is_action_just_pressed('feet'):
			parent._walljump()
		if Input.is_action_pressed("act"):
			parent.rotate_y(179)

func _dbgtxt():
	parent.get_node('veltext').text = str(parent.velocity.y)
#	parent.get_node('inputtext').text = str("on ledge: ", parent.on_ledge).capitalize()
#	parent.get_node('inputtext').text = str(parent.col_result)
#	parent.get_node('inputtext').text = str(parent.get_node('timer').is_stopped())
	

func _state_logic(dt):
	parent._apply_velocity()
#	parent._apply_gravity(dt)
	if [states.move, states.jump, states.fall, states.walljump].has(state):
		parent.parkour_sensor()
		parent._ledge_detect()
	if [states.wall, states.wallrun].has(state):# && parent.get_node('timer').wait_time != 0.0:
		parent._wallrun_gravity()
	else:
		parent._apply_gravity(dt)
		parent._move_floor(dt)
		
	_dbgtxt()

func set_fall():
	return states.fall

func _get_transition(dt):
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent.velocity.y > 0:
					return states.jump
				elif parent.velocity.y < 0:
					return states.fall
			if parent.moving == true:
				return states.move
		states.move:
			if !parent.is_on_floor():
				if parent.velocity.y > 0:
					return states.jump
				elif parent.velocity.y < 0:
					return states.fall
			if parent.moving == false:
				return states.idle
		states.jump:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y <= 0:
				return states.fall
		states.fall:
			if parent.is_on_floor():
				return states.idle
			if parent.col_result == ['fcontact'] && parent.can_wall >= 0:
				return states.wall
		states.wall:
			if parent.is_on_floor():
				return states.idle
			if parent.col_result != ['fcontact']:
				return states.fall
			if parent.velocity.y > 0:
				return states.walljump
		states.walljump:
			if parent.velocity.y <= 0:
				return states.fall
	return null

func _enter_state(new_state, prev_state):
	match new_state:
		states.idle:
			parent.animate_char(0)
			parent.emit_signal('camadjust', 48, 4.2)
		states.move:
			parent.animate_char(2)
			parent.emit_signal("camadjust",64, 3.1)
		states.jump:
			parent.animate_char(4)
			parent.emit_signal("camadjust",64, 3.1)
		states.fall:
			parent.animate_char(5)
			parent.emit_signal("camadjust",68, 3.6)
		states.wall:
			parent.animate_char(9)
		states.walljump:
			parent.animate_char(10)

	parent.get_node('statetext').text = states.keys()[new_state].capitalize()

func _exit_state(prev_state,new_state):
	pass
