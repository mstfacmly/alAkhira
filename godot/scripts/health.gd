extends ProgressBar

var health = 100
var healths
var isdead = false

func _process(delta):
#	print("health : ",health)
#	print("time : ",t)

	healths = set_value(health)
	var healthg = get_value()

	if health >= 0:
		health -= delta / 5
	elif health == 0:
		isdead = true


func _ready():
	set_process(true)