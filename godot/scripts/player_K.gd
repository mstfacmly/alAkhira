extends KinematicBody

const MAX_SLOPE_ANGLE = 45;

var g_Time = 0.0;
var cam = null;

var view_sensitivity = 0.2;
var focus_view_sensv = 0.1;
var sprint = 11.0
var run = 7.0
var walk = 3.33
#var run_multiplier = 2.1;
var max_speed = run;
var gravity = -9.8;
var gravity_factor = 3;
var jump_speed = -gravity ;
var acceleration = 4;
var deacceleration = 10;

var velocity = Vector3();
var is_moving = false;
var on_floor = false;

var focus_switchtime = 0.3;
var focus_mode = false;
var focus_right = true;

var jump_attempt = false;
var jumping = false;
var falling = false;
var relevantCol = null;

var char_offset;
onready var timer = get_node("timer");
onready var animate = get_node("AnimationTreePlayer");
var hvel
var curfov
onready var curr = get_node("scripts/shift")

var JS

# Animation constants
const FLOOR = 0
const WALK = 1
const SPRINT = 2
const AIR_UP = 3
const AIR_DOWN = 4
const RUN_AIR_UP = 5
const RUN_AIR_DOWN = 6

var anim

func _input(ev):
	if (ev.is_action("jump") && ev.is_pressed() && !ev.is_echo()):
		jump_attempt = true
	else:
		jump_attempt = false
	
	if ev.type == InputEvent.MOUSE_BUTTON:
		if ev.pressed && ev.button_index == BUTTON_RIGHT && g_Time > focus_switchtime:
			focus_mode = !focus_mode;
			focus_switchtime = g_Time + 0.2;
			
			if focus_mode:
				cam.cam_fov = 45.0;
				cam.cam_pitch_minmax = Vector2(30, -10);
				cam.cam_view_sensitivity = focus_view_sensv;
				
			else:
				cam.cam_fov = 64.0;
				cam.cam_pitch_minmax = Vector2(80, -60);
				cam.cam_view_sensitivity = view_sensitivity;

	if ev.type == InputEvent.KEY:
		if ev.pressed && Input.is_key_pressed(KEY_F11):
			OS.set_window_fullscreen(!OS.is_window_fullscreen());
			

func _process(delta):
	g_Time += delta;

#	var overview_map = get_node("/root/main/gui/map_overview");
#	overview_map.player_pos = Vector2(get_global_transform().origin.x, get_global_transform().origin.z);
#	overview_map.player_rot = deg2rad(cam.cam_cyaw);

func _fixed_process(delta):
	check_movement(delta);
	player_on_fixedprocess(delta);
	
	if InputEvent.JOYSTICK_MOTION:
		joy_input(delta);
	else:
		pass

func joy_input(delta):
	var x = abs(Input.get_joy_axis(0,0))
	var y = abs(Input.get_joy_axis(0,1))

	var axis_value = atan(x + y) # * PI / 360 * 100
	if axis_value < 0.743 and axis_value > 0.101 :
#		hspeed = max(hspeed - (deaccel * 0.3) * (delta * 10), 0)
#		get_node("AnimationTreePlayer").blend2_node_set_amount("walk", hspeed / (deaccel * 0.3))
		while max_speed > walk:
			max_speed -= 0.001
	else :
		pass

func check_movement(delta):
	var ray = get_node("ray");
	var aim = get_node("body").get_global_transform().basis;
	
	var g = gravity * gravity_factor;
	
	if on_floor:
		g = 0;
		if !is_moving:
			velocity.y = 0;
		if velocity.length() < 0.01:
			velocity = Vector3();
	
	is_moving = false;
	var direction = Vector3();
	
	if Input.is_key_pressed(KEY_W) or JS.get_analog("ls_up"):
		is_moving = true;
		direction += aim[2];
	elif Input.is_key_pressed(KEY_S) or JS.get_analog("ls_down"):
		is_moving = true;
		direction += aim[2];
	elif Input.is_key_pressed(KEY_A) or JS.get_analog("ls_left"):
		is_moving = true;
		direction += aim[2];
	elif Input.is_key_pressed(KEY_D) or JS.get_analog("ls_right"):
		is_moving = true;
		direction += aim[2];
	
	direction.y = 0;
	direction = direction.normalized()
	
	velocity.y += g*delta;
	
	var hvel = velocity;
	hvel.y = 0;
	
	var target = direction * max_speed;
	var accel = deacceleration;
	
	if direction.dot(hvel) > 0:
		accel = acceleration;
	
	hvel = target;
	#hvel = hvel.linear_interpolate(target,accel * delta);
	velocity.x = hvel.x;
	velocity.z = hvel.z;
	
	var motion = velocity * delta;
	motion = move(motion);
	
	on_floor = ray.is_colliding();
	
	var original_vel = velocity;
	var attempts=4;
	
	if motion.length() > 0:
		while is_colliding() && attempts:
			var n = get_collision_normal();
			if (rad2deg(acos(n.dot(Vector3(0,1,0))))< MAX_SLOPE_ANGLE):
				on_floor = true;
			
			motion = n.slide(motion);
			velocity = n.slide(velocity);
			
			if original_vel.dot(velocity) > 0:
				motion = move(motion);
				if motion.length() < 0.001:
					break;
			
			attempts-=1;
	
	if on_floor and jump_attempt:
		velocity.y = jump_speed # * gravity_factor;
		on_floor = false;
		jumping = true;
		falling = false;
	else:
		pass
		
	if jumping:
		if !jump_attempt:
			velocity.y += gravity / 4.972 #2.486 / 2.486
			jumping = false;
			falling = true;
		elif velocity.y < 2.486:
			velocity.y += gravity / 4.972
			jumping = false;
			falling = true;
			
	if !on_floor:
		falling = true;

func player_on_fixedprocess(delta):
	if Input.is_key_pressed(KEY_ALT) && is_moving:
		max_speed = max(min(max_speed - (4 * delta),walk * 2.0),walk);
	elif timer.get_wait_time() < 0.8:
		max_speed = max(min(max_speed + (10 * delta),walk),sprint);
	else:
		max_speed = max(min(max_speed + (4 * delta),walk * 2.0),run);
	
	var tmp_camyaw = cam.cam_yaw;
	if is_moving && !focus_mode:
		if Input.is_key_pressed(KEY_W) or JS.get_analog("ls_up"):
			if Input.is_key_pressed(KEY_A) or JS.get_analog("ls_left"):
				tmp_camyaw += 45;
			if Input.is_key_pressed(KEY_D)  or JS.get_analog("ls_right"):
				tmp_camyaw -= 45;
		elif Input.is_key_pressed(KEY_S) or JS.get_analog("ls_down"):
			if Input.is_key_pressed(KEY_A) or JS.get_analog("ls_left"):
				tmp_camyaw += 135;
			elif Input.is_key_pressed(KEY_D) or JS.get_analog("ls_right"):
				tmp_camyaw -= 135;
			else:
				tmp_camyaw -= 180;
		elif Input.is_key_pressed(KEY_A) or JS.get_analog("ls_left"):
			tmp_camyaw += 90;
		elif Input.is_key_pressed(KEY_D) or JS.get_analog("ls_right"):
			tmp_camyaw -= 90;
	
	hvel = velocity.length()
	var countd = timer.get_wait_time()
	
	if is_moving: # || focus_mode:
		var body_rot = get_node("body").get_rotation();
		body_rot.y = deg2rad(lerp(rad2deg(body_rot.y),tmp_camyaw,10 * delta));
#		#body_rot.y = deg2rad(tmp_camyaw);
		get_node("body").set_rotation(body_rot);
	
	if hvel >= 6.4 and hvel <= 7.2 :
		anim = FLOOR
		cam.cam_radius = 4.0
		cam.cam_fov = 68
		if timer.get_wait_time() > 0.05 :
			timer.set_wait_time(countd - 0.01)
		else:
			pass
	elif hvel >= 10:
		anim = SPRINT
		cam.cam_radius = 4.2
		cam.cam_fov = 72
	elif is_moving && hvel <= 4.2:
		anim = WALK
		cam.cam_radius = 3.3
		cam.cam_fov = 68
		if timer.get_wait_time() < 3:
			timer.set_wait_time(3)
		else:
			pass
	else:
		anim = FLOOR;
		cam.cam_radius = 2.5;
		cam.cam_fov = 64;
		timer.set_wait_time(3)
	
	if jumping:
		if hvel >= 6 :
			anim = RUN_AIR_UP;
		else:
			anim = AIR_UP;
	elif falling && !on_floor:
		if hvel >= 6:
			anim = RUN_AIR_DOWN;
		else:
			anim = AIR_DOWN;
	else:
		pass
	
	if hvel < 3 && jumping:
		anim = AIR_UP
	elif hvel < 4 && !jumping && !on_floor:
		anim = AIR_DOWN
	else:
		pass
	
	if on_floor:
		animate.blend2_node_set_amount("walk", hvel / max_speed)
	animate.transition_node_set_current("state", anim)
	
	curfov = cam.cam_fov
	
#	if curr == "spir" :
#		cam.cam_fov = curfov + 8
#	elif curr == "phys":
#		cam.cam_fov = curfov - 8
	

func _getPlatform(state, facing):
	var platformY = get_global_pos().y - char_offset.y + 16
	
	if (relevantCol.has("collider")):
		if(relevantCol["collider"].has_node("ledge")):
			return relevantCol["collider"]
	return null
	
func _getWall(state, facing):
	var wall = get_global_pos()

	if (relevantCol.has("collider")):
		if(relevantCol["collider"].has_node("wall")):
			return relevantCol["collider"]
	return null

func adjust_facing(p_facing, p_target,p_step, p_adjust_rate,current_gn):	#transition a change of direction

	var n = p_target						# normal
	var t = n.cross(current_gn).normalized()
	var x = n.dot(p_facing)
	var y = t.dot(p_facing)
	var ang = atan2(y,x)

	if (abs(ang)<0.001):					# too small
		return p_facing

	var s = sign(ang)
	ang = ang * s
	var turn = ang * p_adjust_rate * p_step
	var a
	if (ang < turn):
		a = ang
	else:
		a = turn
	ang = (ang - a) * s

	return ((n * cos(ang)) + (t * sin(ang))) * p_facing.length()

func _ready():
	get_node("ray").add_exception(self);
	
	cam = get_node("cam");
	
	if cam.has_method("set_enabled"):
		cam.set_enabled(true);
	
	cam.add_collision_exception(self);
	cam.cam_radius = 2.5;
	cam.cam_view_sensitivity = view_sensitivity;
	cam.cam_smooth_movement = true;
	
	set_process(true);
	set_fixed_process(true);
	set_process_input(true);
	
	animate.set_active(true)
	timer.set_wait_time(3)
	
	JS = get_node("/root/SUTjoystick")