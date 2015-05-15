
extends KinematicBody

# member variables here, example:
# var a=2
# var b="textvar"

var g = -9.8
var vel = Vector3()
const MAX_SPEED = 13
<<<<<<< HEAD
const JUMP_SPEED = 7
=======
const JUMP_SPEED = -9.8 /2.487
>>>>>>> origin
const ACCEL= 2
const DEACCEL= 14
const MAX_SLOPE_ANGLE = 30

var JS

<<<<<<< HEAD
=======
func adjust_facing(p_facing, p_target,p_step, p_adjust_rate,current_gn): #transition a change of direction

	var n = p_target # normal
	var t = n.cross(current_gn).normalized()
	var x = n.dot(p_facing)
	var y = t.dot(p_facing)
	var ang = atan2(y,x)

	if (abs(ang)<0.001): # too small
		return p_facing

	var s = sign(ang)
	ang = ang * s
	var turn = ang * p_adjust_rate * p_step
	var a
	if (ang<turn):
		a=ang
	else:
		a=turn
	ang = (ang - a) * s

	return ((n * cos(ang)) + (t * sin(ang))) * p_facing.length()

>>>>>>> origin
func _fixed_process(delta):

	var dir = Vector3() #where does the player intend to walk to
	var cam_xform = get_node("target/camera").get_global_transform()

	if (JS.get_digital("ls_up") or Input.is_action_pressed("move_forward")):
		dir+=-cam_xform.basis[2]
	if (JS.get_digital("ls_down") or Input.is_action_pressed("move_backwards")):
		dir+=cam_xform.basis[2]
	if (JS.get_digital("ls_left") or Input.is_action_pressed("move_left")):
		dir+=-cam_xform.basis[0]
	if (JS.get_digital("ls_right") or Input.is_action_pressed("move_right")):
		dir+=cam_xform.basis[0]

	dir.y=0
	dir=dir.normalized()

	vel.y+=delta*g
	
	var hvel = vel
	hvel.y=0	
	
	var target = dir*MAX_SPEED
	var accel
	if (dir.dot(hvel) >0):
		accel=ACCEL
	else:
		accel=DEACCEL
		
	hvel = hvel.linear_interpolate(target,accel*delta)
	
	vel.x=hvel.x;
	vel.z=hvel.z	
		
	var motion = vel*delta
	motion=move(vel*delta)

	var on_floor = false
	var original_vel = vel


	var floor_velocity=Vector3()

	var attempts=4
	
	while(is_colliding() and attempts):
		var n=get_collision_normal()

		if ( rad2deg(acos(n.dot( Vector3(0,1,0)))) < MAX_SLOPE_ANGLE ):
				#if angle to the "up" vectors is < angle tolerance
				#char is on floor
				floor_velocity=get_collider_velocity()
				on_floor=true			
			
		motion = n.slide(motion)
		vel = n.slide(vel)
		if (original_vel.dot(vel) > 0):
			#do not allow to slide towads the opposite direction we were coming from
			motion=move(motion)
			if (motion.length()<0.001):
				break
		attempts-=1

	if (on_floor and floor_velocity!=Vector3()):
		move(floor_velocity*delta)
	
	
	if (on_floor and JS.get_digital("action_1") or on_floor and Input.is_action_pressed("jump")):
		vel.y=JUMP_SPEED
		
#	var crid = get_node("../elevator1").get_rid()
#	print(crid," : ",PS.body_get_state(crid,PS.BODY_STATE_TRANSFORM))

func _ready():
	# Initalization here
	set_fixed_process(true)
<<<<<<< HEAD
=======
	adjust_facing()
>>>>>>> origin
	JS = get_node("/root/SUTjoystick")
	pass


func _on_tcube_body_enter( body ):
#	get_node("../ty").show()
	pass # replace with function body
