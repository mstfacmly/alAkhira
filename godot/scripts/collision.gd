extends StaticBody

func _fixed_process(delta):
#		drive(delta)
		if is_colliding():
			if get_collider().get_name() == "player":
					collision_action()
				
func collision_action():
		get_node("player").trigger()