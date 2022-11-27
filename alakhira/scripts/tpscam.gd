extends Spatial

var pitch = 0.0
var yaw = 0.0
var radius = 4.0
var currentpitch = pitch
var currentyaw = yaw
onready var currentradius = radius

export (NodePath) var cam_position
export (NodePath) var look_target setget target_pos
var old_target
var target_player
export (NodePath) var target_height
var smooth_movement:bool = false
var locked_on:bool = false setget _set_locked_on

export var smooth_lerp = 6.16
export var pitch_minmax = Vector2(-28, 69)

const DEADZONE = 0.1

func _ready():
	add_to_group('camera')
	smooth_movement = true
	$cam.add_exception(get_parent())
	$cam.add_exception(self)

func _set_locked_on(lock_on):
	locked_on = lock_on

func cam_adjust(new_fov,new_radius):
	if !null:
		$cam.fov = new_fov
		radius = new_radius

func set_enabled(active:bool):
	set_process(active)
	set_process_input(active)
	$cam.set_process_mode(active)

	if active:
		Input.set_mouse_mode(2)
		$cam.make_current()
#		cam_position_target($pivot)
#		target_pos($target)
		set_pivot_height((get_node(target_height).shape.height + get_node(target_height).global_transform.origin.y) * 0.8)
		cam_position = get_node(cam_position)
		target_player = get_node(look_target)
		look_target = get_node(look_target)
	else:
		Input.set_mouse_mode(0)

func _input(ev):
#	if !locked_on:
	if ev is InputEventMouseMotion:
		cam_input(Vector2(global.mouse_sens,global.mouse_sens),ev.relative)

	if ev is InputEventJoypadMotion:
		cam_input(Vector2(global.js_x,global.js_y),Vector2(Input.get_joy_axis(0,2),Input.get_joy_axis(0,3)))

	if Input.is_action_just_pressed("lock_on"):
		_set_locked_on(!locked_on)
		target_pos(get_tree().get_nodes_in_group('target')[0]) if locked_on else target_pos(target_player)

func cam_input(view_sens,axis):
	if abs(view_sens.length()) >= DEADZONE:
		pitch = clamp(pitch - axis.y * view_sens.y * (-1 if global.invert_y else 1),pitch_minmax.x,pitch_minmax.y)
		if smooth_movement:
			yaw += axis.x * view_sens.x * (-1 if global.invert_x else 1)
		else:
			yaw += fmod(axis.x * view_sens.x,360) * (-1 if global.invert_x else 1)
			currentradius = radius

func cam_position_target(position):
	cam_position = position

func target_pos(new_target):
	old_target = look_target
	look_target = new_target
#	$target.global_transform.origin = new_target.get_global_transform().origin

func set_pivot_height(height):
	$pivot.global_transform.origin.y = height
	$target.global_transform.origin.y = height
	$cam_position.global_transform.origin.y = height
	$cam_position.global_transform.origin.z = radius * 1.2

func cam_motion(position):
	global_transform.origin = position.global_transform.origin
	if !locked_on:
		position = rotatecam(position.global_transform.origin)
	else:
		position = $cam_position.global_transform.origin
		
#	$cam.look_at(look_target.global_transform.origin,Vector3.UP)
	$cam.look_at_from_position($pivot.global_transform.origin, look_target.global_transform.origin, Vector3.UP)

func rotatecam(pos):
	if smooth_movement:
		pos.x += currentradius * sin(deg2rad(currentyaw)) * cos(deg2rad(currentpitch))
		pos.y += currentradius * sin(deg2rad(currentpitch))
		pos.z += currentradius * cos(deg2rad(currentyaw)) * cos(deg2rad(currentpitch))
	else:
		pos.x += currentradius * sin(deg2rad(yaw)) * cos(deg2rad(pitch))
		pos.y += currentradius * sin(deg2rad(pitch))
		pos.z += currentradius * cos(deg2rad(yaw)) * cos(deg2rad(pitch))
		
	return pos

func _smoothcam(delta):
	currentpitch = lerp(currentpitch, pitch, 10 * delta)
	currentyaw = lerp(currentyaw, yaw, 10 * delta)
	currentradius = lerp(currentradius, radius, 5 * delta)

func _process(delta):
	if $cam.PROJECTION_PERSPECTIVE:
		$cam.set_perspective(lerp($cam.get_fov(), $cam.fov, smooth_lerp * delta), $cam.get_znear(), $cam.get_zfar())
	
	cam_motion(cam_position)
	if smooth_movement:
		_smoothcam(delta)
