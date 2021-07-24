extends 'res://scripts/ui_core.gd'

onready var dbg_txt = find_parent('org').get_node('left/dbg_print')

var draining:bool = false

func _dbg():
	$hlth_full/btn.set_text('Restore Full Health')
	$hlth_nil/btn.set_text('Drain All Health')
	
	_health_drain()
	_show_collision(false)
	
	if !dbg_txt.is_visible():
		$info/btn.set_text('Off')
	else:
		$info/btn.set_text('On')
	
# warning-ignore:unused_argument
func _health_drain():
#	if az.hlth_drn != false:
	draining = false if draining else true
	print(draining)
	if draining:
		$hlth_drn/btn.set_text('Enabled')
	else:
		$hlth_drn/btn.set_text('Disabled')
	
# warning-ignore:unused_argument
func _show_collision(false:bool):
	if false:
		$col_ind/btn.set_text('Hide')
	else:
		$col_ind/btn.set_text('Show')
		#az.get_node('body/Skeleton/targets/ptarget/Sprite3D').visible

func old_show_col():
	var col_ind = az.get_node('body/Skeleton/targets/ptarget/Sprite3D')
	
	if col_ind.is_visible() != true:
		col_ind.set_visible(true)
	else:
		col_ind.set_visible(false)

func _ready():
	_dbg()
	_populate(self)
#	if az != null:
#	if get_parent().get_node('menuList/dbg').is_visible():
#		_health_drain()
#	else:
#		pass
