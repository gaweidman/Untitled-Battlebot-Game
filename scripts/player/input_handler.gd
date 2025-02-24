extends Node
var player;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = GameState.get_player();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta):
	# Movement
	var movementVector = Vector2(0, 0)
		
	if Input.is_action_pressed("MoveLeft"):
		movementVector += Vector2.LEFT;
		
	if Input.is_action_pressed("MoveRight"):
		movementVector += Vector2.RIGHT;
		
	if Input.is_action_pressed("MoveUp"):
		movementVector += Vector2.UP;
		
	if Input.is_action_pressed("MoveDown"):
		movementVector += Vector2.DOWN;
		
	process_movement(movementVector, delta);
	
func process_movement(movementVector, delta):
	player.body.linear_velocity += Vector3(
		movementVector.x * GameState.PLAYER_ACCELERATION * delta * -1, 
		0, 
		movementVector.y * GameState.PLAYER_ACCELERATION * delta * -1
	);
