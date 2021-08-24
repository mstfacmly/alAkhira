extends "res://scripts/ui_core.gd"

var default = 'Default'
var invert = 'Inverted'
var evil = 'The Devil\'s Configuration'
var xaxis = 'X Axis'
var yaxis = 'Y Axis'

func _set_sens(m,i):
	if i == 'x':
		global.js_x = m
	if i == 'y':
		global.js_y = m
	if i == 'm':
		global.mouse_sens = m

func _cam_x_btn(toggle):
	global.invert_x = toggle
	_cam_txt()
	
func _cam_y_btn(toggle):
	global.invert_y = toggle
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
	$cam_x/NAME.text = xaxis
	$cam_y/NAME.text = yaxis
	$cam_x_spd/NAME.text = xaxis+' Acceleration'
	$cam_y_spd/NAME.text = yaxis+' Acceleration'
	$cam_mouse/NAME.text = 'Mouse Acceleration'
	_cam_txt()
	$cam_x/btn.connect('toggled',self,'_cam_x_btn')
	$cam_y/btn.connect('toggled',self,'_cam_y_btn')
