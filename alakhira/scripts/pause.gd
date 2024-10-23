extends MarginContainer

var paused = false
onready var az = get_node("/root/scene/az")
onready var ui = $org/right/healthb
onready var t = $timer
onready var debug = $org/left
onready var pmenu = $org/right/pause/pause_menu
onready var shift = az.get_node("scripts/shift")
onready var envanim = get_node("/root/scene/env/AnimationPlayer")
var spd = 2

func _input(ev):
	if Input.is_key_pressed(KEY_F11):
		OS.set_window_fullscreen(!OS.window_fullscreen)
	
	var wait = 2
	var timer = t.set_wait_time(wait)

	var pause = ev.is_action_pressed("pause") && !ev.is_echo()

	if paused == false and pause:
		_on_pause()
	elif paused == true and pause:
		_on_unpause()

	if ev.is_action_pressed("pause"):
		if paused == true:
			t.start()
			print(t.start())
	elif ev.is_action("pause") && !ev.is_pressed():
		t.stop()
	else:
		timer

func _on_pause():
#	pmenu.set_exclusive(true)
#	pmenu.popup()
	pmenu.show()
	get_tree().set_pause(true)
	az.hide()
	ui.hide()
	debug.hide()
	paused = true
	
	if envanim.has_animation('shift'):
		if shift.curr != 'spi':
			envanim.play('shift', -1, spd, (spd < 0))
			shift.curr = 'spi'
		elif shift.curr != 'phys':
			envanim.play('shift', -1, -spd, (-spd < 0))
			shift.curr = 'phys'

func _on_unpause():
	pmenu.hide()
	get_tree().set_pause(false)
	az.show()
	ui.show()
	debug.show()
	paused = false

	if envanim.has_animation('shift'):
		if shift.curr != 'phys':
			envanim.play('shift', -1, -spd, (-spd < 0))
			shift.curr = 'phys'
		elif shift.curr != 'spi':
			envanim.play('shift', -1, spd, (spd < 0))
			shift.curr = 'spi'

func _on_timer_timeout():
	get_tree().quit()
	pass # replace with function body

func _ready():
	set_process_input(true)
