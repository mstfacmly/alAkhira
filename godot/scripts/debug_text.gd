extends Label

onready var player = get_node("../../../player")
onready var cam = get_node("../../cam")
onready var timer = get_node("../../timer")
onready var curr = get_node("../../scripts/shift")
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
		txt = str("FPS: ", int(OS.get_frames_per_second()), "/s");
		txt += str("\nDrawn Vertices: ", Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME));
		txt += str("\nDrawn Objects: ", Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME));
		txt += str("\nDraw Calls: ", Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME));
#		txt += str("\nOn Floor: ", player.on_floor);
		txt += str("\nLedge: ", player.ledge);
		txt += str("\nWall: ", player.wall);
		txt += str("\nVelocity: ", player.velocity.length());
		txt += str("\nCam Radius: ", cam.cam_radius);
		txt += str("\nCam FOV: ", cam.cam_fov);
		txt += str("\nTimer: ", timer.get_wait_time());
		txt += str("\nWorld: ", curr.curr);
#		txt += str("\nJoystick X2: ", js_axis.get_joy_axis(0,2) );
#		txt += str("\nJoystick Y2: ", js_axis.get_joy_axis(0,36) );
#		txt += str("\nChar Rot: ", player.get_node("body").get_rotation().y);
#		if (not player.result.empty()):
#			txt += str("\nCollider: ", player.result.collider_id);
#		else:
#			txt += str("\nCollider: ", null ); 

		set_text(txt);