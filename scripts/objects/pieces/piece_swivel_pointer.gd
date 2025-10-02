extends Piece

class_name Piece_SwivelPointer

@export var swivelNode : Node3D;

var cam : GameCamera;
var pointerLocation := Vector3.ZERO;

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
	if tempFrameCounter < 0:
		tempFrameCounter = 10;
		pointerLocation = Vector3()
	super(delta);

func use_passive():
	if is_instance_valid(cam) and is_instance_valid(cam):
		if super():
			var rot = cam.get_rotation_to_fake_aiming(get_host_robot().get_global_body_position());
			#print(rot)
			if rot != null:
				swivelNode.rotation.y = rot - get_host_robot().get_global_body_rotation().y;
	return false;
