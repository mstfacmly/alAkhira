extends StaticBody

var thresholdUp = Vector3(0, 10, 0)
var collider
onready var player = get_node("/root/scene/player")

func collide(_collider, space):
	collider = _collider
	var rayXZ = collider.get_translation() + collider.facing_dir
	var ledgeFloor = space.intersect_ray(rayXZ + thresholdUp, rayXZ - thresholdUp * 2, [collider])
	if !ledgeFloor.empty() and player.falling == true:
		collider.set_axis_lock(2)
		collider.set_translation(ledgeFloor.position)
		set_process_input(true)
