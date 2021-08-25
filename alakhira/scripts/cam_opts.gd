extends "res://scripts/ui_core.gd"

export var default = 'Default'
export var invert = 'Inverted'
export var evil = 'The Devil\'s Configuration'
export var xaxis = 'X Axis'
export var yaxis = 'Y Axis'

var cam_text = [default,evil]

func _set_sens_x(x):
	global.js_x = x

func _set_sens_y(y):
	global.js_y = y

func _set_sens_mouse(m):
	global.mouse_sens = m

func _cam_x_btn(toggle):
	global.invert_x = toggle
	_cam_txt()
	
func _cam_y_btn(toggle):
	global.invert_y = toggle
	_cam_txt()
	
func _cam_txt():
	$cam_x/btn.set_text(cam_text[int(global.invert_x)])
	$cam_y/btn.set_text(cam_text[int(global.invert_y)])

func _ready():
	$cam_x/NAME.text = xaxis
	$cam_y/NAME.text = yaxis
	$cam_spd/js_x/NAME.text = xaxis+' Acceleration'
	$cam_spd/js_y/NAME.text = yaxis+' Acceleration'
	$cam_spd/mouse/NAME.text = 'Mouse Sensitivity'
	$cam_spd/js_x/slide.value = global.js_x
	$cam_spd/js_y/slide.value = global.js_y
	$cam_spd/mouse/slide.value = global.mouse_sens

	_cam_txt()
	$cam_x/btn.connect('toggled',self,'_cam_x_btn')
	$cam_y/btn.connect('toggled',self,'_cam_y_btn')
