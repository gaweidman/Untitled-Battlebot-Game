extends Piece_Swivel

class_name Piece_SwivelPointer

var cam : GameCamera;
var pointerLocation := Vector3.ZERO;

func can_use_passive(passiveAbility):
	if super(passiveAbility):
		var rot = global_rotation_degrees;
		##Can only use the passive if it's not rotated.
		if rot.x < 5.0 and rot.x > -5.0 and rot.z < 5.0 and rot.z > -5.0:
			return true;
	return false;

func phys_process_collision(delta):
	super(delta);
	if !is_instance_valid(cam):
		cam = GameState.get_camera();

func use_passive(passiveAbility : AbilityManager):
	var prevRotation = targetRotation;
	if host_is_player():
		if is_instance_valid(cam):
			if super(passiveAbility):
				var rot = cam.get_rotation_to_fake_aiming(get_host_robot().get_global_body_position());
				#print(rot)
				if rot != null:
					targetRotation = rot - get_host_robot().get_global_body_rotation().y - get_host_socket().rotation.y;
				else:
					targetRotation = prevRotation;
		return false;
	else:
		##TODO: Pointer Swivel: figure out non-player aiming methods for Robots, then plug that in here somehow. 
		return false;
