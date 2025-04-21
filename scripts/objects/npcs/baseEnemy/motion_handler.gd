extends MotionHandler

class_name MotionHandlerBaseEnemy

var aiHandler;
var nextThrust;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super();
	nextThrust = Time.get_ticks_msec() + randi_range(0, 3) * 1000
	pass;

func _process(delta: float) -> void:
	super(delta);
	pass;

func grab_references():
	thisBot = get_node("../");
	super();
	if thisBot:
		aiHandler = thisBot.get_node("AIHandler");


## This enemy thrusts.
## Make sure to move this to the thruster. Default behavior should probably be unmoving.
func _physics_process(delta):
	super(delta);
	if ! is_instance_valid(aiHandler):
		aiHandler = thisBot.get_node("AIHandler");
		
	nextThrust += 1000;
	
	# this will be the direction of movement taken from 2D to 3D and multiplied by the speed of movement
	# multiplication is done BEFORE the movement vector is obtained.
	var forceVector = Vector3.ZERO
	
	# this is where we get the 2D representation of what direction the player is trying to go
	var movementVector = aiHandler.get_movement_vector();
	
	# the "actual" front of our model is actually a tread, so we rotate the model by 90 degrees so it's
	# what would logically be the front.
	var rotatedMV = movementVector.rotated(deg_to_rad(90));
	
	# Body rotation angle is a directional vector that represents where we want the body to face.
	bodyRotationAngle = lerp(bodyRotationAngle, rotatedMV, delta*7.5);
	
	# This is going to be the target we're looking at. We add the directional vector of where we want to
	# look plus the body's position, and it gives us the point we want the body to face.
	var rotateVector = Vector3(bodyRotationAngle.x, 0, bodyRotationAngle.y) + %BotBody.global_position;
	
	# this function tries to make the body face the direction we give.
	look_at_safe(%BotBody, rotateVector);
	
	# then we take the 2D direction that we're trying to move in and convert them into 3D.
	# in other words, we take the body's relative front and multiply it by the x component
	# (left/right) of the movement vector. This gives us how much force and direction the
	# player will be going side to side.
	forceVector += body.global_transform.basis.x * movementVector.x;
	forceVector += body.global_transform.basis.z * movementVector.y;
	
	# move the body in the direction that we have determined we're trying to go in.sa
	body.apply_central_force(forceVector);
	
	# if we're over the player's max speed, bring us back down to the max speed.
	clamp_speed();
	
	pass;

func _on_body_entered(otherBody: Node) -> void:
	Hooks.OnCollision(%Body, otherBody);
	Hooks.OnEnemyCollision(%Body, otherBody);
	
	if otherBody.get_name() == "ArenaWall":
		Hooks.OnWallCollision(%Body);
