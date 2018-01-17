extends Spatial

onready var target = get_parent().get_global_transform().origin

var cam_pitch = 0.0;
var cam_yaw = 0.0;
var cam_cpitch = 0.0;
var cam_cyaw = 0.0;
var cam_currentradius = 4.0;
var cam_radius = 4.0;
var cam_pos = Vector3();
var cam_ray_result = {};
var cam_smooth_movement = true;
export var cam_fov = 64.0;
export var min_distance = 0.5;
export var max_distance = 7.2;
export var angle_v_adjust = 0.0;
export var autoturn_ray_aperture = 24;
export var autoturn_speed = 25;
var cam_view_sensitivity = 0.3;
var cam_smooth_lerp = 6.16;
var cam_pitch_minmax = Vector2(69, -28);
var turn = Vector2()

export var js_accel_x = 2.3
export var js_accel_y = 1.3

var up = Vector3(0,1,0)
var ds;

var is_enabled = false;
var collision_exception = [];

export(NodePath) var cam;
export(NodePath) var pivot;

const DEADZONE = 0.1

func _ready():
	cam = get_node("cam");
	pivot = get_node("pivot");

	cam_fov = cam.get_fov();
	ds = get_world().get_direct_space_state();
	
#	set_process(true)
#	set_physics_process(true)

func set_enabled(enabled):
	if enabled:
		Input.set_mouse_mode(2);
		set_process(true);
#		set_fixed_process(true);
		set_process_input(true);
		is_enabled = true;
	else:
		Input.set_mouse_mode(0);
		set_process(false);
		set_fixed_process(false);
		set_process_input(false);
		is_enabled = false;

func clear_exception():
	collision_exception.clear();

func add_collision_exception(node):
	collision_exception.push_back(node);

func _input(ev):
	if !is_enabled:
		return;

	if ev == InputEventMouseMotion:
		cam_pitch = max(min(cam_pitch+(ev.relative_y*cam_view_sensitivity),cam_pitch_minmax.x),cam_pitch_minmax.y);
		if cam_smooth_movement:
			cam_yaw = cam_yaw-(ev.relative_x*cam_view_sensitivity);
		else:
			cam_yaw = fmod(cam_yaw-(ev.relative_x*cam_view_sensitivity),360);
			cam_currentradius = cam_radius;
			cam_update();

func js_input():

	var Jx = Input.get_joy_axis(0,2)
	var Jy = Input.get_joy_axis(0,3)

	if abs(Jy) >= DEADZONE:
		cam_pitch = max(min(cam_pitch - (Jy * (cam_view_sensitivity * js_accel_y) ),cam_pitch_minmax.x),cam_pitch_minmax.y);

	if abs(Jx) >= DEADZONE:
		if cam_smooth_movement:
			cam_yaw = cam_yaw - (Jx * (cam_view_sensitivity * js_accel_x));
		else:
			cam_yaw = fmod(cam_yaw - (Jx * (cam_view_sensitivity * js_accel_x)),360);
			cam_currentradius = cam_radius;
			cam_update();


func cam_update():
	cam_pos = pivot.get_global_transform().origin;
	var delta = cam_pos - target #regular delta follow
#	var ds = get_world().get_direct_space_state();

	if cam_smooth_movement:
		cam_pos.x += cam_currentradius * sin(deg2rad(cam_cyaw)) * cos(deg2rad(cam_cpitch));
		cam_pos.y += cam_currentradius * sin(deg2rad(cam_cpitch));
		cam_pos.z += cam_currentradius * cos(deg2rad(cam_cyaw)) * cos(deg2rad(cam_cpitch));
	else:
		cam_pos.x += cam_currentradius * sin(deg2rad(cam_yaw)) * cos(deg2rad(cam_pitch));
		cam_pos.y += cam_currentradius * sin(deg2rad(cam_pitch));
		cam_pos.z += cam_currentradius * cos(deg2rad(cam_yaw)) * cos(deg2rad(cam_pitch));

	var pos = Vector3();

	if (delta.length() < min_distance):
		delta = delta.normalized() * min_distance
	elif (delta.length() > max_distance):
		delta = delta.normalized() * max_distance

	if cam_ray_result.size() != 0:
		var a = (cam_ray_result.position - cam_pos).normalized();
		var b = cam_pos.distance_to(cam_ray_result.position);
		#pos = cam_ray_result.position;
		if a.length() < min_distance:
			a = a.normalized * min_distance;
		elif a.length() > max_distance:
			a = a.normalized() * max_distance;
		pos = cam_pos + a * max(b-0.5, 0);
	else:
		pos = cam_pos;

	cam.look_at_from_position(pos, pivot.get_global_transform().origin, up);

func autoturn_cam(dt):
	var delta = cam_pos - target #regular delta follow

	var col_left = ds.intersect_ray(target,target+Basis(up,deg2rad(autoturn_ray_aperture)).xform(delta),collision_exception)
	var col = ds.intersect_ray(target,target+delta,collision_exception)
	var col_right = ds.intersect_ray(target,target+Basis(up,deg2rad(-autoturn_ray_aperture)).xform(delta),collision_exception)

	if (!col.empty()):
		#if main ray was occluded, get camera closer, this is the worst case scenario
		delta = col.position - target
	elif (!col_left.empty() and col_right.empty()):
		#if only left ray is occluded, turn the camera around to the right
		delta = Basis(up,deg2rad(-dt*autoturn_speed)).xform(delta)
	elif (col_left.empty() and !col_right.empty()):
		#if only right ray is occluded, turn the camera around to the left
		delta = Basis(up,deg2rad(dt*autoturn_speed)).xform(delta)
	else:
		#do nothing otherwise, left and right are occluded but center is not, so do not autoturn
		pass

func _process(delta):
	if !is_enabled:
		return;

	if !cam.is_current():
		cam.make_current();

	if cam.get_projection() == Camera.PROJECTION_PERSPECTIVE:
		cam.set_perspective(lerp(cam.get_fov(), cam_fov, cam_smooth_lerp * delta), cam.get_znear(), cam.get_zfar());

	if cam_smooth_movement:
		cam_cpitch = lerp(cam_cpitch, cam_pitch, 10 * delta);
		cam_cyaw = lerp(cam_cyaw, cam_yaw, 10 * delta);
		cam_currentradius = lerp(cam_currentradius, cam_radius, 5 * delta);

	js_input();
	cam_update();

func _physics_process(delta):
	autoturn_cam(delta);

	if !is_enabled:
		return;

	if ds != null:
		cam_ray_result = ds.intersect_ray(pivot.get_global_transform().origin, cam_pos, collision_exception);
