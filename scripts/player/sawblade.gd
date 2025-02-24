extends RigidBody3D

@export var speed: float;
var gaming;
var player;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gaming = true;
	connect("body_entered", _on_collide);
	set_owner(get_node("../Player"))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass 

func _physics_process(delta):
	pass
	
func _on_collide():
	print("collided")
		
func _integrate_physics(state):
	if state.get_angular_velocity().x != speed:
		state.set_angular_velocity(Vector3(speed, 0, 0))
	
