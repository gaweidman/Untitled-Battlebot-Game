extends RigidBody3D

class_name RobotBody

var targetPoint := Vector2(0.0, 1.0);
var targetRotation := 0.0;
var currentRotation := 0.0;

func _ready():
	targetRotation = global_rotation.y;
	currentRotation = global_rotation.y;

func update_target_rotation(inRot, rotationSpeed):
	rotationSpeed = clamp(rotationSpeed, 0.0, 1.0);
	targetPoint = inRot;
	targetRotation = targetPoint.angle();
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
				var y = linear_velocity.y;
				var cvFIxd = current_velocity.normalized() * max_speed;
				linear_velocity = Vector3(cvFIxd.x, y, cvFIxd.z);
		_:
			pass;
	#print("Applying current rotation:",currentRotation)
	basis = basis.orthonormalized();

func get_robot() -> Robot:
	return get_parent();
