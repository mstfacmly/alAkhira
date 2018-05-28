extends Area

onready var az = $'../az'
onready var spi_az = $'../az_spi'
onready var ui = az.get_node('ui/org')
onready var over = ui.get_node('center/over')

func _ready():
	# Connect signal body enter
	connect('body_entered', self, 'exit')
	
func exit(body):
#	var pause = az.get_node("ui/pause")
	if body.get_name() == "az":
		ui.get_node('right/menuList').hide()
		ui.get_node('right/hlth').hide()
		ui.get_node('center/over').show()
		spi_az.show()
		az.set_physics_process(false)
		az.set_process(false)
		az.get_node('cam').set_enabled(false)
		Input.set_mouse_mode(0)