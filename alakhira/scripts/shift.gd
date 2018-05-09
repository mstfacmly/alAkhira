extends Spatial

# NOTE: this scripts assumes that every _phys and _spi node has only children of the
# same type or none and will also be switched

var DIFFUSE = SpatialMaterial.DIFFUSE_LAMBERT
var MIX = SpatialMaterial.BLEND_MODE_MIX
var ADD = SpatialMaterial.BLEND_MODE_ADD

enum states {ALIVE,DEAD}
var state

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
onready var root = get_node('/root')
#onready var env = $env

var showing = false
var hiding = false
var shifting = false

var t
var transition_time = 0.5

func _ready():

#	var root = get_node('/root/')
	traverse(root.get_children())
	unique_materials(phys)
	unique_materials(spi)

	#initialize on phys
	peek(spi, true)
	toggle(spi, phys)

	pass

func _input(ev):
	var cast = Input.is_action_pressed("cast")
	var attack = Input.is_action_just_pressed("arm_l")
	var shift = cast && attack

	if shift && state != DEAD:
#		shifting = true
		if curr == 'phys':
			toggle(phys, spi)
			peek(spi, false)
			curr = 'spi'
			env_transition(1)
#			env_spir()
			shifting = true
		elif curr == 'spi':
			toggle(spi, phys)
			peek(spi, true)
			curr = 'phys'
			env_transition(-1)
#			env_phys()
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


func peek(store, activate):
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
			obj.set_physics_process(true)
			obj.show()
	showing = b
	hiding = a
	t = 0


func post_toggle(a, b):
	if a:
		for obj in a.nodes:
			obj.set_physics_process(false)
			obj.hide()
	showing = false
	hiding = false

func env_transition(speed):
	for a in anim:
		if(a.get_name() == 'shift'):
			var animList = a.get_animation_list()
			for b in animList:
				a.play(b,  -1, speed, (speed < 0))
		else:
			a.play('shift', -1, speed, (speed < 0))

func traverse(nodes):
	var nm = ''
	var materials
	for node in nodes:
		nm = node.get_name()

		if nm.matchn('*_phys') or nm.matchn('*_spi'):
			materials = get_materials(node)

			if nm.matchn('*_phys'):
				phys['nodes'].push_back(node)
				phys['materials'] += materials
			elif nm.matchn('*_spi'):
				spi['nodes'].push_back(node)
				spi['materials'] += materials
		elif node.is_class('AnimationPlayer'):
			if(nm.matchn('phystospir') or node.has_animation('shift')):
				anim.push_back(node)

		elif node.get_child_count():
			traverse(node.get_children())

func get_next_material(root):
	var res = []
	var surfaces
	var mesh
	
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
	var nm = int(str(root))
	
	if root.is_class('MeshInstance'):
		var mat = root.get_surface_material(nm)
		if mat == null:
			var mesh = root.get_mesh()
			var surfaces = mesh.get_surface_count()
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
		if typeof(resource) == TYPE_AABB and not resource.get_rid() in record:
			new.push_back(resource)
			record.push_back(resource.get_rid())
	store['materials'] = new

#func env_phys():
#		env.set_fog_enabled(false)
#		env.set_glow_enabled(false) 
#		env.adjustment_brightness = 1
#		env.adjustment_contrast = 0.84
#		env.adjustment_saturation = 0.84

#func env_spir():
#		env.set_fog_enabled(true)
#		env.set_glow_enabled(true)
#		env.adjustment_brightness = 0.9
#		env.adjustment_contrast = 1.1
#		env.adjustment_saturation = 0.11