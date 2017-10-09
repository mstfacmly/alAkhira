
extends Spatial

# NOTE: this scripts assumes that every _phys and _spir node has only children of the
# same type or none and will also be switched

var DIFFUSE = SpatialMaterial.DIFFUSE_LAMBERT
var MIX = SpatialMaterial.BLEND_MODE_MIX
var ADD = SpatialMaterial.BLEND_MODE_ADD

var phys = {
	'materials': [],
	'nodes': []
}
var spi = {
	'materials': [],
	'nodes': []
}
var anim = []
var players = []
onready var az = get_node("/root/scene/az/scripts/shift")
#var curr
var overlay = 'none'

var showing = false
var hidding = false

var t
var transition_time = 0.5

onready var root = get_node("/root/")

#onready var pause = get_parent().get_node("../pause")

func _ready():

	traverse(root.get_children())
	unique_materials(phys)
	unique_materials(spi)

	#initialize on phys
	toggle(spi, phys)

	set_process_input(true)
#	set_fixed_process(true)
#	set_process(true)

	pass

func _input(ev):
	var pause = ev.is_action_pressed("pause") && !ev.is_echo()

	if pause:
		if az.curr == 'phys':
			_phys()
		elif az.curr == 'spi':
			_spi()

func _phys():
	toggle(phys, spi)
	az.curr = 'spi'
	env_transition(1)

func _spi():
	toggle(spi, phys)
	az.curr = 'phys'
	env_transition(-1)

func _fixed_process(delta):
	if showing || hidding:
		interpolate(showing, hidding, delta)

func interpolate(show, hide, delta):
	var step_show
	var step_hide
	var color
	var target
	t += delta

	var step = t/transition_time

	if show:
		for mat in show['materials']:
			color = mat.get_parameter(DIFFUSE)
			target = Color(color.r, color.g, color.b, 1)
			step_show = color.linear_interpolate(target, step)
			mat.set_parameter(DIFFUSE, step_show)

	if hide:
		for mat in hide['materials']:
			color = mat.get_parameter(DIFFUSE)
			target = Color(color.r, color.g, color.b, 0)
			step_hide = color.linear_interpolate(target, step)
			mat.set_parameter(DIFFUSE, step_hide)

	if t >= transition_time:
		post_toggle(hide, show)

#switch from a to b
func toggle(a, b):
	if b:
		for obj in b.nodes:
			obj.set_fixed_process(true)
			obj.show()
	showing = b
	hidding = a
	t = 0

func post_toggle(a, b):
	if a:
		for obj in a.nodes:
			obj.set_fixed_process(false)
			obj.hide()
	showing = false
	hidding = false

func env_transition(speed):
	for a in anim:
		if(a.get_name() == 'PhysToSpir'):
			var animList = a.get_animation_list()
			for b in animList:
				a.play(b,  -1, speed, (speed < 0))
			print("PhysToSpir found")
		else:
			a.play('PhysToSpir', -1, speed, (speed < 0))

func traverse(nodes):
	var name = ''
	var materials
	for node in nodes:
		name = node.get_name()

		if name.matchn('*_phys') or name.matchn('*_spi'):
			materials = get_materials(node)

			if name.matchn('*_phys'):
				phys['nodes'].push_back(node)
				phys['materials'] += materials
			elif name.matchn('*_spi'):
				spi['nodes'].push_back(node)
				spi['materials'] += materials
		elif node.is_class('AnimationPlayer'):
			if(name.matchn('PhysToSpir') or node.has_animation('PhysToSpir')):
				anim.push_back(node)

		elif node.get_child_count():
			traverse(node.get_children())

func get_next_material(root):
	var res = []
	var surfaces
	var mesh
	var mat
	if root.is_class('MeshInstance'):
		mesh = root.get_mesh()
		surfaces = mesh.get_surface_count()
		for i in range(surfaces):
			res.push_back(mesh.surface_get_material(i))

	var nodes = root.get_children()
	for node in nodes :
		res.append(get_materials(node))
	return res

func get_materials(root):
	var res = []
	var surfaces
	var mesh
	var mat
	if root.is_class('MeshInstance'):
		mat = root.get_material_override()
		if mat == null:
			mesh = root.get_mesh()
			surfaces = mesh.get_surface_count()
			for i in range(surfaces):
				res.push_back(mesh.surface_get_material(i))
		else:
			res.push_back(mat)

	var nodes = root.get_children()
	for node in nodes :
		res += get_materials(node)
	return res

func unique_materials(store):
	var record = []
	var new = []
	var resource
	for i in range(store['materials'].size()):
		resource = store['materials'][i]
		if typeof(resource) == typeof(ShaderMaterial) and not resource.get_rid() in record:
			new.push_back(resource)
			record.push_back(resource.get_rid())
	store['materials'] = new
