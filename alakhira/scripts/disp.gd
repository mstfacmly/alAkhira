extends "res://scripts/ui_core.gd"

var ratio_div
const ratio = [ '4:3', '16:9', '16:10' ]
const aalist = [ 'Disabled', '2x', '4x', '8x', '16x' ]

const disp_rez = [
	320, 
	640,
	800,
	1024,
	1280,
	1366,
	1600,
	1920,
	2560,
	3200,
	3840
]

func _fs_set():
	if !OS.is_window_fullscreen():
		$fs/btn.text = 'On'
	else:
		$fs/btn.text = 'Off'

func _vsync_set():
	if OS.is_vsync_enabled() == true:
		$vsync/btn.text = 'On'
	else:
		$vsync/btn.text = 'Off'

func _ratio_select(ID):
	if ID == 0:
		ratio_div = 1.333333333
	elif ID == 1:
		ratio_div = 1.777777778
	elif ID == 2:
		ratio_div = 1.6
	
	_res_calc()

func _res_calc():
	#var i = 0
	$res/res.clear()
	for x in disp_rez:
		var y = x / ratio_div
		$res/res.add_item(str(x) + ' x ' + str(y))

func _res_select(ID):
	OS.set_window_size(Vector2(disp_rez[ID], disp_rez[ID] / ratio_div))
	
	if OS.window_fullscreen != true:
		pass
	else:
		OS.set_window_fullscreen(false)
		OS.set_window_fullscreen(true)

func _fsaa_select(ID):
	get_viewport().msaa = ID

func _ready():
	_fs_set()
	_vsync_set()
	_ratio_select($ratio/ratio.get_selected_id())
	
	for r in ratio:
		$ratio/ratio.add_item(str(r))
	for i in aalist:
		$fsaa/aa.add_item(i)
		
#	$res/res.connect('selected', self, '_res_calc')
