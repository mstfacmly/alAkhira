extends KinematicBody

#onready var timer = get_node("timer");
onready var animate = get_node("animationTree");
onready var curr = get_node("scripts/shift");
onready var mesh = get_node("body/skeleton/mesh");
onready var health = get_node("ui/healthb");

# Environment
var g = Vector3(0,-9.8,0);
var up = -g.normalized()

const CHAR_SCALE = Vector3(1,1,1)
const DEADZONE = 0.1

# Camera
onready var cam = get_node("cam");
onready var cam_node = cam.get_node("cam");
var view_sensitivity = 0.2;
var focus_view_sensv = 0.1;
var curfov;

#Movement
var lin_vel = Vector3();
const ACCEL = 6;
const DEACCEL = ACCEL * 2.13;
export var run = 4.44
var walk = run / 1.75
var sprint = run * 2.12 #7.77
var mv_dir = Vector3()
var mv_spd = run;
var turn_speed = 42;
var sharp_turn_threshold = 130
#var climbspeed = 2
var jmp_spd = -g #/ 1.91 ;
var hvel = Vector3();
var hspeed
var jump_attempt = false
var jumping = false;
var falling = false;
var vvel
var wrun = [];
var wjmp
var dist = 4;
var collision_exception=[ self ];
var col_result = [];
var ledge_col = Vector3();
var on_ledge = false;

var anim;
var climb_platform = null;
var climbing_platform = false;
var hanging = false;
var facing_dir = Vector3(1, 0, 0);
var result;

# Animation constants
const FLOOR = 0
const WALK = 1
const SPRINT = 2
const AIR_UP = 3
const AIR_DOWN = 4
const RUN_AIR_UP = 5
const RUN_AIR_DOWN = 6

func _input(ev):
	if ev == InputEventKey:
		if ev.is_pressed() && Input.is_key_pressed(KEY_F11):
			OS.set_window_fullscreen(!OS.is_window_fullscreen())

	if ev.is_action_pressed("jump"):
		jump_attempt = true
	elif ev.is_action_released("jump") or ev.is_echo():
		jump_attempt = false

func js_input(delta):
	var x = abs(Input.get_joy_axis(0,0))
	var y = abs(Input.get_joy_axis(0,1))

	var axis_value = atan(x + y)# * PI / 360 * 100
	if axis_value >= DEADZONE && axis_value <= 0.743:
		if mv_spd > walk:
			while mv_spd > walk:
				mv_spd -= 0.05;
#				mv_spd = max(min(mv_spd - (4 * delta),walk * 2.0),walk);
		else:
			mv_spd = walk;
	else :
		pass
#	print(axis_value)


func adjust_facing(p_facing, p_target, p_step, p_adjust_rate, current_gn):
        var n = p_target # Normal
        var t = n.cross(current_gn).normalized()

        var x = n.dot(p_facing)
        var y = t.dot(p_facing)

        var ang = atan2(y,x)

        if (abs(ang) < 0.001): # Too small
                return p_facing

        var s = sign(ang)
        ang = ang*s
        var turn = ang*p_adjust_rate*p_step
        var a
        if (ang < turn):
                a = ang
        else:
                a = turn
        ang = (ang - a)*s

        return (n*cos(ang) + t*sin(ang))*p_facing.length()

func _physics_process(delta):
	# Velocity
	var lv = lin_vel
	lv += g * (delta * 3)
	vvel = up.dot(lv)
	var hvel = lv - up * vvel

	var hdir = hvel.normalized()
	var hspeed = hvel.length()

	var dir = Vector3()

	# Input
	var mv_u = Input.is_action_pressed("mv_f")
	var mv_b = Input.is_action_pressed("mv_b")
	var mv_l = Input.is_action_pressed("mv_l")
	var mv_r = Input.is_action_pressed("mv_r")

	var cam_xform = cam_node.get_global_transform()

	if mv_u:
		dir += -cam_xform.basis[2]
	if mv_b:
		dir += cam_xform.basis[2]
	if mv_l:
		dir += -cam_xform.basis[0]
	if mv_r:
		dir += cam_xform.basis[0]

	var target_dir = (dir - up * dir.dot(up)).normalized()
	var mesh_xform = mesh.get_transform()
	var facing_mesh = -mesh_xform.basis[0].normalized()
	
	if is_on_floor():# or (is_on_wall() && jump_attempt):
		var sharp_turn = hspeed > 0.1 and rad2deg(acos(target_dir.dot(hdir))) > sharp_turn_threshold

		if dir.length() > 0.1 and !sharp_turn:
			if hspeed > 0.001:
				hdir = adjust_facing(hdir, target_dir, delta, 1.0 / hspeed * turn_speed, up)
				facing_dir = hdir
			else:
				hdir = target_dir

			if hspeed < mv_spd:
				hspeed += ACCEL * delta
		else:
			hspeed -= DEACCEL * delta
			if hspeed < 0:
				hspeed = 0
#		print("hspeed: ",hspeed)

		hvel = hdir * hspeed

		facing_mesh = (facing_mesh - up * facing_mesh.dot(up)).normalized()
		if hspeed > 0.01:
			facing_mesh = adjust_facing(facing_mesh, target_dir, delta, 1.0 / hspeed * turn_speed, up)
		var m3 = Basis(-facing_mesh, up, -facing_mesh.cross(up).normalized()).scaled(CHAR_SCALE)

		mesh.set_transform(Transform(m3, mesh_xform.origin))

	else:
		var hs
		if dir.length() > 0.1:
			hvel += target_dir * (ACCEL * 0.2) * delta
			if hvel.length() > mv_spd:
				hvel = hvel.normalized() * mv_spd

	if is_on_floor() && jump_attempt:
		jumping = true
		vvel = jmp_spd
	elif !is_on_floor() && jump_attempt or !is_on_floor() && !jump_attempt:
		jumping = false

	lv = hvel + up * vvel

	if is_on_floor():
		mv_dir = lv
		wrun = []
		falling = false
	
	if !is_on_floor():
		if hspeed >= run:
			if col_result == ['front']:
#				vvel = jmp_spd + hspeed;# * 0.13);
				wrun = 'vert';
				is_on_wall()
			elif col_result == ['left'] or col_result == ['right']:# && hspeed > walk:
#				vvel = jmp_spd + (hspeed * 0.13);
#				hvel = jmp_spd + hvel;
				wrun = 'horz';
#				jumping = false;
				is_on_wall()
			else:
				col_result == []
				wrun = []
		if !jumping:
			falling = true
			
	wjmp = jmp_spd + (hvel * 0.5)
	
	lin_vel = move_and_slide(lv, up)

	player_fp(delta)
	js_input(delta)
	parkour()
	ledge()


func player_fp(delta):
	hspeed = lin_vel.length()
#	var countd = timer.get_wait_time()
	anim = FLOOR

	if Input.is_key_pressed(KEY_ALT):
		if (hspeed > walk ):
			mv_spd = max(min(mv_spd - (2 * delta),walk * 2.0),walk);
		elif (hspeed <= walk) :
			mv_spd = walk
		anim = FLOOR;
		cam.cam_radius = 3.7
		cam.cam_fov = 64
#	elif timer.get_wait_time() < 0.8:
#		mv_spd = max(min(mv_spd + (delta),walk),sprint);
	else:
		cam.cam_radius = 3.1;
		cam.cam_fov = 64;
#		timer.set_wait_time(3)
		mv_spd = max(min(mv_spd + (delta * 0.5),walk),run);

	if hspeed >= run - 0.1 and hspeed <= sprint - 1 :
		anim = FLOOR
		cam.cam_radius = 4.0
		cam.cam_fov = 69
#		if timer.get_wait_time() > 0.05 :
#			timer.set_wait_time(countd - 0.005)
#		else:
#			pass
	elif hspeed >= run + 1.3:
		anim = SPRINT
		cam.cam_radius = 4.2
		cam.cam_fov = 72
	elif hspeed >= 0.1 && hspeed <= run:
		anim = WALK
		cam.cam_radius = 3.7
		cam.cam_fov = 64
#		if timer.get_wait_time() < 3:
#			timer.set_wait_time(3)
#		else:
#			pass
	else:
		pass

	if jumping:
		if hspeed >= run :
			anim = RUN_AIR_UP;
		else:
			anim = AIR_UP;
	elif falling: # && !is_on_floor():
		if hspeed >= sprint:# - 1:
			anim = RUN_AIR_DOWN;
		else:
			anim = AIR_DOWN;
	else:
		pass

	if hspeed < 3 && jumping:
		anim = AIR_UP
	elif hspeed < 4 && jumping && !is_on_floor():
		anim = AIR_DOWN
	else:
		pass

#	if wrun == 'vert':
#		anim = SPRINT;
#	elif wrun == 'horz':
#		anim = SPRINT;

	if is_on_floor():
		animate.blend2_node_set_amount("run", hspeed / mv_spd);
	animate.transition_node_set_current("state", anim);

	if !is_on_floor() or (!col_result.empty() and hspeed >= run):
		cam.cam_radius = 4.7
		cam.cam_fov = 72

	curfov = cam.cam_fov
	var physfov
	var spifov

	if curr.curr != 'spir' && curr.shifting :
		cam.cam_fov += 13
	elif curr.curr == 'phys' && curr.shifting :
		cam.cam_fov -= 13

func parkour():
	var ds = get_world().get_direct_space_state();
	var parkour_detect = 80;
	var ppos = mesh.get_global_transform().origin;
	var ptarget = mesh.get_node("targets/ptarget").get_global_transform().origin
	var delta = ptarget - ppos;

	var col_right = ds.intersect_ray(ppos,ptarget+Basis(up,deg2rad(parkour_detect)).xform(delta),collision_exception)
	var col = ds.intersect_ray(ppos,ptarget+delta,collision_exception)
	var col_left = ds.intersect_ray(ppos,ptarget+Basis(up,deg2rad(-parkour_detect)).xform(delta),collision_exception)

	if (!col_left.empty() && col_right.empty()):
		col_result = ['left']
		return col_result
	elif (!col_right.empty() && col_left.empty()):
		col_result = ['right']
		return col_result
	elif (!col.empty() && !col_left.empty() && col_right.empty()):
		col_result = ['left']
		return col_result
	elif (!col.empty() && !col_right.empty() && col_left.empty()):
		col_result = ['right']
		return col_result
	elif (!col.empty()): # && col_left.empty() && col_right.empty()):
		col_result = ['front']
		return col_result
	else:
#		pass
		col_result = []
		return col_result


func ledge():
	var ds = get_world().get_direct_space_state();
	var ppos = mesh.get_global_transform().origin;
	var ptarget = mesh.get_node("targets/ptarget").get_global_transform().origin;
	var ledgecol = mesh.get_node("targets/ledgecol").get_global_transform().origin;
	var delta = ptarget - ppos;
	var lv = Vector3()
	
	var ledge_diff = ledge_col.y - mesh.get_global_transform().origin.y
	print(ledge_diff)
	
	if col_result == ['front']:
		var col_top = ds.intersect_ray(ledgecol,ptarget)
		if !col_top.empty():
			ledge_col = Vector3(0,col_top.position.y,0)
			return ledge_col
			ledgecol.global_translation(ledge_col)
	else:
		pass
		
	if is_on_wall():
#	if col_result == ['front']:
		if !jump_attempt:
			lv = Vector3(0,0.0000001,0)
		elif jump_attempt:
			if col_result == ['front']:
#				vvel = jmp_spd + hvel #(hvel * 2)
				lv = hvel * wjmp * up
				if ledge_diff <= 1.6 && ledge_diff >= -1.1:
					on_ledge = true;
				else:
					on_ledge = false
#					!is_on_wall()
		else:
			pass
	else:
		pass
		
#	print('wrun: ', wrun)
	if on_ledge:
		translate(ledge_col)# - (ledge_col - Vector3(0,2.8,0)))
#		mesh.get_owner().global_translate(wjmp)
#		mesh.get_owner().move_and_slide(wjmp, Vector3(0,0,1),1)
#		mesh.get_owner().translate(ledge_col * 0.5)
		lv = ledge_col
		if jump_attempt:
			lv = wjmp
			on_ledge = false
#			move_and_slide(Vector3(0,0,1),up)
	else:
		on_ledge = false
		lv += g * (delta *3)
		pass
	
#	if wrun == ['vert']:
#		var col_top = ds.intersect_ray(ledgecol,ptarget);
#		if !col_top.empty():
#			ledge_col = col_top.position.y ;
#			return ledge_col ;
#	elif wrun == []:
#		ledge_col = [];
#	else:
#		pass
		
#	print("ledge col: ", ledge_col)


func _ready():
	animate.set_active(true)

	if cam.has_method("set_enabled"):
		cam.set_enabled(true);

	cam.add_collision_exception(self);
	cam.cam_radius = 2.5;
	cam.cam_view_sensitivity = view_sensitivity;
	cam.cam_smooth_movement = true;
