extends RigidBody3D

class_name RobotBody

var targetPoint := Vector2(0.0, 1.0);
var targetRotation := 0.0;
var currentRotation := 0.0;

func _ready():
	targetRotation = global_rotation.y;
	currentRotation = global_rotation.y;

func update_target_rotation(inRot, rotationSpeed):
	targetPoint = inRot;
	targetRotation = targetPoint.angle();
	#print("Getting target rotation:",targetRotation)
	currentRotation = lerp_angle(currentRotation, targetRotation, rotationSpeed);
	_integrate_forces("Rotation");

func clamp_speed():
	_integrate_forces("Speed Clamp");

func _integrate_forces(state):
	match state:
		"Rotation":
			rotation.y = currentRotation;
		"Speed Clamp":
			var max_speed = get_parent().get_stat("MovementSpeedMax");
			var current_velocity = linear_velocity;
			var current_speed = current_velocity.length();

			if current_speed > max_speed:
				linear_velocity = current_velocity.normalized() * max_speed;
		_:
			pass;
	#print("Applying current rotation:",currentRotation)
	basis = basis.orthonormalized();

#func _physics_process(delta):
