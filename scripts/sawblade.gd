extends RigidBody3D

@export var speed: float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass 

func _physics_process(delta):
	pass
		
func _integrate_physics(state):
	if state.get_angular_velocity().x != speed:
		state.set_angular_velocity(Vector3(speed, 0, 0))
	
