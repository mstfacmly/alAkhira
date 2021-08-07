extends "res://scripts/ui_core.gd"

export var default = 'Default'
export var invert = 'Inverted'
export var evil = 'The Devil\'s Configuration'

func _set_sens(m,i):
	if i == 'x':
		global.js_x = m
	if i == 'y':
		global.js_y = m
	if i == 'm':
		global.mouse_sens = m

func _cam_x_btn():
	global.invert_x = false if global.invert_x else true
	_cam_txt()
	
func _cam_y_btn():
	global.invert_y = false if global.invert_y else true
	_cam_txt()
	
func _cam_txt():
	if global.invert_x == true:
		$cam_x/btn.set_text(invert)
	else:
		$cam_x/btn.set_text(default)
	
	if global.invert_y == true:
		$cam_y/btn.set_text(evil)
	else:
		$cam_y/btn.set_text(default)

func _ready():
	_cam_txt()
