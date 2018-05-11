extends Node

func _ready():
	pass
func load_scene(new_scene):
	get_tree().change_scene(new_scene)