extends "res://scripts/ui_core.gd"

func _opts_container():
#	_load_cfg()
	pass

func _opts_menu():
	var menu = get_parent().get_node('menuList')
	
	set_visible(!visible)
	menu.set_visible(!menu.visible)
