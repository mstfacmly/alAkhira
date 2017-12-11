extends KinematicBody

#onready var timer = get_node("timer");
#onready var health = get_node("ui/healthb");

# Environment
var g = Vector3(0,-9.8,0);
var up = -g.normalized()

const CHAR_SCALE = Vector3(1,1,1)
const DEADZONE = 0.1

# Camera
var view_sensitivity = 0.2;
var focus_view_sensv = 0.1;
var curfov;

#Movement
var ppos
var lin_vel = Vector3();
const ACCEL = 6;
const DEACCEL = ACCEL * 2.13;
export var run = 4.44
var walk = run / 1.75
var sprint = run * 2.12 #7.77
#var mv_dir = Vector3()
var mv_spd = run;
var turn_speed = 42;
var sharp_turn_threshold = 130
#var climbspeed = 2
var jmp_spd = -g * 1.84 ;
var hvel = Vector3();
var hspeed
var parkour_f = false
var jumping = false;
var falling = false;
var vvel
var can_wrun
var wrun = [];
var dist = 4;
var collision_exception=[ self ];
var col_f
var col_result = [];
var ledge_col = Vector3();
var on_ledge = false;
var ptarget
var ledgecol

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
const LEDGE_H = 7
const ROLL = 8

var timer = 0
#var time_start = 0
#var time_now = 0

func _input(ev):
	if ev == InputEventKey:
		if ev.is_pressed() && Input.is_key_pressed(KEY_F11):
			OS.set_window_fullscreen(!OS.is_window_fullscreen())

	if ev.is_action_pressed("feet"):
		parkour_f = true
	elif ev.is_action_released("feet"):# or ev.is_echo():
		parkour_f = false

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
	var mesh = $body/skeleton/mesh
	var cam_node = $cam/cam
	js_input(delta)

	# Velocity
	var lv = lin_vel
	lv += g * (delta * 3)
	vvel = up.dot(lv)
	var hvcalc = lv - up * vvel
	hvel = Vector3(hvcalc.x, 0 ,hvcalc.z)

	var hdir = hvel.normalized()
	var hspeed = hvel.length()
	
	ppos = mesh.get_global_transform().origin
	ptarget = mesh.get_node("targets/ptarget").get_global_transform().origin
	ledgecol = mesh.get_node("targets/ledgecol").get_global_transform();

	var dir = Vector3()

	# Input
	var mv_u = Input.is_action_pressed("mv_f")
	var mv_b = Input.is_action_pressed("mv_b")
	var mv_l = Input.is_action_pressed("mv_l")
	var mv_r = Input.is_action_pressed("mv_r")
	var jmp_att = Input.is_action_just_pressed("feet")

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
	var mesh_basis = mesh_xform.basis[0]
	
	if is_on_floor() or on_ledge:# or (is_on_wall() && parkour_f):
		var sharp_turn = hspeed > 0.1 and rad2deg(acos(target_dir.dot(hdir))) > sharp_turn_threshold

		if dir.length() > 0.1 and !sharp_turn:
			if hspeed >= walk -1: # 0.001:
				hdir = adjust_facing(hdir, target_dir, delta, 1.0 / hspeed * turn_speed, up)
				facing_dir = hdir
			elif on_ledge:
				hdir = mesh_basis + Vector3(0,0,target_dir.z)
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
		if hspeed > 0.01 and is_on_floor():
			facing_mesh = adjust_facing(facing_mesh, target_dir, delta, 1.0 / hspeed * turn_speed, up)
		var m3 = Basis(-facing_mesh, up, -facing_mesh.cross(up).normalized())#.scaled(CHAR_SCALE)

		mesh.set_transform(Transform(m3, mesh_xform.origin))

	else:
		var hs
		if dir.length() > 0.1:
			hvel += target_dir * (ACCEL * 0.2) * delta
			if hvel.length() > mv_spd:
				hvel = hvel.normalized() * mv_spd

	if is_on_floor() && jmp_att:
		jumping = true
		can_wrun = true
		vvel = jmp_spd
	elif !is_on_floor() && !jmp_att: #parkour_f or !is_on_floor() && !parkour_f:
		jumping = false

	lv = hvel + up * vvel
	
	parkour()

	if is_on_floor():
#		mv_dir = lv
		wrun = []
		falling = false
		var can_wrun = true
	
	if !is_on_floor():
		ledge()
		if hspeed >= run:
			if col_result == ['front']:
#				vvel = jmp_spd + hspeed;# * 0.13);
				wrun = ['vert'];
#				is_on_wall()
			elif col_result == ['left'] or col_result == ['right']:# && hspeed > walk:
#				vvel = jmp_spd + (hspeed * 0.13);
#				hvel = jmp_spd + hvel;
				wrun = ['horz'];
#				jumping = false;
#				is_on_wall()
			else:
				col_result == []
				wrun = []
		if !jumping:
			falling = true
			
	var wjmp = jmp_spd + (hvel)# * 0.5)
	var ledge_diff = ledge_col.y - ptarget.y
#	print(ledge_col)
#	print("diff :", ledge_diff)
#	print(col_result)
	
	if is_on_wall():
		ledge()
		if wrun == ['vert']:# && is_on_wall():
#		ledge()
			if !jmp_att :
				lv = Vector3(0,0.0000001,0)
			if parkour_f:
#				if col_result == ['front']:
#				vvel = jmp_spd + hvel #(hvel * 2)
#				lv += g * (delta *3)
				lv = wjmp
				vvel = jmp_spd #wjmp# + hvel# + up
				if ledge_col.y > 3.33 && ledge_diff <= 1.2 && ledge_diff >= 0.2:
					global_translate(ledge_col - ledge_col - facing_mesh.slide(Vector3(0,1.2,0)))
#					global_translate(wjmp)
#					move_and_slide(wjmp, Vector3(0,0,1),1)
#					translate(ledge_col)
					on_ledge = true;
				else:
					on_ledge = false
#					!is_on_wall()
	
	if wrun == ['horz']:
		if wjmp && can_wrun == true:
#			vvel = jmp_spd * 0.84
			if is_on_wall():
				lv.y = 0.01
				lv.y -= lv.y + delta/delta * 0.9
				timer += 0.01
#				print(timer)
#				if timer >= 0.99:
#					parkour_f = false
#					jmp_att = false
#					can_wrun = false
#				mesh.rotate_y(col_f.normal.z)
			if can_wrun == false:
				wjmp = false
				lv.y += g.y * (delta *3)
#				lv = Vector3(0,0.0000001,0)
		elif !wjmp:
			lv.y += g.y * (delta *3)
	else:
#		timer = 0
		pass
		
#	print('wrun: ', wrun)
	if on_ledge:
		wrun = []
#		mv_dir = Vector3(0,0,lv.z)
		lv.y = 0
		if jmp_att:
#			lv += jmp_spd
			on_ledge = false
			translate(ledge_col + mesh_basis + Vector3(0,-6.36,0.91))
#			move_and_slide(Vector3(0,0,1),-g.normalized())
		if Input.is_action_pressed("arm_r"):
#			translate(mesh_basis)
			mesh.rotate(up, 185)
			on_ledge = false
#			lv += g * (delta * 3)

	elif !on_ledge:
		lv += g * (delta *3)
	
#	if on_ledge:
#		lin_vel = move_and_slide(Vector3(0,0,lv.z),up)
#	else:
	lin_vel = move_and_slide(lv, up)
		

	player_fp(delta)
#	parkour()
#	ledge()


func player_fp(delta):
	var animate = $animationTree
	var curr = $scripts/shift
	var cam = $cam
	
	animate.set_active(true)
	if cam.has_method("set_enabled"):
		cam.set_enabled(true)

	cam.add_collision_exception(self);
	cam.cam_radius = 2.5;
	cam.cam_view_sensitivity = view_sensitivity;
	cam.cam_smooth_movement = true;
	
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
		
	if on_ledge:
		anim = LEDGE_H

	if wrun == ['vert']:
		anim = ROLL
	elif wrun == ['horz']:
		anim = ROLL

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
		col_f = col
		return col_f
		return col_result
	else:
#		pass
		col_result = []
		return col_result


func ledge():
	var ds = get_world().get_direct_space_state();
	var delta = ptarget - ppos;
	
	if col_result == ['front']:
		var col_top = ds.intersect_ray(ledgecol.origin,ptarget)
		if !col_top.empty():
			ledge_col = Vector3(0,col_top.position.y,0)
			return ledge_col
			ledgecol.translate(ledge_col)
	elif col_result.empty():
		ledgecol.translated(Vector3(-0, 5.5,3))
		ledge_col = Vector3()
		return ledge_col
		
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

	pass