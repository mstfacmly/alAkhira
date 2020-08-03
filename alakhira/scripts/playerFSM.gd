extends 'res://scripts/StateMachine.gd'

func _ready():
	add_state('alive')
	add_state('dead')
	add_state('gone')
	add_state('idle')
	add_state('move')
#	add_state('run')
#	add_state('sprint')
	add_state('dash')
	add_state('jump')
	add_state('wall')
	add_state('wallrun')
	add_state('fall')
	add_state('land')
	add_state('parry')
	add_state('block')
	
#	print(states.keys())
	call_deferred('set_state', states.idle)

func _input(ev):
	parent.act = Input.is_action_just_pressed('act')
	parent.cast = Input.is_action_pressed('cast')

	if parent.is_on_floor():
		if [states.idle,states.move,states.dash].has(state):
			if ev.is_action_pressed('feet'):
				parent.jump()
				_enter_state('jump', state)

func _state_logic(dt):
#	parent._move_input()
	parent._apply_gravity(dt)
	parent._move_floor(dt)

func _get_transition(dt):
	return null

func _enter_state(new_state, prev_state):
	pass

func _exit_state(prev_state,new_state):
	pass
