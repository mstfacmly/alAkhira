extends "res://scripts/ui_core.gd"

func _opts_container():
#	_load_cfg()
	pass

func _opts_menu():
	#var opts = self
	var menu = get_parent().get_node('menuList')
	
	if !is_visible():
		set_visible(true)
#		back = funcref(self, '_opts_menu')
	else:
		set_visible(false)
		if az != null:
			back = funcref(self, '_pause_menu')
		else:
			back = funcref(self, '_main_menu')
	
	menu.set_visible(!menu.visible)
