extends Node

var jscam_x = 2.3
var jscam_y = 1.3
var invert_x = false
var invert_y = false

func _ready():
	pass

func load_scene(new_scene):
	get_tree().change_scene(new_scene)