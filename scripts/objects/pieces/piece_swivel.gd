extends Piece

class_name Piece_Swivel

var targetRotation := 0.0;
@export var swivelNode : Node3D;
@export var rotationSpeed := 0.9;
@export var movingSockets : Array[Socket] = [];

func stat_registry():
	super();
	register_stat("RotationSpeed", rotationSpeed, statIconCooldown);

func phys_process_collision(delta):
	if !can_use_passive_any():
		targetRotation = 0.0;
	
	swivelNode.rotation.y = lerp_angle(swivelNode.rotation.y, targetRotation, delta * 30.0 * get_stat("RotationSpeed") * get_swivel_rotation_speed_multiplier_based_on_weight())
	
	super(delta);


func get_swivel_rotation_speed_multiplier_based_on_weight():
	var load = 0.0;
	for socket in movingSockets:
		load += get_socket_weight_load(socket);
	#print("WEIGHT LOAD: ",load);
	var speed = max(00.0, (1.0 - load * 0.015));
	return speed;
