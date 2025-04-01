extends MotionHandler

class_name MotionHandlerPlayer

var inputHandler;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super();
	pass # Replace with function body.


func _process(delta: float) -> void:
	super(delta);
	pass;

func grab_references():
	thisBot = GameState.get_player();
	super();
	if thisBot:
		inputHandler = thisBot.get_node("InputHandler");
	

# custom physics handling for player movement. regular movement feels flat and boring.
func _physics_process(delta):
	super(delta);
		
	var movementVector = inputHandler.get_movement_vector();
	
	##Rotating the body mesh towards the movement vector
	var rotatedMV = movementVector.rotated(deg_to_rad(90));

	if InputHandler.is_inputting_movement():
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

	pass;
