extends Node3D
var player;
var body;
var inputHandler;
var raycasts;

@export var maxSpeed: float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = GameState.get_player();
	body = player.get_node("Body");
	inputHandler = player.get_node("InputHandler");
	raycasts = [%Raycast1, %Raycast2, %Raycast3, %Raycast4];
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# custom physics handling for player movement. regular movement feels flat and boring.
func _physics_process(delta):	
	
	var downVec = -body.global_transform.basis.y;

	for raycast in raycasts:
		# if we're not making contact at any of the contact points, we don't do anything, so just return
		if !raycast.is_colliding() && false:
			return
			
	
	var movementVector = inputHandler.get_movement_vector();
	var forceVector = Vector3.ZERO
	
	forceVector += body.global_transform.basis.x * movementVector.x * -GameState.PLAYER_ACCELERATION;
	forceVector += body.global_transform.basis.z * movementVector.y * -GameState.PLAYER_ACCELERATION;
	
	body.apply_central_force(forceVector);
		
# make sure the player's speed doesn't go over its max speed
func clamp_speed():
	body.linear_velocity.x = clamp(body.linear_velocity.x, -maxSpeed, maxSpeed);
	body.linear_velocity.z = clamp(body.linear_velocity.z, -maxSpeed, maxSpeed);

func _on_body_collision(collider: Node):
	player.play_sound("")
	Hooks.OnPlayerCollision(collider);
