extends RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rand = RandomNumberGenerator.new();
	set_rotation_degrees(Vector3(0, rand.randi_range(0, 360), 0));
	#apply_central_force(front());


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
