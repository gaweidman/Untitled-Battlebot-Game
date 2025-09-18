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
	_integrate_forces(null);

func _integrate_forces(state):
	rotation.y = currentRotation;
	#print("Applying current rotation:",currentRotation)

#func _physics_process(delta):
