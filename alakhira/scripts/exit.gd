extends Area

signal exit

onready var ui = $'../az/ui'

func _ready():
	# Connect signal body enter
	connect('body_entered', self, 'entered')
	connect('exit', ui, '_over')

func entered(body):
	if body.get_name() == 'az':
		emit_signal('exit')
#		print(get_signal_connection_list('exit'))
#		ui.get_node('right/menuList').hide()
#		ui.get_node('right/hlth').hide()
#		ui.get_node('left/org/over').show()
#		spi_az.show()
#		az.set_physics_process(false)
#		az.set_process(false)
#		az.get_node('cam').set_enabled(false)
#		Input.set_mouse_mode(0)