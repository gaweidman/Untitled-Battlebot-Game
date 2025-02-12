extends Camera3D

@export var cameraOffset: Vector3 = Vector3(0, 28, 31);
@export var cameraAngle: Vector3 = Vector3(-49, 0, 0);

var player;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("../Player")
	rotation = cameraAngle

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = player.get_position() + cameraOffset;
	print(position)
	
