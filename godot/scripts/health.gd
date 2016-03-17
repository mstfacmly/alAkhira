extends ProgressBar

var health = 100
var div = 5
var healths
var isdead = false
onready var shift = get_node("../shift")

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
		isdead = true

func _ready():
	set_process(true)