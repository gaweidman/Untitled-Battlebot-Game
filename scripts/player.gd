extends Node3D

@export var maxSpeed: int;

var body;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_node("Body");
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# gets the direction the player is trying to go
func get_movement_vector():
	var movementVector = Vector2(0, 0);
	if Input.is_action_pressed("MoveLeft"):
		movementVector += Vector2.LEFT;
		
	if Input.is_action_pressed("MoveRight"):
		movementVector += Vector2.RIGHT;
		
	if Input.is_action_pressed("MoveUp"):
		movementVector += Vector2.UP;
		
	if Input.is_action_pressed("MoveDown"):
		movementVector += Vector2.DOWN;
		
	return movementVector
	
# custom physics handling for player movement. regular movement feels flat and boring.
func _physics_process(delta):
	if should_accelerate_horizontal():
		accelerate_horizontal(delta);
	elif should_decelerate_horizontal():
		decelerate_horizontal(delta);
		
	if should_accelerate_vertical():
		accelerate_vertical(delta);
	elif should_decelerate_vertical():
		decelerate_vertical(delta);
		
	do_gravity(delta);
		
	clamp_speed();
		
# check if we should accelerate on the horizontal axis. effectively checks if the
# player is trying to move horizontally
func should_accelerate_horizontal():
	var movementVector = get_movement_vector();
	return movementVector.x != 0
	
# check if we should accelerate on the horizontal axis. effectively checks if the player is trying to move horizontally
func should_accelerate_vertical():
	var movementVector = get_movement_vector();
	return movementVector.y != 0
	
func accelerate_horizontal(delta):
	var movementVector = get_movement_vector();
	
	# we WOULD multiply by the right vector, but left is positive in godot weirdly
	body.linear_velocity += movementVector.x * GameState.ACCELERATION * Vector3.LEFT * delta
	
func accelerate_vertical(delta):
	var movementVector = get_movement_vector();
	
	# up (forward in 3D) is positive, so we multiply the vertical speed by the forward vector and not the backward vector.
	body.linear_velocity += movementVector.y * GameState.ACCELERATION * Vector3.FORWARD * delta;
		
# check if we need to decelerate on the horizontal access
func should_decelerate_horizontal():
	var movementVector = get_movement_vector();
	return !should_accelerate_horizontal() && body.linear_velocity.x != 0

# check if we need to decelerate on the vertical axis
func should_decelerate_vertical():
	return !should_accelerate_vertical() && body.linear_velocity.z != 0

# do the horizontal deceleration
func decelerate_horizontal(delta):
	var direction = get_sign(body.linear_velocity.x);
	body.linear_velocity.x += GameState.DECELERATION * (direction * -1) * delta;
	
	# if the velocity, when being decelerated, passes zero and starts going the
	# other direction, we set it to zero.
	var newDirection = get_sign(body.linear_velocity.x)
	if newDirection != 0 && newDirection != direction:
		body.linear_velocity.x = 0;

# do the vertical deceleration
func decelerate_vertical(delta):
	var direction = get_sign(body.linear_velocity.z);
	body.linear_velocity.z += GameState.DECELERATION * (direction * -1) * delta;
	
	# if the velocity, when being decelerated, passes zero and starts going the
	# other direction, we set it to zero.
	var newDirection = get_sign(body.linear_velocity.z)
	if newDirection != 0 && newDirection != direction:
		body.linear_velocity.z = 0;
		
# make sure the player's speed doesn't go over its max speed
func clamp_speed():
	body.linear_velocity.x = clamp(body.linear_velocity.x, -maxSpeed, maxSpeed)
	body.linear_velocity.z = clamp(body.linear_velocity.z, -maxSpeed, maxSpeed)
	
func do_gravity(delta):
	body.linear_velocity.y -= GameState.GRAVITY * delta;

# if a given number is positive, returns 1. if it's negative, returns -1. if it's
# 0, returns 0.
func get_sign(num):
	if num == 0:
		return 0
	else:
		return num/abs(num);
