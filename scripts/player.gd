extends Node3D

@export var speed: int;

var sawblade;
var body;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sawblade = get_node("Body/Sawblade");
	body = get_node("Body");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# makes the sawblade rotate
	sawblade.rotation_degrees = Vector3(0, Time.get_ticks_msec()%360, 0);
	
	# this is the direction the player wants to move
	var movementVector = get_movement_vector();
		
	var horizSpeed = movementVector.x * speed;
	var vertSpeed = movementVector.y * speed

	# up (forward in 3D) is positive, so we multiply the vertical speed by the forward vector and not the backward vector.
	# we WOULD do the same for moving horizontal, but left is positive in godot
	body.linear_velocity += horizSpeed * Vector3.LEFT + vertSpeed * Vector3.FORWARD
	
	body.linear_velocity.x = clamp(body.linear_velocity.x, -speed, speed)
	body.linear_velocity.z = clamp(body.linear_velocity.z, -speed, speed)
	
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
func _physics_process(state):
	var movementVector = get_movement_vector();
	
	# if the speed on the x axis isn't 0 but the player isn't inputting movement on that axis
	# basically, if we need to decelerate on the x axis.
	if movementVector.x == 0 && body.linear_velocity.x != 0:
		var direction = get_sign(body.linear_velocity.x);
		body.linear_velocity.x += GameState.DECELERATION * (direction * -1);
		
		# if the velocity, when being decelerated, passes zero and starts going the
		# other direction, we set it to zero.
		var newDirection = get_sign(body.linear_velocity.x)
		if newDirection != 0 && newDirection != direction:
			body.linear_velocity.x = 0;
	
	# if the speed on the z axis isn't 0 but the player isn't inputting movement on that axis
	# basically, if we need to decelerate on the z axis.
	if movementVector.y == 0 && body.linear_velocity.z != 0:
		var direction = get_sign(body.linear_velocity.z);
		body.linear_velocity.z += GameState.DECELERATION * (direction * -1);
		
		# if the velocity, when being decelerated, passes zero and starts going the
		# other direction, we set it to zero.
		var newDirection = get_sign(body.linear_velocity.z)
		if newDirection != 0 && newDirection != direction:
			body.linear_velocity.z = 0;
			
	print(body.linear_velocity)

# if a given number is positive, returns 1. if it's negative, returns -1. if it's
# 0, returns 0.
func get_sign(num):
	if num == 0:
		return 0
	else:
		return num/abs(num);
