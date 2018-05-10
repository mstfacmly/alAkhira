extends MarginContainer

# Onready
onready var az = $"/root/scene/az"
onready var bar = $org/right/hlth
onready var tween = $tween
onready var t = $timer
onready var debug = $org/left
#onready var pmenu = $pause
onready var shifter = shift
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
	$pause.show()
	get_tree().set_pause(true)
	az.hide()
	bar.hide()
	debug.hide()
	paused = true
	Input.set_mouse_mode(0)
	$pause/org/right/menuList/res.show()
	$pause/org/right/menuList/new_game.hide()

	if envanim.has_animation('shifter'):
		if shifter.curr != 'spi':
			envanim.play('shifter', -1, spd, (spd < 0))
			shifter.curr = 'spi'
		elif shifter.curr != 'phys':
			envanim.play('shifter', -1, -spd, (-spd < 0))
			shifter.curr = 'phys'

func _on_unpause():
	$pause.hide()
	get_tree().set_pause(false)
	az.show()
	bar.show()
	debug.show()
	paused = false
	Input.set_mouse_mode(2)
	$pause/org/right/menuList/res.show()

	if envanim.has_animation('shifter'):
		if shifter.curr != 'phys':
			envanim.play('shifter', -1, -spd, (-spd < 0))
			shifter.curr = 'phys'
		elif shifter.curr != 'spi':
			envanim.play('shifter', -1, spd, (spd < 0))
			shifter.curr = 'spi'

func _on_timer_timeout():
	get_tree().quit()

func _ready():
	var max_hlth = az.max_hlth
	bar.max_value = max_hlth
	updt_hlth(max_hlth)
	
	$pause.hide()
	$org/left/debug_info.hide()

	$pause/org/right/menuList/dbg.connect("pressed", self, "on_btn_press", ['dbg'])
	
	set_process_input(true)
	
	$pause/org/right/menuList/res.connect("pressed", self, "_on_btn_press", ['res'])
	
func _on_hlth_chng(hlth):
	updt_hlth(hlth)
	
func updt_hlth(new_val):
	tween.interpolate_property(self, 'anim_hlth', anim_hlth, new_val, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if !tween.is_active():
		tween.start()
		
func _process(delta):
	bar.value = anim_hlth

func _on_btn_press(btn):
	if btn == 'res':
		_on_unpause()
		
	if btn == 'dbg':
		show_debug()

func show_debug():
	var dbg_txt = $org/left/debug_info

	if dbg_txt.hide() != false:
		dbg_txt.show()
	else:
		dbg_txt.hide()