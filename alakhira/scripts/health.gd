extends ProgressBar

var health = 100
var div = 5
var healths
export var state = 'alive'
onready var shift = get_node("/root/scene/az/scripts/shift")

func _process(delta):
	var curr = shift.curr
	var rnd = delta * 5

	healths = set_value(health)
	var healthg = get_value()

	if health >=0 && curr == 'phys':
		health -= delta / div
	elif curr == 'spi':
		health -= rand_range(-rnd,rnd * 1.001)
	elif health == 0:
		state = 'dead'

func _ready():
	set_process(true)
