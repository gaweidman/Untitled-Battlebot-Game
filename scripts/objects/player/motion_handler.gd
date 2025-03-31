extends Node3D
var player;
var body;
var botBodyMesh;
var inputHandler;
var raycasts;
var bodyRotationAngle = Vector2.ZERO;

@export var maxSpeed: float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = GameState.get_player();
	if player:
		body = player.get_node("Body");
		botBodyMesh = body.get_node("BotBody");
		inputHandler = player.get_node("InputHandler");
	raycasts = [%Raycast1, %Raycast2, %Raycast3, %Raycast4];
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !player:
		player = GameState.get_player();
		if player:
			body = player.get_node("Body");
			botBodyMesh = body.get_node("BotBody");
			inputHandler = player.get_node("InputHandler");
			
			print(botBodyMesh, " BODY MESH ")
# custom physics handling for player movement. regular movement feels flat and boring.
func _physics_process(delta):	
	print("WE ARE RUNNING", body.get_node("../Body/BotBody"))
	if body:
		var downVec = -body.global_transform.basis.y;
		
	var movementVector = inputHandler.get_movement_vector();
	
	##Rotating the body mesh towards the movement vector
	var rotatedMV = movementVector.rotated(deg_to_rad(90));
	
	if inputHandler.is_inputting_movement():
		bodyRotationAngle = lerp(bodyRotationAngle, movementVector.rotated(deg_to_rad(90)), delta * 10)
	
	var rotateVector = Vector3(bodyRotationAngle.x, 0, bodyRotationAngle.y) + botBodyMesh.global_position
	
	look_at_safe(botBodyMesh, rotateVector)
	
	for raycast in raycasts:
		# if we're not making contact at any of the contact points, we don't do anything, so just return
		if !raycast.is_colliding() && false:
			return
		
	var forceVector = Vector3.ZERO
	forceVector += body.global_transform.basis.x * movementVector.x * -GameState.PLAYER_ACCELERATION;
	forceVector += body.global_transform.basis.z * movementVector.y * -GameState.PLAYER_ACCELERATION;
	body.apply_central_force(forceVector);
	clamp_speed();

func look_at_safe(node, target):
	if node.global_transform.origin.is_equal_approx(target): return;
	node.look_at(target);
# make sure the player's speed doesn't go over its max speed
func clamp_speed():
	body.linear_velocity.x = clamp(body.linear_velocity.x, -maxSpeed, maxSpeed);
	body.linear_velocity.z = clamp(body.linear_velocity.z, -maxSpeed, maxSpeed);

func _on_collision(playerComponent: Node, collider: Node):
	# if we've assigned a material to it, it can make a sound on collision, so this is how we check
	# whether or not this collision can play a sound
	if (collider.is_in_group("Concrete") || collider.is_in_group("Metal") || collider.is_in_group("Plastic")) && (playerComponent.is_in_group("Concrete") || playerComponent.is_in_group("Metal") || playerComponent.is_in_group("Plastic")):
		player.play_sound(Sound.get_proper_sound(collider, playerComponent))
	Hooks.OnPlayerCollision(collider);
