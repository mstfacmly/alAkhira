extends "res://scripts/ui_core.gd"

var div
const ratio = { '4:3':1.333333333, '16:9':1.777777778, '16:10':1.6 }
const aalist = [ 'Disabled', '2x', '4x', '8x', '16x' ]

const disp_rez = [ 
	320, 640, 800, 1024,
	1280, 1366, 1600, 1920,
	2560, 3200, 3840 ]

func _fs_set():
	$fs/btn.set_text(onOff[int(OS.window_fullscreen)])

func _vsync_set():
	$vsync/btn.set_text(onOff[int(OS.vsync_enabled)])

func _fxaa_set():
	$fxaa/btn.set_text(onOff[int(get_viewport().fxaa)])

func _ratio_select(ID):
	_res_calc(ratio[ratio.keys()[ID]])
	div = ratio[ratio.keys()[ID]]

func _res_calc(ratio_div):
	$res/res.clear()
	for x in disp_rez:
		$res/res.add_item(str(x) + ' x ' + str(round(x / ratio_div)))

func _res_select(ID):
	OS.set_window_size(Vector2(disp_rez[ID], disp_rez[ID] / div))

func _msaa_select(ID):
	get_viewport().msaa = ID

func _list_AA():
	for i in aalist:
		$msaa/aa.add_item(i)

func _ready():
	_fs_set()
	_vsync_set()
	_fxaa_set()
	_list_AA()
	_ratio_select($ratio/ratio.get_selected_id())
	
	for r in ratio:
		$ratio/ratio.add_item(str(r))
	
#	$res/res.connect('selected', self, '_res_calc')
