extends 'res://scripts/ui_core.gd'

onready var dbg_txt = find_parent('org').get_node('left/dbg_print')

var draining setget _set_draining
var col_show setget _show_collision

func _set_draining(active:bool):
	draining = active
	_health_drain()

"""func get_draining():
	return draining"""

func _dbg():
	$hlth_full/btn.set_text('Restore Full Health')
	$hlth_nil/btn.set_text('Drain All Health')
	
	_set_draining(1)
	_show_collision(1)

func _dbg_txt_set():
	$info/btn.set_text(onOff[int(dbg_txt.visible)])

func _health_drain():
	var status = [ 'Disabled' , 'Enabled' ]
	$hlth_drn/btn.set_text(status[int(draining)])
	
func _show_collision(hide:bool):
	var showHide = [ 'Show' , 'Hide' ]
	col_show = hide
	$col_ind/btn.set_text(showHide[int(hide)])

func _ready():
	az = get_parent().get_parent().get_parent().get_parent()
	if az.name != 'az':
		pass
	else:
		_dbg()
		_dbg_txt_set()
