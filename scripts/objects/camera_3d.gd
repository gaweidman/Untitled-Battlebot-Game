extends Camera3D

var player;
var cameraOffset;
var targetPosition : Vector3;
var inputOffset : Vector3;
var targetInputOffset : Vector3;
var modInpVec : Vector3;
var modMouseVec : Vector3;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node_or_null("../Player/Body")
	cameraOffset = position # the player always starts at 0, 0, 0 so we don't do any subtraction here

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player != null:
		var inp = GameState.get_input_handler();
		var inpVec = inp.get_movement_vector();
		modInpVec = - Vector3(inpVec.x, 0, inpVec.y);
		modMouseVec = InputHandler.mouseProjectionRotation(self);
		targetInputOffset = modMouseVec + modInpVec;
		targetPosition = player.get_position() + cameraOffset + inputOffset;
	else:
		player = get_node("../Player/Body")

func _physics_process(delta):
	inputOffset = lerp (inputOffset, targetInputOffset, delta * 5)
	position = lerp(position, targetPosition, delta * 10);
