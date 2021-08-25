extends Label

var az
var cam
var update = 0.0
#var shifter = shift_script

func _ready():
	if find_parent('scene') && find_parent('scene').has_node('az'):
		az = find_parent('scene').get_node('az')
		cam = az.get_node('cam')
		if self.is_visible():
			set_physics_process(true)
		else:
			set_physics_process(false)
	else:
		set_physics_process(false)

func _physics_process(delta):
	if update < 1.0:
		update += delta
	else:
		update = 0.0
		var txt
		txt = str('OS: ', OS.get_name())
		txt += str('\nScreens: ', OS.get_screen_count())
		txt += str('\nScreen Resolution: ', OS.get_screen_size())
		txt += str('\nWindow Resolution: ', OS.get_real_window_size())
		txt += str('\nDynamic RAM: ', round(OS.get_dynamic_memory_usage() / pow(1024,1)) , 'Kbs')
		txt += str('\nStatic RAM: ', round(OS.get_static_memory_usage() / pow(1024,2)), 'Mbs')
		txt += str('\nFPS: ', int(Engine.get_frames_per_second()), '/s')
		txt += str('\nDrawn Vertices: ', Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME))
		txt += str('\nDrawn Objects: ', Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME))
		txt += str('\nDraw Calls: ', Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME))
#		txt += str('\nLocale: ', TranslationServer.get_locale())
		txt += str('\nMSAA: ', get_viewport().msaa)
#		txt += str('\nOn Floor: ', az.is_on_floor())
#		txt += str('\nWall Run: ', az.wrun)
#		txt += str('\nColliding: ', az.col_result)
#		txt += str('\nLedge: ', az.ledge_col)
		txt += str('\nVelocity: ', az.velocity.length())
		txt += str('\nVertical Velocity: ', az.velocity.y)
#		txt += str('\nCam Enabled: ', cam.is_enabled)
#		txt += str('\nCam Radius: ', cam.radius)
#		txt += str('\nCam FOV: ', cam.fov)
#		txt += str('\nTimer: ', timer.get_wait_time())
#		txt += str('\nChar State: ', az.state)
#		txt += str('\nWorld State: ', shifter.state)
#		txt += str('\nWorld: ', shifter.curr)
#		txt += str('\nMouse Mode: ', Input.get_mouse_mode())
		txt += str('\nJoystick Vector: ', Vector2(Input.get_joy_axis(0,0), Input.get_joy_axis(0,1)).length_squared())

		set_text(txt)
