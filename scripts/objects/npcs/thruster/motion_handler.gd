extends Node3D
var thisNpc;
var body;
var botBodyMesh;
var raycasts;
var aiHandler;

@export var maxSpeed: float;

var bodyRotationAngle = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thisNpc = get_node("../");
	aiHandler = get_node("../AIHandler");
	body = thisNpc.get_node("Body");
	raycasts = [%Raycast1, %Raycast2, %Raycast3, %Raycast4];
	botBodyMesh = body.get_node("BotBody")
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
	
	var movementVector = aiHandler.get_movement_vector();
	var forceVector = Vector3.ZERO
	
	forceVector += body.global_transform.basis.x * movementVector.x * -GameState.PLAYER_ACCELERATION;
	forceVector += body.global_transform.basis.z * movementVector.y * -GameState.PLAYER_ACCELERATION;
	
	body.apply_central_force(forceVector);
	
	##Rotating the body mesh towards the movement vector
	var rotatedMV = movementVector.rotated(deg_to_rad(90));
	
	var rotateVector = Vector3(bodyRotationAngle.x, 0, bodyRotationAngle.y) + botBodyMesh.global_position
	
	look_at_safe(botBodyMesh, rotateVector)

func look_at_safe(node, target):
	if node.global_transform.origin.is_equal_approx(target): return;
	node.look_at(target);

# make sure the player's speed doesn't go over its max speed
func clamp_speed():
	body.linear_velocity.x = clamp(body.linear_velocity.x, -maxSpeed, maxSpeed);
	body.linear_velocity.z = clamp(body.linear_velocity.z, -maxSpeed, maxSpeed);

func _on_collision(thisComponent: Node, collider: Node):
	# if we've assigned a material to it, it can make a sound on collision, so this is how we check
	# whether or not this collision can play a sound
	if (collider.is_in_group("Concrete") || collider.is_in_group("Metal") || collider.is_in_group("Plastic")) && (thisComponent.is_in_group("Concrete") || thisComponent.is_in_group("Metal") || thisComponent.is_in_group("Plastic")):
		thisNpc.play_sound(Sound.get_proper_sound(collider, thisComponent))
	Hooks.OnPlayerCollision(collider);
