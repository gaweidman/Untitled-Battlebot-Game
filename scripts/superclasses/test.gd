extends Node3D

func _process(delta):
	if Input.is_action_pressed("CameraYawLeft"):
		rotate(Vector3.UP, deg_to_rad(-1))
	if Input.is_action_pressed("CameraYawRight"):
		rotate(Vector3.UP, deg_to_rad(1))
