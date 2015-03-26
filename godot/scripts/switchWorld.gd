
extends Spatial

# NOTE: this scripts assumes that every _phys and _spir node has only children of the 
# same type or none and will also be switched

var phys = []
var spi = []
var curr = 'phys'
var overlay = 'none'
var environment = {}
var JS

var overlay_mat = load("res://env/materials/spi_overlay.mtl") 

func _ready():
	JS = get_node("/root/SUTjoystick")
	get_envs(get_node('env'))
	traverse(get_children())
	
	#initialize on phys
	toggle(spi, phys)
	override_mat(spi, overlay_mat)
	get_node('env').set_environment(environment.phys)
	
	set_process_input(true)
		
	pass

func _input(ev):
#	if (JS.get_digital("bump_left") or (Input.is_action_pressed('magic')) && curr != 'spi':
		
	if curr == 'phys' and (JS.get_digital("bump_left") or Input.is_action_pressed('magic')) and overlay != 'spi':
		toggle(false, spi) #just show spi
		overlay = 'spi'
	elif curr == 'phys' and overlay == 'spi':
		toggle(spi, false) #just hide spi
		overlay = 'none'	
		
	if (JS.get_digital("bump_left") and (JS.get_digital("action_3")) or
	 (Input.is_action_pressed('magic')) and Input.is_action_pressed('attack')) && curr != 'spi':
		toggle(phys, spi)
		override_mat(spi, null)
		curr = 'spi'
		get_node('env').set_environment(environment.spi)
	elif (JS.get_digital("bump_left") and (JS.get_digital("action_3")) or 
	(Input.is_action_pressed('magic')) and Input.is_action_pressed('attack')) && curr !='phys':
		toggle(spi, phys)
		override_mat(spi, overlay_mat)
		curr = 'phys'
		get_node('env').set_environment(environment.phys)


func override_mat(store, mat):
	for obj in store :
		for mesh in obj.meshes:
			mesh.set_material_override(mat)
		
#switch from a to b
func toggle(a, b):
	if a != false:
		for obj in a:
			obj.node.set_fixed_process(false)
			obj.node.hide()
	if b != false:
		for obj in b:
			obj.node.set_fixed_process(true)
			obj.node.show()
		

func get_envs(root) : 
	var envs = root.get_children()
	for env in envs :
		environment[env.get_name().replace('env_', '')] = env.environment
		root.remove_child(env)

func traverse(nodes):
	var name = ''
	for node in nodes:
		name = node.get_name()
		if name.match('*_phys'):
			var obj = {}
			obj['node'] = node
			phys.append(obj)
		elif name.match('*_spi'):
			var obj = {}
			obj['node'] = node
			obj['meshes'] = get_mesh_instances(node)
			spi.append(obj)
		elif node.get_child_count():
			traverse(node.get_children())
			

func get_mesh_instances(root):
	var res = []
	if root.is_type('MeshInstance'):
		res.append(root)
		
	var nodes = root.get_children()
	for node in nodes : 
		if node.get_child_count():
			res += get_mesh_instances(node)
		elif node.is_type('MeshInstance'):
			res.append(node)
	return res
	
	
	