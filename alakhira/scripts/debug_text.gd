extends Label

onready var az = $"../../../../../az"
onready var cam = $"../../../../cam"
onready var curr = shift
var js_axis = Input
var update = 0.0

func _physics_process(delta):
	if update < 1.0:
		update += delta
	else:
		update = 0.0
		var txt
		txt = str("OS: ", OS.get_name())
		txt += str("\nFPS: ", int(Engine.get_frames_per_second()), "/s")
		txt += str("\nDrawn Vertices: ", Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME))
		txt += str("\nDrawn Objects: ", Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME))
		txt += str("\nDraw Calls: ", Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME))
		txt += str("\nOn Floor: ", az.is_on_floor())
		txt += str("\nWall Run: ", az.wrun)
		txt += str("\nColliding: ", az.col_result)
		txt += str("\nLedge: ", az.ledge_col)
		txt += str("\nVelocity: ", az.hvel.length())
		txt += str("\nVertical Velocity: ", az.vvel)
		txt += str("\nCam Radius: ", cam.cam_radius)
		txt += str("\nCam FOV: ", cam.cam_fov)
#		txt += str("\nTimer: ", timer.get_wait_time())
#		txt += str("\nChar State: ", health.state)
		txt += str("\nWorld: ", curr.curr)
		txt += str("\nJoystick X: ", js_axis.get_joy_axis(0,0) )
		txt += str("\nJoystick Y: ", js_axis.get_joy_axis(0,1))

		set_text(txt)
