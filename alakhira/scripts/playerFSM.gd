extends StateMachine

#var dash_toggle: bool = false

func _ready():
	add_state('idle')
	add_state('move')
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
#	add_state('alive')
#	add_state('dead')
#	add_state('gone')
	
	call_deferred('set_state', states.idle)

func _input(ev):

	parent.act = Input.is_action_pressed('act')
	parent.cast = Input.is_action_pressed('cast')
	
	"""if Input.is_key_pressed(KEY_F1):
		dash_toggle = false if dash_toggle else true
		print(dash_toggle)"""
	
	if parent.is_on_floor():
		parent.mv_z = Input.get_action_strength('mv_f') - Input.get_action_strength('mv_b')
		parent.mv_x = Input.get_action_strength('mv_r') - Input.get_action_strength('mv_l')
		if [states.idle,states.move, states.dash].has(state):
			if Input.is_action_just_pressed('act'):
				parent._dodge()
#			if !dash_toggle:
			if Input.is_action_pressed('act') && ev.is_echo():
				parent._dash(true)
			if Input.is_action_just_released('act'):
				parent._dash(false)
#			else:
#				if Input.is_action_just_pressed('act'):
#					parent._dash(false if true else false)
			if Input.is_action_just_released('feet'):
				parent._jump()
	
	if [states.wall].has(state):
		if Input.is_action_pressed('feet'):
			parent._walljump()
		if Input.is_action_pressed('act'):
			parent.rotate_y(179)
			parent.col_result = ['back']
	
	if [states.jump,states.fall,states.walljump].has(state):
		if parent.ledge_col.y > 4.2 && parent.ledge_diff < 2.1 && parent.ledge_diff > -2.1:
			if Input.is_action_pressed("arm_l"):
				parent._ledge_grab()

func _dbgtxt():
	parent.get_node('dbgtxt4').text = str('velocity.xz',Vector2(parent.velocity.x,parent.velocity.z).length(), '\nvelocity.y ',parent.velocity.y)
#	parent.get_node('dbgtxt5').text = str('timer ',parent.timer.is_stopped(), '\n', parent.timer.wait_time)
#	parent.get_node('dbgtxt').text = str("on ledge: ", parent.on_ledge).capitalize()
#	parent.get_node('dbgtxt').text = str(parent.col_result)
#	parent.get_node('dbgtxt').text = str(parent.timer.is_stopped())

func _state_logic(dt):
	parent._apply_velocity()
#	parent._apply_gravity(dt)
	if [states.move, states.move, states.jump, states.fall, states.walljump].has(state):
		parent.parkour_sensor()
	if [states.jump, states.fall, states.wall, states.walljump].has(state):
		parent._ledge_detect()
	if [states.wall, states.wallrun].has(state):# && parent.timer.wait_time != 0.0:
		parent._wallrun_gravity()
	if [states.ledge].has(state):
		parent._apply_gravity(0,0)
	else:
		parent._apply_gravity(dt,3.69)
		parent._move_floor(dt)
	
	_dbgtxt()

func _process(dt):
	if parent.hlth_drain != false:# && !states.dead and :
		parent.hlth_drn(dt)

func _get_transition(_dt):
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
			if !parent.moving:
				return states.idle
			if parent.dashing:
				return states.dash
		states.dash:
			if !parent.is_on_floor():
				if parent.velocity.y > 0:
					return states.jump
				elif parent.velocity.y < 0:
					return states.fall
			if !parent.dashing:
				return states.move
			if !parent.moving:
				return states.idle
		states.jump:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y <= 0:
				return states.fall
		states.fall:
			if parent.is_on_floor():
				return states.idle
			if parent.col_result == ['fcontact'] && parent.can_wall > 0 && parent.timer.is_stopped():
				return states.wall
		states.wall:
			if parent.is_on_floor():
				return states.idle
			if parent.col_result != ['fcontact'] || parent.timer.is_stopped():
				return states.fall
			if parent.velocity.y > 0:
				return states.walljump
		states.walljump:
#			parent.can_wall = 0
			if parent.velocity.y <= 0:
				return states.fall
		states.ledge:
			if parent.velocity.y < 0:
				return states.fall
			if Input.is_action_just_pressed('act'):
				return states.wall
			if Input.is_action_just_released('feet'):
				parent._ledge_climb()
				return states.idle
	return null

func _enter_state(new_state, _prev_state):
	match new_state:
		states.idle:
			parent.animate_char(0)
			parent.emit_signal('camadjust', 64, 4.2)
		states.move:
			parent.animate_char(2)
			parent.emit_signal("camadjust",64, 3.6)
		states.dash:
			parent.animate_char(3)
			parent.timer.start(3)
			parent.emit_signal('camadjust', 56, 4.2)
		states.jump:
			parent.animate_char(4)
			parent.emit_signal("camadjust",64, 4.2)
		states.fall:
			parent.animate_char(5)
			parent.emit_signal("camadjust",64, 4.2)
		states.wall:
			parent._timer(0.42)
			parent.animate_char(9)
		states.walljump:
			parent.animate_char(10)
		states.wallrun:
			parent.timer.start(parent.MAX_VEL/2)
		states.ledge:
			parent.animate_char(8)

	parent.get_node('dbgtxt').text = str('\n state ', states.keys()[new_state]).capitalize()

func _exit_state(prev_state,_new_state):
	match prev_state:
		states.wall:
			parent.can_wall = 0
