extends KinematicBody

# Signals
signal hlth_chng
signal died
signal az_ready
signal camadjust

# Health
export var max_hlth = 100
var hlth = max_hlth
var hlth_drain = true

onready var checkpt = $'/root/scene/chkpt'
onready var ui = $ui
onready var timer = $timer

# Environment
onready var g = ProjectSettings.get_setting("physics/3d/default_gravity")
var worldstate = ['phys','spi']

# Joystick Input
const DEADZONE = 0.3
const JOY_VAL = 0.9

#Movement
var ACCEL = 7.77
var DEACCEL = ACCEL * 2.13
const MAX_SLOPE = 57
export var run = 8.16
var fwalk = run / 2.25
var walk = run / 1.33
var dash = run * run #1.72 #2.12 #7.77
var mv = Vector2()
var mv_spd = run
var MAX_VEL = dash
#var turn_speed = 42
#var sharp_turn_threshold = 130
#var climbspeed = 2
onready var jmp_spd = g * 1.64
var velocity = Vector3()
var moving = false
var dashing = false
var can_wall = 1
var wrun = []
var dist = 4
var col_normal = Vector3()
var col_result = {}
var ledge_col = Vector3()
var ledge_diff : float

export var attempts = 1
#onready var col_feet = $col_feet

func _ready():
	connect('hlth_chng', ui, '_on_hlth_chng')
	connect('died', ui, '_over')
	connect('camadjust', $cam, 'cam_adjust' )
	
	if $cam.has_method('set_enabled'):
		$cam.set_enabled(true)
	
	$AnimationTree.active = 1
	
	chkpt()
	
	add_cols('left')
	add_cols('right')
	add_cols('front')
	add_cols('fcontact')
	add_cols('back')

func _input(event):
	mv.y = Input.get_action_strength('mv_f') - Input.get_action_strength('mv_b')
	mv.x = Input.get_action_strength('mv_r') - Input.get_action_strength('mv_l')

	if event == InputEventJoypadMotion:
		if (abs(mv.length()) < DEADZONE):
			mv = Vector2(0,0)
		else:
			mv = mv.normalized() * ((mv.length() - DEADZONE) / (1 - DEADZONE))
			if mv.length() >= DEADZONE && mv.length() <= JOY_VAL:
				mv_spd = walk

func _apply_gravity(delta,multiplier):
	if delta == 0:
		velocity.y = multiplier
	else:
		velocity.y -= (g * delta) * multiplier

func _move_floor(delta):
	var TARGET_MOD = (velocity.length() * 0.84) / 2 + 1
	
	# Velocity
	var dir = Vector3()
	var cam_xform = $cam/cam.get_global_transform()

	dir += -cam_xform.basis[2] * mv.y
	dir += cam_xform.basis[0] * mv.x
	
	if dir.length() != 0:
		moving = true
	else:
		moving = false

	var hspeed = Vector2(velocity.x, velocity.z).length()
	
	var hvel = velocity
	if is_on_floor():
		hvel.y = 0
		can_wall = 1
	
	var new_pos = dir * mv_spd
	
	if dir.dot(hvel) > 0:
		ACCEL = ACCEL
	else:
		ACCEL = DEACCEL
		
	hvel = hvel.linear_interpolate(new_pos, ACCEL * delta)
	
	velocity.x = hvel.x
	velocity.z = hvel.z
	
	$body/Skeleton/targets/ptarget.translation.z = TARGET_MOD

func _move_rotate():
	var hvel = velocity
	var angle = atan2(-hvel.x,-hvel.z)
	var char_rot = get_rotation()
	if moving:
		char_rot.y = angle
		rotation = char_rot

func _dodge():
	var roll_magnitude = 11.1
	velocity = (velocity - get_floor_normal()) * roll_magnitude

func _dash(toggle: bool):
	if toggle == true:
		if Vector2(velocity.x,velocity.z).length() <= MAX_VEL * 7:# - timer.get_wait_time()):
			velocity = (velocity - get_floor_normal()) * 1.3
#	dashing = false if dashing else true
			dashing = true
	else:
		dashing = false

func _apply_velocity():
	velocity = move_and_slide(velocity - get_floor_normal(), Vector3.UP)

func _increase_speed():
	MAX_VEL = MAX_VEL + 1

func _jump():
	velocity.y = jmp_spd

func _ppos():
	return $body/Skeleton.get_global_transform().origin

func _ptarget():
	return $body/Skeleton/targets/ptarget.get_global_transform().origin	

func _ledge_detect():
	var delta = _ppos() - _ptarget()
	var ledgecol = $body/Skeleton/targets/ledgecol.get_global_transform().origin
	var col_top = get_world().get_direct_space_state().intersect_ray(ledgecol,_ptarget() + delta, [self])
	
	if !col_top.empty():
		ledge_col = col_top.position
		ledge_diff = ledge_col.y - _ptarget().y
		$dbgtxt2.text = str('\nledge_col :', ledge_col.y, '\nledge diff :', ledge_diff)
	else:
		ledge_col = ledge_col
		ledge_diff = 20

func _ledge_calc():
	if ledge_col.y > 4.2 && ledge_diff < 2.1 && ledge_diff > -2.1:
		return true

func _ledge_grab():
	set_translation(Vector3(col_normal.x + ledge_col.x, ledge_col.y -2.6, col_normal.z + ledge_col.z))
	$FSM.state = $FSM.states.ledge

func _ledge_climb():
	set_translation(ledge_col)

func _walljump():
	velocity.y += jmp_spd
	can_wall = 0

func _wallrun():
	return null

func _wallrunjump():
	var walln = get_slide_collision(0).normal
#	var wrjmp = $body/Skeleton.get_transform().basis.xform(Vector3(jmp_spd * 4, jmp_spd * 4, jmp_spd * 4))
	var modlv = velocity.slide(Vector3.UP).slide(walln).abs()
#	velocity += modlv * wrjmp
	velocity += walln * modlv# * wrjmp
# https://godotengine.org/qa/27565/3d-directional-jumping

func walking(hspeed,delta):
	if Input.is_key_pressed(KEY_ALT):
		if (hspeed > walk ):
			mv_spd = max(min(mv_spd - (2 * delta),walk * 2.0),walk)
		elif (hspeed <= walk):
			mv_spd = walk
	else:
		mv_spd = max(min(mv_spd + (delta * 0.5),walk),run)

func animate_char(anim):
	$AnimationTree.set('parameters/state/current', anim)

func add_cols(new_col):
	col_result[new_col] = col_result.size()

func _parkour_sensor():
	var ds = get_world().get_direct_space_state()
	var delta = _ptarget() - _ppos()
	col_result.back = ds.intersect_ray(_ppos(),-_ptarget() + delta, [self])
	col_result.left = ds.intersect_ray(_ppos(), _ptarget() + Basis(Vector3.UP,deg2rad(90)).xform(delta), [self])
	col_result.right = ds.intersect_ray(_ppos(), _ptarget() + Basis(Vector3.UP,deg2rad(-90)).xform(delta), [self])
	col_result.front = ds.intersect_ray(_ppos(), _ptarget() + delta, [self])
	col_result.fcontact = ds.intersect_ray(_ppos(), _ptarget() + Vector3.UP, [col_result.front , self])
	col_result.lcontact = ds.intersect_ray(_ppos(), _ptarget() + Basis(Vector3.UP,deg2rad(90)).xform(delta/5), [col_result.left, self])
	col_result.rcontact = ds.intersect_ray(_ppos(), _ptarget() + Basis(Vector3.UP,deg2rad(-90)).xform(delta/5), [col_result.right, self])
	
	if !col_result.left.empty() && !col_result.lcontact.empty() && col_result.fcontact.empty():# && !col_f.empty() && col_r.empty():
#		col_normal = col_result.left.normal
		return col_result.left
	if !col_result.right.empty() && !col_result.rcontact.empty() && col_result.fcontact.empty():# && !col_f.empty() && col_l.empty()):
#		col_normal = col_result.right.normal
		return col_result.right
	if !col_result.front.empty() && col_result.fcontact.empty():# && col_l.empty() && col_r.empty()):
		col_normal = col_result.front.normal
		return col_result.front
	if !col_result.fcontact.empty():# && [col_l.empty(),col_r.empty()]:
		col_normal = col_result.fcontact.normal
		return col_result.fcontact
	if !col_result.back.empty():
#		col_normal = col_result.back.normal
		return col_result.back
	else:
		return null

func hlth_drn(dt):
	var div = 5
	var rnd = dt * div
	
	if hlth >= 0:
		if !worldstate[1]:
			hlth -= rnd / 10#(div * 10)
		elif worldstate[1]:
			hlth += rand_range(-rnd,rnd * (1.001 * 1.33))
		
		if Input.is_action_pressed('cast') && Input.is_action_just_pressed('arm_l'):
			hlth -= 7
	
		emit_signal('hlth_chng', hlth)

func heal(tch):
#	if state == states.GONE:
#		return
	hlth += tch

func dmg(hit):
#	if state == 1:
#		return
	hlth -= hit
	
	if hlth <= 0:
		hlth = 0
#		state = 1
#		shifter.state = 'dead'
		emit_signal('died')
	
		emit_signal('hlth_chng', hlth)

func chkpt():
	if get_parent().has_node('chkpt'):
		set_transform(checkpt.get_global_transform())

func _timer(time):
#	timer = Timer.new()
	timer.one_shot = true
	timer.start(time)

#func translateMove(distent):
#	var localTranslate = Vector3(0,0,distent)
#	translate(get_transform().basis.xform(localTranslate))
