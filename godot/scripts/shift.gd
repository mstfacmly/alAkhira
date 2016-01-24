
extends Spatial

# NOTE: this scripts assumes that every _phys and _spir node has only children of the 
# same type or none and will also be switched

var DIFFUSE = FixedMaterial.PARAM_DIFFUSE
var MIX = FixedMaterial.BLEND_MODE_MIX
var ADD = Material.BLEND_MODE_ADD

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
var hidding = false

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
	set_fixed_process(true)
		
	paus = get_node("../pause")

	pass

func _input(ev):
#	if (JS.get_digital("bump_left") or (Input.is_action_pressed('magic')) && curr != 'spi':
	var cast = Input.is_action_pressed('cast') or Input.is_joy_button_pressed(0,4)
	var attack = Input.is_action_pressed('attack') or Input.is_joy_button_pressed(0,2)
	
	if cast && attack or paus.paused == true:
		if curr == 'phys':
			toggle(phys, spi)
			spir_peek(spi, false)
			curr = 'spi'
			env_transition(1)
		elif curr == 'spi':
			toggle(spi, phys)
			spir_peek(spi, true)
			curr = 'phys'
			env_transition(-1)
	elif cast and curr == 'phys' and overlay != 'spi':
		toggle(false, spi) #just show spi
		overlay = 'spi'
	elif hidding == false and curr == 'phys' and overlay == 'spi' and not cast :
		toggle(spi, false) #just hide spi
		overlay = 'none'


func _fixed_process(delta):
	if showing != false || hidding != false:
		interpolate(showing, hidding, delta)
	
func interpolate(show, hide, delta):
	var step_show
	var step_hide
	var color
	var target
	t += delta
	
	var step = t/transition_time
	
	if show != false:
		for mat in show['materials']:
			color = mat.get_parameter(DIFFUSE)
			target = Color(color.r, color.g, color.b, 1)
			step_show = color.linear_interpolate(target, step)
			mat.set_parameter(DIFFUSE, step_show)
				
	if hide != false:
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
	if b != false:
		for obj in b.nodes:
			obj.set_fixed_process(true)
			obj.show()
	showing = b
	hidding = a
	t = 0
	

func post_toggle(a, b):
	if a != false:
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
		
		if name.match('*_phys') or name.match('*_spi'):
			materials = get_materials(node)
			
			if name.match('*_phys'):
				phys['nodes'].push_back(node)
				phys['materials'] += materials
			elif name.match('*_spi'):
				spi['nodes'].push_back(node)
				spi['materials'] += materials
		elif node.is_type('AnimationPlayer'):
			if(name.match('PhysToSpir') or node.has_animation('PhysToSpir')):
				anim.push_back(node)
				
		elif node.get_child_count():
			traverse(node.get_children())
			
func get_next_material(root):
	var res = []
	var surfaces
	var mesh
	var mat
	if root.is_type('MeshInstance'):
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
	if root.is_type('MeshInstance'):
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
		if typeof(resource) == typeof(FixedMaterial) and not resource.get_rid() in record:
			new.push_back(resource)
			record.push_back(resource.get_rid())
	store['materials'] = new
	
	
	
	
