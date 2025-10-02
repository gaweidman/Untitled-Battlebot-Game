extends Piece

class_name Piece_SwivelPointer

@export var swivelNode : Node3D;

var cam : GameCamera;
var pointerLocation := Vector3.ZERO;
var targetRotation := 0.0;
@export var rotationSpeed := 1.0;

func stat_registry():
	super();
	register_stat("RotationSpeed", rotationSpeed, statIconCooldown);

func can_use_passive():
	return true;
	if super():
		var rot = global_rotation_degrees;
		##Can only use the passive if it's not rotated.
		if rot.x < 5.0 and rot.x > -5.0 and rot.z < 5.0 and rot.z > -5.0:
			return true;
	return false;

var tempFrameCounter = 0;
func phys_process_collision(delta):
	if !is_instance_valid(cam):
		cam = GameState.get_camera();
	
	if can_use_passive():
		swivelNode.rotation.y = lerp_angle(swivelNode.rotation.y, targetRotation, delta * 30.0 * get_stat("RotationSpeed"))
	
	super(delta);

func use_passive():
	var prevRotation = targetRotation;
	if host_is_player():
		if is_instance_valid(cam):
			if super():
				var rot = cam.get_rotation_to_fake_aiming(get_host_robot().get_global_body_position());
				#print(rot)
				if rot != null:
					targetRotation = rot - get_host_robot().get_global_body_rotation().y;
				else:
					targetRotation = prevRotation;
		return false;
	else:
		##TODO: Pointer Swivel: figure out non-player aiming methods for Robots, then plug that in here somehow. 
		return false;
