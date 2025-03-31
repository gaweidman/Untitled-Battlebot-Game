extends Node3D

class_name InputHandler;

var player;
var combatHandler;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = GameState.get_player();
	combatHandler = player.get_node("CombatHandler");


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta):
	process_movement(get_movement_vector(), delta);
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && combatHandler.can_fire():
		print("HI")
		combatHandler.fireBullet();
	
# we apply forces in motion_handler
func process_movement(movementVector, delta):
	pass
	
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

func is_inputting_movement():
	if Input.is_action_pressed("MoveLeft"):
		return true;
		
	if Input.is_action_pressed("MoveRight"):
		return true;
		
	if Input.is_action_pressed("MoveUp"):
		return true;
		
	if Input.is_action_pressed("MoveDown"):
		return true;
	
	return false;

static func mouseProjectionRotation(positionNode : Node3D):
	var viewport = positionNode.get_viewport();
	var camera = viewport.get_camera_3d();
	
	var mousePos = viewport.get_mouse_position();
	var mousePos3 = camera.project_position(mousePos, 0);
	var mouseProject = camera.project_position(mousePos, camera.position.y) - positionNode.global_position;
	
	var mouseProjectNormalized = Vector3(mouseProject.x, 0, mouseProject.z).normalized()
	return mouseProjectNormalized;
