
extends Spatial

# NOTE: this scripts assumes that every _phys and _spir node has only children of the 
# same type or none and will also be switched

var phys = []
var spi = []
var curr = 'spi'

func _ready():
	
	traverse(get_children())
	
	#initialize on spi
	toggle(phys, spi)
	set_process_input(true)
		
	pass

func _input(ev):
	if Input.is_action_pressed('magic') && curr != 'spi':
		toggle(phys, spi)
		curr = 'spi'
	elif Input.is_action_pressed('attack') && curr !='phys':
		toggle(spi, phys)
		curr = 'phys'

#switch from a to b
func toggle(a, b):
	for node in a:
		node.set_fixed_process(false)
		node.hide()
	for node in b:
		node.set_fixed_process(true)
		node.show()

func traverse(nodes):
	var name = ''
	
	for node in nodes:
		
		name = node.get_name()
		
		if name.match('*_phys'):
			print('_phys found')
			phys.append(node)
		elif name.match('*_spi'):
			spi.append(node)
			print('_spir found')
		elif node.get_child_count():
			traverse(node.get_children())