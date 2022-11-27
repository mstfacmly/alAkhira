extends Spatial

#var shifter = 
onready var dest = get_children()
onready var room = $'/root/scene'
#onready var anim = find_node('AnimationPlayer')
var anim
#var spd = 2
var transdiv

func _physics_process(_dt):
#	if shifter.transit:
#		if shifter.curr == 'spi':
#			_transit(1)
#		elif shifter.curr == 'phys':
#			_transit(-100)
	if anim != null:
		if anim.get_current_animation_position() <= 0.05:
			room.set_visible(abs(transdiv))
			set_visible(transdiv + 1)

func _transit(spd):
	var spdivup = ceil(spd / abs(spd + 1))

	if spd >= 1:
		transdiv = floor(spd / (spd + 1))
	elif spd <= -1:
		transdiv = ceil(spd / abs(spd + 1))

	for i in dest:
		if i.has_node('AnimationPlayer'):
			anim = i.get_node('AnimationPlayer')
			if anim.has_animation('default'):
				var animlst = anim.get_animation_list()
				for b in animlst:
					anim.play(b, 1, spd, (spdivup < 0))
