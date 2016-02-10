extends StaticBody

var thresholdUp = Vector3(0, 10, 0)
var collider
onready var player = get_node("/root/scene/player")

func _input(ev):
	print('a')
	if ev.is_action('move_forward') or ev.is_action('move_backwards'):
		set_process_input(false)
		collider.set_axis_lock(0)
		player.hspeed == 0
		print('b')
	if ev.is_action('move_forward') and !ev.is_echo():
		collider.apply_impulse(collider.get_translation() + Vector3(0, -0.2, 0), collider.get_translation() + Vector3(0, 10, 2))

func collide(_collider, space):
	collider = _collider
	var rayXZ = collider.get_translation() + collider.facing_dir
	var ledgeFloor = space.intersect_ray(rayXZ + thresholdUp, rayXZ - thresholdUp * 2, [collider])
	if !ledgeFloor.empty() and player.falling == true:
		collider.set_axis_lock(2)
		collider.set_translation(ledgeFloor.position)
		set_process_input(true)
