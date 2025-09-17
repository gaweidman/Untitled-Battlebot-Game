extends Robot

class_name Robot_Player

######################## INPUT MANAGEMENT
	
func get_movement_vector(rotatedByCamera : bool = true) -> Vector2:
	var movementVector = Vector2.ZERO
		
	if Input.is_action_pressed("MoveLeft"):
		movementVector += Vector2.LEFT;
		
	if Input.is_action_pressed("MoveRight"):
		movementVector += Vector2.RIGHT;
		
	if Input.is_action_pressed("MoveUp"):
		movementVector += Vector2.UP;
		
	if Input.is_action_pressed("MoveDown"):
		movementVector += Vector2.DOWN;
	
	if rotatedByCamera:
		if not is_instance_valid(camera):
			camera = GameState.get_camera();
		
		var camRotY = - camera.targetRotationY;
		
		movementVector = movementVector.rotated(camRotY);
	
	if is_inputting_movement():
		movementVectorRotation = movementVector.angle();
	return movementVector.normalized();

func is_inputting_movement() -> bool:
	inputtingMovementThisFrame = false;
	#print("ASDASDASD")
	if GameState.get_in_state_of_play() and is_conscious():
		if Input.is_action_pressed("MoveLeft"):
			inputtingMovementThisFrame = true;
			return inputtingMovementThisFrame;
			
		if Input.is_action_pressed("MoveRight"):
			inputtingMovementThisFrame = true;
			return inputtingMovementThisFrame;
			
		if Input.is_action_pressed("MoveUp"):
			inputtingMovementThisFrame = true;
			return inputtingMovementThisFrame;
			
		if Input.is_action_pressed("MoveDown"):
			inputtingMovementThisFrame = true;
			return inputtingMovementThisFrame;
	
	return inputtingMovementThisFrame;

func die():
	#Hooks.OnDeath(self, GameState.get_player()); ##TODO: Fix hooks to use new systems before uncommenting this.
	alive = false;
	hide();
	freeze(true, true);
	#queue_free();
