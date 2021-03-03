extends Node

const version = '0.12'
var mouse_sens = 0.3
var js_x = 2.3
var js_y = 1.3
var invert_x = false
var invert_y = false

#const AZ = preload('res://player/az.tscn')
const UI = preload('res://assets/ui/ui.tscn')

func _ready():
	Input.add_joy_mapping("030000005e040000ea02000008040000,Microsoft Xbox One S pad - Wired,a:b0,b:b1,back:b6,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,guide:b8,leftshoulder:b4,leftstick:b9,lefttrigger:a2,leftx:a0,lefty:a1,rightshoulder:b5,rightstick:b10,righttrigger:a5,rightx:a3,righty:a4,start:b7,x:b2,y:b3,platform:Linux", true)

func load_scene(new_scene):
	get_tree().change_scene(new_scene)
