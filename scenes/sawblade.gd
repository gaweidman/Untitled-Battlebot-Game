extends CSGCylinder3D

@export var speed: float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation.y = speed;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass 

func _physics_process(delta):
	if angular_velocity.x != speed:
		angular_velocity.x = Vector(99, 0, 0)
