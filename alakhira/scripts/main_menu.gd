extends 'res://scripts/ui_core.gd'

func _ready():
	connect("draw",self,"_grab_menu")
