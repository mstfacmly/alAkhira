
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
var curr = 'phys'
var overlay = 'none'

var showing = false
var hiding = false
var shifting = false

var t
var transition_time = 0.5

var paus

func _ready():

	var root = get_node('/root/')
	traverse(root.get_children())
	unique_materials(phys)
	unique_materials(spi)

	#initialize on phys
	spir_peek(spi, true)
	toggle(spi, phys)


	set_process_input(true)


	pass

func _input(ev):
	var cast = Input.is_action_pressed("cast")
	var attack = Input.is_action_pressed("arm_l")
	var shift = cast && attack

	if shift:
		if curr == 'phys':
			toggle(phys, spi)
			spir_peek(spi, false)
			curr = 'spi'
			env_transition(1)
			shifting = true
		elif curr == 'spi':
			toggle(spi, phys)
			spir_peek(spi, true)
			curr = 'phys'
			env_transition(-1)
			shifting = false
	elif cast and curr == 'phys' and overlay != 'spi':
		toggle(false, spi) #just show spi
		overlay = 'spi'
	elif !hiding and curr == 'phys' and overlay == 'spi' and not cast :
		toggle(spi, false) #just hide spi
		overlay = 'none'

func _physics_process(delta):
	if showing || hiding:
		interpolate(showing, hiding, delta)

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


func spir_peek(store, activate):
	if activate:
		for mat in store['materials'] :
			mat.set_blend_mode(ADD)
	else:
		for mat in store['materials'] :
			mat.set_blend_mode(MIX)

#switch from a to b
func toggle(a, b):
	if b:
		for obj in b.nodes:
			obj.set_fixed_process(true)
			obj.show()
	showing = b
	hiding = a
	t = 0


func post_toggle(a, b):
	if a:
		for obj in a.nodes:
			obj.set_fixed_process(false)
			obj.hide()
	showing = false
	hiding = false

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
	var nm = ''
	var materials
	for node in nodes:
		nm = node.get_name()

		if name.matchn('*_phys') or name.matchn('*_spi'):
			materials = get_materials(node)

			if nm.matchn('*_phys'):
				phys['nodes'].push_back(node)
				phys['materials'] += materials
			elif name.matchn('*_spi'):
				spi['nodes'].push_back(node)
				spi['materials'] += materials
		elif node.is_class('AnimationPlayer'):
			if(nm.matchn('phystospir') or node.has_animation('PhysToSpir')):
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
		if typeof(resource) == typeof(Material) and not resource.get_rid() in record:
			new.push_back(resource)
			record.push_back(resource.get_rid())
	store['materials'] = new
