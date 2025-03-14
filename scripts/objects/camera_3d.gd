extends Camera3D

var player;
var cameraOffset;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node_or_null("../Player/Body")
	cameraOffset = position # the player always starts at 0, 0, 0 so we don't do any subtraction here

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player != null:
		position = player.get_position() + cameraOffset;
	else:
		player = get_node("../Player/Body")
