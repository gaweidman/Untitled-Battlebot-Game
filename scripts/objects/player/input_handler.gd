extends Node3D

class_name InputHandler;

var player;
var combatHandler;

enum FIRE {
	SLOT0,
	SLOT1,
	SLOT2,
	SLOT3,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = GameState.get_player();
	combatHandler = player.get_node("CombatHandler");


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta):
	
	if GameState.get_in_state_of_play():
		process_movement(get_movement_vector(), delta);
		
		if ! player.inventory.inventoryUp:
			if Input.is_action_pressed("Fire0") && combatHandler.can_fire(FIRE.SLOT0):
				combatHandler.use_active(FIRE.SLOT0);
			if Input.is_action_pressed("Fire1") && combatHandler.can_fire(FIRE.SLOT1):
				combatHandler.use_active(FIRE.SLOT1);
			if Input.is_action_pressed("Fire2") && combatHandler.can_fire(FIRE.SLOT2):
				combatHandler.use_active(FIRE.SLOT2);
			if Input.is_action_pressed("Fire3") && combatHandler.can_fire(FIRE.SLOT3):
				combatHandler.use_active(FIRE.SLOT3);
	
# we apply forces in motion_handler
func process_movement(movementVector, delta):
	pass
	
func get_movement_vector() -> Vector2:
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

static func is_inputting_movement() -> bool:
	if GameState.get_in_state_of_play():
		if Input.is_action_pressed("MoveLeft"):
			return true;
			
		if Input.is_action_pressed("MoveRight"):
			return true;
			
		if Input.is_action_pressed("MoveUp"):
			return true;
			
		if Input.is_action_pressed("MoveDown"):
			return true;
	
	return false;

static func mouseProjectionRotation(positionNode : Node3D) -> Vector3:
	if is_instance_valid(positionNode):
		var viewport = positionNode.get_viewport();
		var camera = viewport.get_camera_3d();
		
		var mousePos = viewport.get_mouse_position();
		var mousePos3 = camera.project_position(mousePos, 0);
		var mouseProject = camera.project_position(mousePos, (camera.global_position - positionNode.global_position).length())
		#print(projDif)
		
		var vector = mouseProject - positionNode.global_position
		var mouseProjectNormalized = Vector3(vector.x, 0, vector.z).normalized()
		return mouseProjectNormalized;
	return Vector3.ZERO;

static func playerPosRotation(positionNode : Node3D) -> Vector3:
	var pos = GameState.get_player_pos_offset(positionNode.global_position);
	
	var mouseProjectNormalized = Vector3(pos.x, 0, pos.z).normalized()
	return mouseProjectNormalized;
