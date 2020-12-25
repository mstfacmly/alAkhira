extends Spatial

onready var ptarget = get_parent().get_node('body/Skeleton/targets/ptarget')
onready var target = get_parent().get_global_transform().origin

var pitch = 0.0
var yaw = 0.0
var cpitch = 0.0
var cyaw = 0.0
var currentradius = 4.0
var radius = 4.0
var pos = Vector3()
var smooth_movement = false
export var distance = Vector2(0.5,7.2)
export var view_sensitivity = 1
export var smooth_lerp = 6.16
export var pitch_minmax = Vector2(-28, 69)

const DEADZONE = 0.1

func _ready():
	add_to_group('camera')
	smooth_movement = true
	add_exception(get_parent())
	add_exception(self)

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

func clear_exception():
	$cam.clear_exceptions()

func add_exception(node):
	$cam.add_exception(node)

func _input(ev):
	if ev is InputEventMouseMotion:
		pitch += clamp(ev.relative.y * view_sensitivity,pitch_minmax.x,pitch_minmax.y)
		if smooth_movement:
			yaw += ev.relative.x * view_sensitivity
		else:
			yaw += fmod(ev.relative.x * view_sensitivity,360)
			currentradius = radius
	
	if ev is InputEventJoypadMotion:
		js_input()

func js_input():
	var Jx = Input.get_joy_axis(0,2)
	var Jy = Input.get_joy_axis(0,3)

	if abs(Jy) >= DEADZONE:
		pitch -= max(min((Jy * (view_sensitivity * global.js_y) ),pitch_minmax.x),pitch_minmax.y)
	
	if abs(Jx) >= DEADZONE:
		if smooth_movement:
			yaw += (Jx * (view_sensitivity * global.js_x))
		else:
			yaw += fmod((Jx * (view_sensitivity * global.js_x)),360)
			currentradius = radius

func update():
	var target_pos = ptarget.get_global_transform().origin
	pos = $pivot.get_global_transform().origin
	var delta = pos - target_pos #regular delta follow

	if smooth_movement:
		pos.x += currentradius * sin(deg2rad(cyaw)) * cos(deg2rad(cpitch))
		pos.y += currentradius * sin(deg2rad(cpitch))
		pos.z += currentradius * cos(deg2rad(cyaw)) * cos(deg2rad(cpitch))
	else:
		pos.x += currentradius * sin(deg2rad(yaw)) * cos(deg2rad(pitch))
		pos.y += currentradius * sin(deg2rad(pitch))
		pos.z += currentradius * cos(deg2rad(yaw)) * cos(deg2rad(pitch))

	if (delta.length() < distance.x):
		delta = delta.normalized() * distance.x
	elif (delta.length() > distance.y):
		delta = delta.normalized() * distance.y
	
	$cam.look_at_from_position(pos, $pivot.get_global_transform().origin, Vector3.UP)


func _process(delta):
	if $cam.get_projection() == Camera.PROJECTION_PERSPECTIVE:
		$cam.set_perspective(lerp($cam.get_fov(), $cam.fov, smooth_lerp * delta), $cam.get_znear(), $cam.get_zfar())

	if smooth_movement:
		cpitch = lerp(cpitch, pitch, 10 * delta)
		cyaw = lerp(cyaw, yaw, 10 * delta)
		currentradius = lerp(currentradius, radius, 5 * delta)

#	if ds != null:
#		ray_result = ds.intersect_ray($cam.get_global_transform().origin, pos, collision_exception)

	update()
