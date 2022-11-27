extends 'res://scripts/ui_core.gd'

func _over():
#	_grab_menu()
	$org/right/menuList.hide()
	$org/left/dbg.hide()
	$org/left/over.show()
	$org/right/hlth.hide()
	az.hide()
#	$'/root/scene/spi_az'.show()
	az.set_physics_process(false)
	az.set_process(false)
	az.get_node('cam').set_enabled(false)
	Input.set_mouse_mode(0)
