extends KinematicBody

# Signals
signal hlth_chng
signal died
signal az_ready
#signal peek
#signal shifting

# Health
export var max_hlth = 100
var hlth = max_hlth
var hlth_drn = true

onready var chkpt = $'/root/scene/chkpt'
onready var ui = $ui
onready var shifter = $scripts/shift

# Environment
var g = Vector3(0,-9.8,0)
var up = -g.normalized()
var lv = Vector3()

var joy_vec
const DEADZONE = 0.3
const JOY_VAL = 0.9

# Camera
var view_sensitivity = 0.2
var focus_view_sensv = 0.1
onready var cam = $cam
onready var cam_node = $cam/cam
signal camadjust

# Input
var jmp_att
#var hop_att
var act
var cast

#Movement
var ppos
#var lin_vel = Vector3()
const ACCEL = 7.77
const DEACCEL = ACCEL * 2.13
const MAX_SLOPE = 57
export var run = 6.16
var fwalk = run / 2.25
var walk = run / 1.33
var sprint = run * 1.72 #2.12 #7.77
#var mv_dir = Vector3()
var mv_z
var mv_x
var mv_spd = run
#var turn_speed = 42
#var sharp_turn_threshold = 130
#var climbspeed = 2
var jmp_spd = 9.8 * 1.984 
var velocity = Vector3()
#var hspeed
#var parkour_f = false
var jumping = false
var falling = false
#var vvel
#var can_wrun
var wrun = []
var dist = 4
var collision_exception = [ self ]
var col_normal = Vector3()
var col_result = []
var ledge_col = Vector3()
var on_ledge = false

var result
export var attempts = 1
onready var mesh = $body/Skeleton
var walln
var modlv
#onready var col_feet = $col_feet

func _ready():
	connect('hlth_chng', ui, '_on_hlth_chng')
	connect('died', ui, '_over')
	connect('camadjust', cam, 'cam_adjust' )
		
	#shifter.state = 'dead'
	
	if cam.has_method('set_enabled'):
		cam.set_enabled(true)
	
	$AnimationTree.active = 1
	
	chkpt()

func _input(event):
	mv_z = Input.get_action_strength('mv_f') - Input.get_action_strength('mv_b')
	mv_x = Input.get_action_strength('mv_r') - Input.get_action_strength('mv_l')

#func js_input(delta):
#	joy_vec = Vector2(Input.get_joy_axis(0,0), Input.get_joy_axis(0,1))
#
#	if (abs(joy_vec.length()) < DEADZONE):
#		joy_vec = 0
#	else:
#		joy_vec = joy_vec.normalized() * ((joy_vec.length() - DEADZONE) / (1 - DEADZONE))
#		if joy_vec.length() >= DEADZONE && joy_vec.length() <= JOY_VAL:
#			mv_spd = walk

func _apply_gravity(delta):
	lv += g * (delta * 3)
	velocity.y = up.dot(lv)
#	var hvcalc = lv - up * velocity.y
#	hvel = Vector3(hvcalc.x, 0 ,hvcalc.z)

func _physics_process(delta):
	if !$FSM.states.dead and hlth_drn != false:
		hlth_drn(delta)

func _move_floor(delta):
	# Velocity
	var dir = Vector3()
	var cam_xform = cam_node.get_global_transform()
	var moving = false

	dir += -cam_xform.basis[2] * mv_z
	dir += cam_xform.basis[0] * mv_x
	
	if dir.length() != 0:
		moving = true

	var hspeed = velocity.length()
	
	ppos = mesh.get_global_transform().origin
	var hvel = velocity
	hvel.y = 0
	
	var new_pos = dir * mv_spd
	
	if dir.dot(hvel) > 0:
		ACCEL
		
	hvel = hvel.linear_interpolate(new_pos, ACCEL * delta)
	
	velocity.x = hvel.x
	velocity.z = hvel.z
	
	velocity = move_and_slide(velocity - get_floor_normal(), Vector3.UP)
	
	if moving:
		var angle = atan2(-hvel.x,-hvel.z)
		var char_rot = get_rotation()
		char_rot.y = angle
		rotation = char_rot

func jump():
	velocity.y = jmp_spd * 2
	
	if mv_spd >= run :
		animate_char(6)
	else:
		animate_char(4)
#	can_wrun = true
#	lv = (velocity * 11.1) + up * velocity.y

#	if is_on_floor() && mv_spd >= run && jmp_att:
#		lv = (hvel * 11.1) + up * vvel
#	else:
#		lv = hvel + up * vvel

func wallrunning(ppos,ptarget,hspeed):
#	col_feet.set_rotation_degrees(mesh.get_rotation_degrees())
	parkour(ppos,ptarget,ptarget - ppos)
#	ledge(ptarget, ptarget - ppos)
	if hspeed >= walk -1:
		if col_result == ['front']:
			wrun = ['vert']
		elif col_result == ['left'] or col_result == ['right']:# && hspeed > walk:
			wrun = ['horz']
		else:
			col_result == []
			wrun = []

func fall(lv):
	jumping = false
	lv = velocity + up * velocity.y

	if mv_spd >= run:# - 1:
		animate_char(7)
	else:
		animate_char(5)

func _walljump():
#	elif is_on_wall() && jmp_att:
#		jumping = true
	pass

func _wall(ptarget,mesh_xform,delta):
#	var wjmp = jmp_spd + (hvel)# * 0.5)
	var ledge_diff = ledge_col.y - ptarget.y
	var TARGET_MOD = (velocity.length() * 0.84) / 2 + 1
	
	$body/Skeleton/targets/ptarget.translation.z = 0
	walln = get_slide_collision(0).normal.abs()
	modlv = lv.slide(up).slide(walln).abs()
	var whop = mesh_xform.basis.xform(Vector3(jmp_spd.y * 0.01, ((jmp_spd.y + velocity.length())) * 0.64, jmp_spd.y * 0))
	var wjmp = mesh_xform.basis.xform(Vector3(jmp_spd.y * 6, jmp_spd.y , jmp_spd.y * 6))
	
	ledge(ptarget, ptarget - ppos)
	lv.y = 0.0000001
	if col_result == ['front']:
		animate_char(9)
		#if !jmp_att :
		if jmp_att && attempts > 0:
			lv += whop * mv_spd * 0.48
			attempts -= 1
		if act:
			mesh.rotate_y(179)
			col_result = ['back']

	if col_result == ['back']:
		animate_char(8)
#				wrun = ['vert']
#	if !jmp_att :
#		lv = Vector3(0,0.0000001,0)
		if jmp_att:
			animate_char(7)
			lv += -walln * wjmp
			lv += up * wjmp
			attempts = 1
	
	print('ledge_diff: ', ledge_diff)
	if ledge_col.y > 3.33 && ledge_diff < 2.1 && ledge_diff > -4.4:
		global_translate(ledge_col - (ledge_col) + Vector3(0,0.1,0))# - facing_mesh.slide(Vector3(0,-1.2,0)))
		on_ledge = true
		animate_char(7)
#		else:
#			on_ledge = false
#				!is_on_wall()
	if on_ledge:
		if col_result == ['front']:
			wrun = []
			lv = mesh_xform.basis.xform(Vector3(0,0,0))
			if jmp_att:
				on_ledge = false
				translate(mesh_xform.basis.xform(Vector3(-0.91,3.36,0)))
			if act:
				mesh.rotate(up, 185)
				on_ledge = false
		else:
			!on_ledge
	else:
		lv += g * (delta *3)
	
	$body/Skeleton/targets/ptarget.translation.z = TARGET_MOD

func _wrun(mesh_xform,delta):
	var wrjmp = mesh_xform.basis.xform(Vector3(jmp_spd.y * 3, jmp_spd.y, jmp_spd.y * 3))
	if wrun == ['horz']:
		lv += modlv * 0.33
#			if can_wrun:
		lv.y -= lv.y + delta/(delta * 1.11)# * 0.9
		if col_result == ['right']:
			animate_char(11)
			lv += -modlv * 0.33
			if jmp_att:
				lv += (-walln / 2) * wrjmp
				lv += -modlv * wrjmp
				lv += up * wrjmp
		if col_result == ['left']:
			animate_char(10)
			lv += -modlv * 0.33
			if jmp_att:
				lv += (walln / 2) * wrjmp
				lv += -modlv * wrjmp
				lv += up * wrjmp
#			else:
#				wjmp = false
#	elif !wjmp:
#		lv.y += g.y * (delta *3)
#	elif !is_on_wall():
#		!on_ledge
	
#	player_fp(delta, hspeed)

func walk(hspeed,delta):
	if Input.is_key_pressed(KEY_ALT):
		if (hspeed > walk ):
			mv_spd = max(min(mv_spd - (2 * delta),walk * 2.0),walk)
		elif (hspeed <= walk):
			mv_spd = walk
	else:
		mv_spd = max(min(mv_spd + (delta * 0.5),walk),run)

	animate_char(1)
	emit_signal("camadjust",64, 3.1)

func idle():
	animate_char(0)

func animate_char(anim):
	$AnimationTree.set('parameters/state/current', anim)

func parkour(ppos,ptarget,delta):
	var ds = get_world().get_direct_space_state()
	var parkour_detect = 90

	var col_r = ds.intersect_ray(ppos,ptarget+Basis(up,deg2rad(parkour_detect)).xform(delta),collision_exception)
	var col_f = ds.intersect_ray(ppos,ptarget+delta,collision_exception)
	var col_l = ds.intersect_ray(ppos,ptarget+Basis(up,deg2rad(-parkour_detect)).xform(delta),collision_exception)
	var col_b = ds.intersect_ray(ppos,-ptarget + delta,collision_exception)

	if (!col_f.empty() && !col_l.empty() && col_r.empty()):
		col_normal = col_l.normal
		col_result = ['left']
		return col_result
	elif (!col_f.empty() && !col_r.empty() && col_l.empty()):
		col_normal = col_r.normal
		col_result = ['right']
		return col_result
	elif (!col_f.empty()): # && col_left.empty() && col_right.empty()):
		col_normal = col_f.normal
		col_result = ['front']
		return col_result
	elif (!col_b.empty()):
		col_normal = col_b.normal
		col_result = ['back']
		return col_result
	else:
		col_normal = Vector3()
		col_result = []
		return col_result

func ledge(ptarget, delta):
	var ledgecol = $body/Skeleton/targets/ledgecol.get_global_transform()
	var ds = get_world().get_direct_space_state()
	
	if col_result == ['front']:
		var col_top = ds.intersect_ray(ledgecol.origin,ptarget + delta,collision_exception)
		if !col_top.empty():
			ledge_col = Vector3(0,col_top.position.y,0)
			return ledge_col
			ledgecol.translate(ledge_col)
	elif col_result.empty():
		ledgecol.translated(Vector3(-0, 5.5,3))
		ledge_col = Vector3()
		return ledge_col
	else:
		ledge_col = Vector3()
		return ledge_col

func hlth_drn(dt):
	var div = 5
	var rnd = dt * div
	var curr = shifter.curr
	
	if hlth >= 0:
		if curr != 'spi':
			hlth -= dt / (div * 10)
		elif curr == 'spi':
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
		set_transform(chkpt.get_global_transform())

func translateMove(dist):
	var localTranslate = Vector3(0,0,dist)
	translate(get_transform().basis.xform(localTranslate))
