extends Spatial

var pitch = 0.0
var yaw = 0.0
var radius = 0.0
var currentpitch = pitch
var currentyaw = yaw
onready var currentradius = radius

#export (NodePath) var cam_position setget cam_position_target
export (NodePath) var pivot_target #setget set_pivot_position
export (NodePath) var look_target #setget set_look_target
var old_target
var target_player
export (NodePath) var target_height
var smooth_movement:bool = true
var locked_on:bool = false setget _set_locked_on

var param_tween = Tween.new()

export var smooth_lerp = 6.16
export var pitch_minmax = Vector2(-28, 69)

const DEADZONE = 0.1

func _ready():
	target_player = look_target
	$cam.add_exception(get_node(look_target))
	_set_look_target(get_node(look_target))
	Input.set_mouse_mode(2)
	add_to_group('camera')
	add_child(param_tween)

func _set_locked_on(lock_on):
	locked_on = lock_on
	return locked_on

func _cam_adjust(new_fov,new_radius):
	if !null:
		$cam.fov = new_fov
		radius = new_radius

func _input(ev):
	if ev is InputEventMouseMotion && !locked_on:
		_cam_input(Vector2(global.mouse_sens,global.mouse_sens),ev.relative)

	if ev is InputEventJoypadMotion && !locked_on:
		_cam_input(Vector2(global.js_x,global.js_y),Vector2(Input.get_joy_axis(0,2),Input.get_joy_axis(0,3)))
	
	if Input.is_action_just_pressed("lock_on"):
		_set_look_target(get_tree().get_nodes_in_group('target')[0] if _set_locked_on(!locked_on) else old_target)
#		_tween_param(look_target,'position')

func _cam_input(view_sens,axis):
	if abs(view_sens.length()) >= DEADZONE:
		pitch = clamp(pitch - axis.y * view_sens.y * (-1 if global.invert_y else 1),pitch_minmax.x,pitch_minmax.y)
		if smooth_movement:
			yaw += axis.x * view_sens.x * (-1 if global.invert_x else 1)
		else:
			yaw += fmod(axis.x * view_sens.x,360) * (-1 if global.invert_x else 1)
			currentradius = radius

func _set_look_target(new_target):
	old_target = look_target
	look_target = new_target

func _look_target_position():
	$target.global_transform.origin = look_target.global_transform.origin
	$target.global_transform.origin.y = _set_height(look_target)
	return $target.global_transform.origin

func _set_pivot_position(new_pivot):
	global_transform.origin = new_pivot.global_transform.origin
	$pivot.global_transform.origin.y = _set_height(new_pivot)
	$cam_position.global_transform.origin.y = _set_height(new_pivot)

func _set_height(height):
	return height.global_transform.origin.y + height.get_node('collision').shape.height

func _cam_motion(position,delta):
	if smooth_movement:
		position += currentradius * _circle_calc(currentyaw,currentpitch)
		_smoothcam(delta)
	else:
		position += currentradius * _circle_calc(yaw,pitch)
	return position

func _circle_calc(y,p):
	return Vector3(sin(deg2rad(y)) * cos(deg2rad(p)), sin(deg2rad(p)) , cos(deg2rad(y)) * cos(deg2rad(p)))

func _smoothcam(delta):
	currentpitch = lerp(currentpitch, pitch, 10 * delta)
	currentyaw = lerp(currentyaw, yaw, 10 * delta)
	currentradius = lerp(currentradius, radius, 5 * delta)

# https://m.twitch.tv/videos/1170334807
func _tween_param(target,parameter):
	param_tween.interpolate_property(self,parameter,null, target.get(parameter),1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
func _physics_process(delta):
	_set_pivot_position(get_node(pivot_target))
#	$cam.set_perspective(lerp($cam.get_fov(), $cam.fov, smooth_lerp * delta), $cam.get_znear(), $cam.get_zfar())
	$cam.transform.origin = _cam_motion($cam_position.transform.origin, delta)
	$cam.look_at(_look_target_position(), Vector3.UP)
