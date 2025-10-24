extends Piece_Swivel

class_name Piece_SwivelPointer

var cam : GameCamera;
var pointerLocation := Vector3.ZERO;

func can_use_passive(passiveAbility):
	if passiveAbility.abilityName == "Target":
		var rot = global_rotation_degrees;
		##Can only use the passive if it's not rotated.
		if rot.x < 5.0 and rot.x > -5.0 and rot.z < 5.0 and rot.z > -5.0:
			return super(passiveAbility);
		return false;
	return super(passiveAbility);

func phys_process_pre(delta):
	super(delta);
	if !is_instance_valid(cam):
		cam = GameState.get_camera();

func use_passive(passiveAbility : AbilityManager):
	if passiveAbility.abilityName == "Target":
		if is_instance_valid(cam):
			if test_energy_available(passiveAbility.get_energy_cost()):
				if can_use_passive(passiveAbility):
					return use_active(passiveAbility);
				else:
					targetRotation = 0.0;
		return false;
	else:
		return super(passiveAbility);

func target():
	var prevRotation = targetRotation;
	if host_is_player():
		var rot = cam.get_rotation_to_fake_aiming(global_position);
		
		if rot != null:
			targetRotation = rot - get_host_robot().get_global_body_rotation().y - get_host_socket().rotation.y;
		else:
			targetRotation = prevRotation;
	else:
		pass;
