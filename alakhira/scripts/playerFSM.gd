extends StateMachine

func _ready():
	add_state('idle')
	add_state('move')
#	add_state('run')
#	add_state('sprint')
	add_state('dash')
	add_state('jump')
	add_state('fall')
	add_state('wall')
	add_state('wallrun')
#	add_state('land')
#	add_state('parry')
#	add_state('block')
	add_state('alive')
	add_state('dead')
	add_state('gone')
	
	call_deferred('set_state', states.idle)

func _input(ev):
	parent.get_node('inputtext').text = str(ev.as_text())
	parent.act = Input.is_action_just_pressed('act')
	parent.cast = Input.is_action_pressed('cast')
	
	if parent.is_on_floor():
		parent.get_node('statetext').text = str(parent.is_on_floor())
		parent.mv_z = Input.get_action_strength('mv_f') - Input.get_action_strength('mv_b')
		parent.mv_x = Input.get_action_strength('mv_r') - Input.get_action_strength('mv_l')
		if [states.idle,states.move].has(state):
			if ev.is_action_pressed('feet'):
				parent._jump()

func _state_logic(dt):
#	parent._move_input()
	parent._apply_gravity(dt)
	parent._move_floor(dt)
	parent.get_node('veltext').text = str(parent.velocity)

func _get_transition(dt):
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			#if parent._move_floor(dt):
			#	return states.move
			if parent.moving == true:
				return states.move
		states.move:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
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
			elif parent.velocity.y > 0:
				return states.jump
	return null

func _enter_state(new_state, prev_state):
	match new_state:
		states.idle:
			parent.animate_char(0)
		states.move:
			parent.animate_char(2)
		states.jump:
			parent.animate_char(4)

	parent.get_node('statetext').text = str(state)

func _exit_state(prev_state,new_state):
	pass
