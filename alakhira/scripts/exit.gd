extends Area

onready var az = $'../az'
onready var spi_az = $'../az_spi'
onready var ui = az.get_node('ui/org')
onready var over = ui.get_node('center/container/over')

func _ready():
	# Connect signal body enter
	print(ui)
	connect('body_entered', self, 'exit')
	
func exit(body):
#	var pause = az.get_node("ui/pause")
	if body.get_name() == "az":
		ui.get_node('right/menuList').hide()
		ui.get_node('right/hlth').hide()
		ui.get_node('center').show()
		ui.get_node('center/container/over').show()
		over.get_node('thanks').show()
		over.get_node('lune_site').show()
		over.get_node('quit').show()
#		az.hide()
		spi_az.show()
		az.set_physics_process(false)
		az.set_process(false)
		az.get_node('cam').set_enabled(false)
		Input.set_mouse_mode(0)