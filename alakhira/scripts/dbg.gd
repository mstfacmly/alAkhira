extends 'res://scripts/ui_core.gd'

onready var dbg_txt = find_parent('org').get_node('left/dbg_print')

var draining setget set_draining
var col_show setget _show_collision

func set_draining(active:bool):
	draining = active
	_health_drain()

"""func get_draining():
	return draining"""

func _dbg():
	$hlth_full/btn.set_text('Restore Full Health')
	$hlth_nil/btn.set_text('Drain All Health')
	
	set_draining(1)
	_show_collision(0)

func _dbg_set():
	if !dbg_txt.is_visible():
		$info/btn.set_text('Off')
	else:
		$info/btn.set_text('On')
	
func _health_drain():
	if draining == true:
		$hlth_drn/btn.set_text('Enabled')
	else:
		$hlth_drn/btn.set_text('Disabled')
	
func _show_collision(hide:bool):
	col_show = hide
	if hide:
		$col_ind/btn.set_text('Hide')
	else:
		$col_ind/btn.set_text('Show')

func old_show_col():
	var col_ind = az.get_node('body/Skeleton/targets/ptarget/Sprite3D')
	
	if col_ind.is_visible() != true:
		col_ind.set_visible(true)
	else:
		col_ind.set_visible(false)

func _ready():
#	print(find_node('/Skeleton/targets/ptarget/Sprite3D'))
#	if get_parent().name != az:
#		pass
#	else:
	_dbg_set()
	_dbg()
