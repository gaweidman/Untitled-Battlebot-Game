extends Node
var player;
var combatHandler;
@export var fireRateTimer := 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = GameState.get_player();
	combatHandler = player.get_node("CombatHandler");


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta):
	process_movement(get_movement_vector(), delta);
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && can_fire():
		combatHandler.fireBullet();
		
	fireRateTimer -= delta;
	
func process_movement(movementVector, delta):
	player.body.linear_velocity += Vector3(
		movementVector.x * GameState.PLAYER_ACCELERATION * delta * -1, 
		0, 
		movementVector.y * GameState.PLAYER_ACCELERATION * delta * -1
	);
	
func get_movement_vector():
	var movementVector = Vector2.ZERO
		
	if Input.is_action_pressed("MoveLeft"):
		movementVector += Vector2.LEFT;
		
	if Input.is_action_pressed("MoveRight"):
		movementVector += Vector2.RIGHT;
		
	if Input.is_action_pressed("MoveUp"):
		movementVector += Vector2.UP;
		
	if Input.is_action_pressed("MoveDown"):
		movementVector += Vector2.DOWN;
		
	return movementVector;

func can_fire():
	return fireRateTimer <= 0
		##Temp condition, can be changed later
