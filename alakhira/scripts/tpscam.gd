extends Spatial

var pitch = 0.0
var yaw = 0.0
var currentpitch = 0.0
var currentyaw = 0.0
var currentradius = 4.0
var radius = 4.0
var pos = Vector3()

var smooth_movement = false
var mod_x = 1
var mod_y = 1

export var distance = Vector2(0.5,7.2)
export var smooth_lerp = 6.16
export var pitch_minmax = Vector2(-28, 69)

const DEADZONE = 0.1

func _ready():
	add_to_group('camera')
	smooth_movement = true
	$cam.add_exception(get_parent())
	$cam.add_exception(self)
	target_pos($pivot.get_global_transform().origin)

func _process(delta):
	if $cam.projection == Camera.PROJECTION_PERSPECTIVE:
		$cam.set_perspective(lerp($cam.get_fov(), $cam.fov, smooth_lerp * delta), $cam.get_znear(), $cam.get_zfar())
	
	cam_motion()
	
	if smooth_movement:
		_smoothcam(delta)

func cam_adjust(new_fov,new_radius):
	if !null:
		$cam.fov = new_fov
		radius = new_radius

func set_enabled(enabled:bool):
	if enabled:
		Input.set_mouse_mode(2)
		set_process(true)
		set_process_input(true)
		$cam.make_current()
		$cam.process_mode = 1
	else:
		Input.set_mouse_mode(0)
		set_process(false)
		set_process_input(false)

# warning-ignore:unused_argument
func _invert_x(false):
	if !false:
		mod_x = -1
	else:
		mod_x = 1

# warning-ignore:unused_argument
func _invert_y(false):
	if !false:
		mod_y = -1
	else:
		mod_y = 1

func _input(ev):
	if ev is InputEventMouseMotion:
		cam_input(Vector2(global.mouse_sens,global.mouse_sens),ev.relative.x,ev.relative.y)

	if ev is InputEventJoypadMotion:
		cam_input(Vector2(global.js_x,global.js_y),Input.get_joy_axis(0,2),Input.get_joy_axis(0,3))

func cam_input(view_sens,axis_x,axis_y):
	if abs(view_sens.y) >= DEADZONE:
		pitch = clamp(pitch - axis_y * view_sens.y,pitch_minmax.x,pitch_minmax.y) * mod_y
	
	if abs(view_sens.x) >= DEADZONE:
		if smooth_movement:
			yaw += axis_x * view_sens.x * mod_x
		else:
			yaw += fmod(axis_x * view_sens.x,360) * mod_x
			currentradius = radius

func target_pos(target):
	$target.global_transform.origin = target

func cam_motion():
	pos = $pivot.get_global_transform().origin

	if smooth_movement:
		pos.x += currentradius * sin(deg2rad(currentyaw)) * cos(deg2rad(currentpitch))
		pos.y += currentradius * sin(deg2rad(currentpitch))
		pos.z += currentradius * cos(deg2rad(currentyaw)) * cos(deg2rad(currentpitch))
	else:
		pos.x += currentradius * sin(deg2rad(yaw)) * cos(deg2rad(pitch))
		pos.y += currentradius * sin(deg2rad(pitch))
		pos.z += currentradius * cos(deg2rad(yaw)) * cos(deg2rad(pitch))
	
	$cam.look_at_from_position(pos, $target.get_global_transform().origin, Vector3.UP)

func _smoothcam(delta):
	currentpitch = lerp(currentpitch, pitch, 10 * delta)
	currentyaw = lerp(currentyaw, yaw, 10 * delta)
	currentradius = lerp(currentradius, radius, 5 * delta)
