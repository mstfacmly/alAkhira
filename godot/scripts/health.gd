extends ProgressBar

var health = 100
var div = 5
var healths
var isdead = false
onready var shift = get_node("../shift")
var curr

func _process(delta):
	curr = shift.curr
	print("curr : ",curr)

	healths = set_value(health)
	var healthg = get_value()

	if health >=0 && curr == 'phys':
		health -= delta / div
	elif curr == 'spi':
		health == health 
	elif health == 0:
		isdead = true


func _ready():
	set_process(true)