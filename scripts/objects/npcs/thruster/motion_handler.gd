extends MotionHandler

var aiHandler;
var nextThrust;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super();
	nextThrust = Time.get_ticks_msec() + randi_range(0, 5) * 1000
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
	if (Time.get_ticks_msec() >= nextThrust) and not thisBot.is_asleep():
		nextThrust += 1000;
		
		var forceVector = Vector3.ZERO
		var movementVector = aiHandler.get_movement_vector();
		
		forceVector += body.global_transform.basis.x * movementVector.x;
		forceVector += body.global_transform.basis.z * movementVector.y;
		
		body.apply_central_force(forceVector);
		
		SND.play_sound_at("Movement.Dash", thisBot.get_node("Body").global_position, thisBot.get_node("Body"), 0.9, randf_range(0.8, 1.2));
		
		##Rotating the body mesh towards the movement vector
		var rotatedMV = movementVector.rotated(deg_to_rad(90));
		
		bodyRotationAngle = lerp(bodyRotationAngle, rotatedMV, 1);
		
		var rotateVector = Vector3(bodyRotationAngle.x, 0, bodyRotationAngle.y) + botBodyMesh.global_position
		
		look_at_safe(botBodyMesh, rotateVector);
		clamp_speed();
	else:
		
		var forceVector = Vector3.ZERO
		var movementVector = aiHandler.get_movement_vector();
		
		##Rotating the body mesh towards the movement vector
		var rotatedMV = movementVector.rotated(deg_to_rad(90));
		
		bodyRotationAngle = lerp(bodyRotationAngle, rotatedMV, delta * 6);
		
		var rotateVector = Vector3(bodyRotationAngle.x, 0, bodyRotationAngle.y) + botBodyMesh.global_position
		
		look_at_safe(botBodyMesh, rotateVector);
		#clamp_speed();
	
	pass;
