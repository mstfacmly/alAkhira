extends Label

onready var az = get_node("../../../az")
onready var cam = get_node("../../cam")
#onready var timer = get_node("../../timer")
onready var curr = get_node("../../scripts/shift")
onready var health = get_node("../../ui/healthb")
var js_axis = Input

var update = 0.0;

func _ready():
	set_process(true);

func _process(delta):
	if update < 1.0:
		update += delta;
	else:
		update = 0.0;
		var txt
		txt = str("FPS: ", int(Engine.get_frames_per_second()), "/s");
		txt = str("\n Drawn Vertices: ", Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME));
		txt = str("\n Drawn Objects: ", Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME));
		txt = str("\n Draw Calls: ", Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME));
#		txt = str("\nOn Floor: ", az.on_floor);
#		txt = str("\nWall Run: ", az.wrun);
#		txt = str("\nColliding: ", az.col_result);
#		txt = str("\nLedge: ", az.ledge_col);
#		txt = str("\nVelocity: ", az.vel.length());
#		txt = str("\nVertical Velocity: ", az.vel.y);
#		txt = str("\nCam Radius: ", cam.cam_radius);
#		txt = str("\nCam FOV: ", cam.cam_fov);
#		txt = str("\nTimer: ", timer.get_wait_time());
#		txt = str("\nChar State: ", health.state);
#		txt = str("\nWorld: ", curr.curr);
		txt = str("\n Joystick X: ", js_axis.get_joy_axis(0,0) );
		txt = str("\n Joystick Y: ", js_axis.get_joy_axis(0,1));

		set_text(txt);
