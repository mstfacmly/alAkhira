extends Node

const version = '0.11.3'
var mouse_sens = 0.3
var jscam_x = 2.3
var jscam_y = 1.3
var invert_x = false
var invert_y = false

const AZ = preload('res://player/az.tscn')
const UI = preload('res://assets/ui/ui.tscn')

func _ready():
	pass

func load_scene(new_scene):
	get_tree().change_scene(new_scene)