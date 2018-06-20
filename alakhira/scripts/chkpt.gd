extends Area

signal exit

onready var chkpt = $'/root/scene/chkpt'
onready var ui = $'/root/scene/az/ui'

func _ready():
	# Connect signal body enter
	connect('body_entered', self, 'entered')
	connect('exit', ui, '_over')

func entered(body):
	if body.get_name() == 'az':
		if get_name() == 'exit':
			emit_signal('exit')
		else:
			# Set checkpoint position to this area position
			chkpt.global_transform = global_transform
#			print(global_transform)
			body.heal(5)