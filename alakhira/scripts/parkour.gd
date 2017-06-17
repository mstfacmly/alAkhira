extends "res://scripts/player_K.gd"

func check_parkour():
	var ds = get_world().get_direct_space_state();
	var parkour_detect = 80;
	var ppos = mesh.get_global_transform().origin;
	var ptarget = mesh.get_node("ptarget").get_global_transform().origin;
	var ledgecol = mesh.get_node("ledgecol").get_global_transform()origin;
	var delta = ptarget - ppos;

	var col_right = ds.intersect_ray(ppos,ptarget+Matrix3(up,deg2rad(parkour_detect)).xform(delta),collision_exception)
	var col = ds.intersect_ray(ppos,ptarget+delta,collision_exception)
	var col_left = ds.intersect_ray(ppos,ptarget+Matrix3(up,deg2rad(-parkour_detect)).xform(delta),collision_exception)

	if (!col_left.empty() && col_right.empty()):
		col_result = "left"
		return col_result
	elif (!col_right.empty() && col_left.empty()):
		col_result = "right"
		return col_result
	elif (!col.empty() && !col_left.empty() && col_right.empty()):
		col_result = "left"
		return col_result
	elif (!col.empty() && !col_right.empty() && col_left.empty()):
		col_result = "right"
		return col_result
	elif (!col.empty()): # && col_left.empty() && col_right.empty()):
		col_result = "front"
		return col_result
	else:
		col_result = "nothing";
		return col_result

func _process(delta):
	check_parkour();
