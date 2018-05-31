extends Node

var jscam_x = 2.3
var jscam_y = 1.3

func _ready():
	pass
func load_scene(new_scene):
	get_tree().change_scene(new_scene)