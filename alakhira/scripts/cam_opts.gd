extends "res://scripts/ui_core.gd"

var standard = 'Standard'
var invert = 'Inverted'
var evil = 'The Devil\'s Configuration'

func _set_sens(i,i):
	if i == 'x':
		global.jscam_x = $cam_x_spd/slide.value
	if i == 'y':
		global.jscam_y = $cam_y_spd/slide.value
	if i == 'm':
		global.mouse_sens = $cam_mouse/slide.value

func _cam_btn(btn):
	if btn == 'x':
		if global.invert_x != true:
			$cam_x/btn.set_text(invert)
			global.invert_x = true
		elif global.invert_x != false:
			$cam_x/btn.set_text(standard)
			global.invert_x = false
	if btn == 'y':
		if global.invert_y != true:
			$cam_y/btn.set_text(evil)
			global.invert_y = true
		elif global.invert_y != false:
			$cam_y/btn.set_text(standard)
			global.invert_y = false

func _showhide():
	if is_visible() != true:
		set_visible(true)
		back = funcref(self, '_showhide')
	else:
		set_visible(false)
	
	_grab_menu()

func _ready():
	if global.invert_x != true:
		$cam_x/btn.set_text(standard)
	else:
		$cam_x/btn.set_text(invert)

	if global.invert_y != true:
		$cam_y/btn.set_text(standard)
	else:
		$cam_y/btn.set_text(evil)
