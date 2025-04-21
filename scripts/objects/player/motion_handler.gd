extends MotionHandler

class_name MotionHandlerPlayer

var inputHandler;
var combatHandler;


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
		combatHandler = thisBot.get_node("CombatHandler");
	

# custom physics handling for player movement. regular movement feels flat and boring.
func _physics_process(delta):
	super(delta);
		
	var movementVector = Vector2.ZERO;
	if GameState.get_in_state_of_play() and combatHandler.health > 0:
		movementVector = inputHandler.get_movement_vector();
	
	##Rotating the body mesh towards the movement vector
	var rotatedMV = movementVector.rotated(deg_to_rad(90));

	if InputHandler.is_inputting_movement():
		bodyRotationAngle = lerp(bodyRotationAngle, movementVector.rotated(deg_to_rad(90)), delta * 10)
	
	var rotateVector = Vector3(bodyRotationAngle.x, 0, bodyRotationAngle.y) + botBodyMesh.global_position

	look_at_safe(botBodyMesh, rotateVector)
	
	var forceVector = Vector3.ZERO
	forceVector += body.global_transform.basis.x * movementVector.x * -GameState.PLAYER_ACCELERATION;
	forceVector += body.global_transform.basis.z * movementVector.y * -GameState.PLAYER_ACCELERATION;
	body.apply_central_force(forceVector);
	clamp_speed();

	pass;

func _on_collision(this, other):
	Hooks.OnCollision(%Body, other);
	Hooks.OnPlayerCollision(other);
	print("COLLISION HERE");
	print(other, other.is_in_group("Combatant"), other.get_groups())
	#if other.is_in_group("Combatant") && 
	#if (other.is_in_group("Projectile") && other.get_attacker() != thisBot) || other.is_in_group("MeleeWeapon") || other.is_in_group("Combatant"):
		##print(other.get_attacker())
		#combatHandler.take_damage(1);
