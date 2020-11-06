extends StateMachine

var dash_toggle: bool = false
var collisions = {}
var collision = null #setget set_collision

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
	collisions = parent.col_result

func _input(ev):

	parent.act = Input.is_action_pressed('act')
	parent.cast = Input.is_action_pressed('cast')
	
	if Input.is_key_pressed(KEY_1):
		dash_toggle = false if dash_toggle else true
		print(dash_toggle)
	
	if parent.is_on_floor():
		parent.mv_z = Input.get_action_strength('mv_f') - Input.get_action_strength('mv_b')
		parent.mv_x = Input.get_action_strength('mv_r') - Input.get_action_strength('mv_l')
		if [states.idle,states.move, states.dash].has(state):
			if Input.is_action_just_pressed('act'):
				parent._dodge()
			if !dash_toggle:
				if Input.is_action_pressed('act') && ev.is_echo():
					parent._dash(true)
				if Input.is_action_just_released('act'):
					parent._dash(false)
			else:
				if Input.is_action_just_pressed('act'):
					parent._dash(false if true else false)
			if Input.is_action_just_pressed('feet'):
				parent._jump()
	
	if [states.wall].has(state):
		if Input.is_action_pressed('feet'):
			parent._walljump()
		if Input.is_action_pressed('act'):
			parent.rotate_y(179)
			return collisions.back
	
	if [states.fall,states.walljump,states.jump].has(state):
		if Input.is_action_pressed("arm_l"):
			if parent.ledge_col.y > 4.2 && parent.ledge_diff < 2.1 && parent.ledge_diff > -2.1:
				parent._ledge_grab()

func _dbgtxt():
	parent.get_node('dbgtxt4').text = str('velocity.xz',Vector2(parent.velocity.x,parent.velocity.z).length(), '\nvelocity.y ',parent.velocity.y)
	parent.get_node('dbgtxt2').text = str('collision ',collision,'\nhas collision ',[collisions.left,collisions.right,collisions.fcontact].has(collision))
#	parent.get_node('dbgtxt5').text = str('timer ',parent.timer.is_stopped(), '\n', parent.timer.wait_time)
#	parent.get_node('dbgtxt').text = str("on ledge: ", parent.on_ledge).capitalize()
#	parent.get_node('dbgtxt').text = str(collision)
#	parent.get_node('dbgtxt').text = str(parent.timer.is_stopped())

func _state_logic(dt):
	var ds = parent.get_world().get_direct_space_state()
	parent._apply_velocity()
		
	if [states.move, states.dash, states.jump, states.fall, states.walljump,states.wallrun].has(state):
		parent._parkour_sensor(ds)
	if [states.move,states.dash].has(state):
		parent._move_rotate()
	if [states.jump, states.fall, states.wall, states.walljump].has(state):
		parent._ledge_detect()
	if [states.wall, states.wallrun].has(state):
		parent._apply_gravity(0.00000096, 0)
	if [states.ledge].has(state):
		parent._apply_gravity(0,0)
	else:
		parent._apply_gravity(dt,3.69)
		parent._move_floor(dt)

	collision = parent._parkour_sensor(ds)
	
	_dbgtxt()

func _process(dt):
	if parent.hlth_drain != false:
		parent.hlth_drn(dt)

func _get_transition(_dt):
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent.velocity.y > 0:
					return states.jump
				else:
					return states.fall
			if parent.moving == true:
				return states.move
		states.move:
			if !parent.is_on_floor():
				if parent.velocity.y > 0:
					return states.jump
				else:
					return states.fall
			if !parent.moving:
				return states.idle
			if parent.dashing:
				return states.dash
		states.dash:
			if !parent.is_on_floor():
				if parent.velocity.y > 0:
					return states.jump
				else:
					return states.fall
			if !parent.dashing:
				return states.move
			if !parent.moving:
				return states.idle
		states.jump:
			if parent.velocity.y <= 0:
				return states.fall
		states.fall:
			if parent.is_on_floor():
				return states.idle
			if [collisions.left,collisions.right].has(collision):# && !['fcontact'].has(collision):
				return states.wall
			if [collisions.fcontact].has(collision) && parent.can_wall > 0:
				return states.wall
		states.wall:
			if [collisions.left,collisions.right].has(collision):# && !['fcontact'].has(collision):
				return states.wallrun
			if ![collisions.fcontact].has(collision) || parent.timer.is_stopped():
				return states.fall
			if parent.velocity.y > 0:
				return states.walljump
		states.walljump:
#			parent.can_wall = 0
			if parent.velocity.y <= 0:
				return states.fall
		states.wallrun:
			if parent.velocity.y <= -9.8*2:
				return states.fall
			if ['fcontact'].has(collision):
				return states.wall
			if parent.is_on_floor():
				return states.idle
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
			parent.emit_signal('camadjust', 48, 4.2)
		states.move:
			parent.animate_char(2)
			parent.emit_signal("camadjust",64, 3.6)
		states.dash:
			parent.animate_char(3)
			parent.timer.start(3)
			parent.emit_signal('camadjust', 60, 4.2)
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
		states.wallrun:
			parent.can_wall = 0
