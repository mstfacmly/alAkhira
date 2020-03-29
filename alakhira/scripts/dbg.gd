extends 'res://scripts/ui_core.gd'

func _dbg():
	var dbg_txt = get_node('../../left/dbg')
	$hlth_full/btn.set_text('Restore Full Health')
	$hlth_nil/btn.set_text('Drain All Health')
	
	if dbg_txt.is_visible() != false:
		$info/btn.set_text('On')
	else:
		$info/btn.set_text('Off')
	
	if az.hlth_drn != false:
		$hlth_drn/btn.set_text('Enabled')
	else:
		$hlth_drn/btn.set_text('Disabled')
	
	if az.get_node('body/Skeleton/targets/ptarget/Sprite3D').is_visible() != true:
		$col_ind/btn.set_text('Hide')
	else:
		$col_ind/btn.set_text('Show')

func _show_col():
	var col_ind = az.get_node('body/Skeleton/targets/ptarget/Sprite3D')
	
	if col_ind.is_visible() != true:
		col_ind.set_visible(true)
	else:
		col_ind.set_visible(false)

func _showhide():
	if is_visible() != true:
		set_visible(true)
		back = funcref(self, '_showhide')
	else:
		set_visible(false)

func _ready():
	if get_parent().get_node('menuList/dbg').visible:
		_dbg()
	else:
		pass
