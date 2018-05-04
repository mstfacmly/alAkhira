extends MarginContainer

# Onready
onready var az = $"/root/scene/az"
onready var bar = $org/right/hlth
onready var tween = $tween
onready var t = $timer
onready var debug = $org/left
onready var pmenu = $org/right/pause/pause_menu
onready var shift = az.get_node("scripts/shift")
onready var envanim = get_node("/root/scene/env/AnimationPlayer")

# variables
var paused = false
var anim_hlth = 0
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
	elif ev.is_action("pause") && !ev.is_pressed():
		t.stop()
	else:
		timer

func _on_pause():
	pmenu.show()
	get_tree().set_pause(true)
	az.hide()
	bar.hide()
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
	bar.show()
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

func _ready():
	var max_hlth = az.max_hlth
	bar.max_value = max_hlth
	updt_hlth(max_hlth)
	
	set_process_input(true)
	
func _on_hlth_chng(hlth):
	updt_hlth(hlth)
	
func updt_hlth(new_val):
	tween.interpolate_property(self, 'anim_hlth', anim_hlth, new_val, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if !tween.is_active():
		tween.start()
		
func _process(delta):
	bar.value = anim_hlth
