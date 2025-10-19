extends Piece

class_name Piece_Swivel

var targetRotation := 0.0;
@export var swivelNode : Node3D;
@export var rotationSpeed := 1.0;

func stat_registry():
	super();
	register_stat("RotationSpeed", rotationSpeed, statIconCooldown);

func phys_process_collision(delta):
	if !can_use_passive_any():
		targetRotation = 0.0;
	
	swivelNode.rotation.y = lerp_angle(swivelNode.rotation.y, targetRotation, delta * 30.0 * get_stat("RotationSpeed"))
	
	super(delta);
