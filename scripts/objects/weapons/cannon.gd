extends MeshInstance3D
@export var inputHandler : Node3D;
@export var posNode : Node3D;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var rot = inputHandler.mouseProjectionRotation(posNode)
	rot = rot.rotated(Vector3(0,1,0), deg_to_rad(90))
	look_at(global_transform.origin + rot, Vector3.UP)
	#rotation = 
	pass
