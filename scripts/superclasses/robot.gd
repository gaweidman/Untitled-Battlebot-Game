extends MakesNoise;

class_name Robot

@export_category("General")
@export var body : RobotBody;
@export var meshes : Node3D;
var bodyPiece : Piece; ##The Piece this Robot is using as the 3D representation of its body.
var gameBoard : GameBoard;
var camera : Camera;


################################## GODOT PROCESSING FUNCTIONS

func _ready():
	grab_references();
	reassign_body_collision();
	freeze(true, true);

func _process(delta):
	process_pre(delta);
	pass

func _physics_process(delta):
	#motion_process()
	phys_process_pre(delta);
	phys_process_motion(delta);
	phys_process_combat(delta);
	pass

##Process and Physics process that run before anything else.
func process_pre(delta):
	grab_references();
	pass;
func phys_process_pre(delta):
	grab_references();
	##Freeze this bot before it can do physics stuff.
	if freezeQueued: freeze(true);
	if not is_frozen():
		sleepTimer -= delta;
	pass;

##Grab all variable references to nodes that can't be declared with exports.
func grab_references():
	if not is_instance_valid(gameBoard):
		gameBoard = GameState.get_game_board();
	if not is_instance_valid(camera):
		camera = GameState.get_camera();

######################### STATE CONTROL

var spawned := false;
var frozen := false;
@export var sleepTimerLength := 0.0;
var sleepTimer := sleepTimerLength; ## An amount of time in which this robot isn't allowed to do anything after spawning.
func is_asleep() -> bool:
	return sleepTimer > 0;
var linearVelocityBeforeFreeze := Vector3.ZERO
func freeze(doFreeze := not frozen, force := false):
	freezeQueued = false; ##Cancel the freeze queue.
	if not force: if frozen == doFreeze: return;
	frozen = doFreeze;
	
	##If freezing, save previous linear velocity.
	if doFreeze:
		linearVelocityBeforeFreeze = body.linear_velocity;
		body.gravity_scale = 0;
	
	##Lock up linear velocities while frozen.
	body.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC;
	body.set_freeze_enabled(doFreeze);
	
	##If unfreezing, add an impule for the velocity we had before.
	if not doFreeze:
		body.apply_central_impulse(linearVelocityBeforeFreeze)
		body.gravity_scale = 1;
	pass;
func unfreeze(force := false):
	freeze(false, force);
func is_frozen(): return frozen;
var freezeQueued := false;
##This function sets a flag to freeze the robot during the next frame.
func queue_freeze_next_frame():
	freezeQueued = true;
##This function returns true only if the bot is spawned in, alive, awake, and not frozen.
func is_conscious():
	return spawned and (not is_asleep()) and (not is_frozen()) and is_alive();


func is_playing():
	return true;
	#return (not get_frozen()) and (is_alive()) and GameState.get_in_state_of_play();
func is_building(): return GameState.get_in_state_of_building();

##Fired by the gameboard when a new game starts.
func start_new_game():
	pass;
##Fired by the gameboard when the round ends.
func end_round():
	pass;
##Fired by the gameboard when the shop gets opened.
##In here and not in the player subset just in case.
func enter_shop():
	pass;

##Function run when the bot first spawns in.
func live():
	unfreeze(true);
	show();
	spawned = true;

func die():
	#Hooks.OnDeath(self, GameState.get_player()); ##TODO: Fix hooks to use new systems before uncommenting this.
	alive = false;
	queue_free();
	##Play the death sound
	if GameState.get_in_state_of_play():
		SND.play_sound_nondirectional(deathSound);
	##Play the death particle effects.
	ParticleFX.play("NutsBolts", GameState.get_game_board(), body.global_position);


################################# EDITOR MODE
##The path to the scene the Piece placement pipette is using.
var pipettePiecePath := "res://scripts/superclasses/piece_bumper_T.tscn";
var pipettePieceScene := preload("res://scripts/superclasses/piece_bumper_T.tscn");
var pipettePieceInstance : Piece = pipettePieceScene.instantiate();

func prepare_pipette(scenePath := pipettePiecePath):
	#print("Preparing pipette")
	pipettePiecePath = scenePath;
	pipettePieceScene = load(scenePath);
	if is_instance_valid(pipettePieceInstance):
		pipettePieceInstance.queue_free();
	pipettePieceInstance = pipettePieceScene.instantiate();
	pipettePieceInstance.hostRobot = self;

func detach_pipette():
	pipettePieceScene = null;
	pipettePieceInstance = null;

################################## HEALTH AND LIVING


@export_category("Combat Handling")

@export var deathSound := "Combatant.Die";

#TODO: Reimplement all stuff involving taking damage, knockback, and invincibility.

@export_category("Health Management")
##Game statistics.
@export var maxHealth := 1.0;
var health := maxHealth;

func get_max_health():
	##TODO: Add bonuses into this calc.
	return maxHealth;

func take_damage(damage:float):
	if is_playing():
		if invincible && damage > 0:
			return;
		#if !(GameState.get_setting("godMode") == true && self is Robot_Player):
			#health -= damage;
			##TODO: Make Robot_Player class.
		set_invincibility();
		if health <= 0.0:
			die();
			health = 0.0;
		if health > get_max_health():
			health = get_max_health();

func heal(health:float):
	take_damage(-health)

func is_alive():
	return alive;

var invincible := false;
var invincibleTimer := 0.0;
@export var maxInvincibleTimer := 0.25; #TODO: Add in bonuses for this.
var alive := true;

##Replaces the invincible timer with the value given (Or maxInvincibleTimer by default) if that value is greater than the current invincibility timer.
func set_invincibility(amountOverride : float = maxInvincibleTimer):
	invincibleTimer = max(invincibleTimer, amountOverride);

func take_knockback(inDir:Vector3):
	body.call_deferred("apply_impulse", inDir);
	pass

##Physics process for combat. 
func phys_process_combat(delta):
	if invincibleTimer > 0:
		invincibleTimer -= delta;

################################## ENERGY

@export_category("Energy Management")
@export var maxEnergy := 3.0;
var energy := maxEnergy;
@export var energyRefreshRate := 2.0;

##Returns available power. Whenever something is used in a frame, it should detract from the energy variable.
func get_available_energy() -> float:
	return energy;

func get_maximum_energy() -> float:
	##TODO: Reimplement max Energy bonuses and stuff.
	return maxEnergy;

##Returns true or false depending on whether the sap would work or not.
func try_sap_energy(amount):
	if amount <= get_available_energy():
		energy -= amount;
		return true;
	else:
		return false;

##Adds to the energy total. 
##If told to "cap at max" it will not add energy if it is above or at the current maximum, and will clamp it at the max. 
##If told NOT to "cap at max" it will just flat add the energy amount. 
func generate_energy(amount, capAtMax := true):
	if capAtMax: 
		if energy < get_maximum_energy():
			energy = clamp(energy + amount, 0, get_maximum_energy());
	else:
		energy += amount;

################################# MOTION HANDLER STUFF

@export_category("Motion Handling")


#TODO: Implement "target pointer" to be used in mouse aiming and AI targeting. 


func get_global_body_position():
	return body.global_position;

##Should fire whenever a Piece connected to this robot gets hit by something.
func on_hitbox_collision(body : PhysicsBody3D, pieceHit : Piece):
	pass;

##Gives the Body new collision based on its Parts.
##Currently commented out because of rotation shenanigans. Maybe take another look at this later.
func reassign_body_collision():
	#return;
	##First, clear the Body of all collision shapes.
	for child in body.get_children(false):
		if child is PieceCollisionBox:
			child.queue_free();
	
	##Then, gather copies of every Hitbox collider from all pieces, and assign a copy of it to the Body.
	for piece in get_all_pieces():
		for hitbox in piece.get_all_hurtboxes():
			var newHitbox = hitbox.duplicate();
			#newHitbox.position = hitbox.position;
			newHitbox.position = Vector3(0,0,0);
			newHitbox.disabled = false;
			hitbox.add_child(newHitbox);
			newHitbox.reparent(body, true);

##TODO: Reimplement movement.
#@export var topSpeed : 
@export var acceleration: float = 6000.0;
@export var maxSpeed: float = 20.0;
var movementVector := Vector2.ZERO;
var movementVectorRotation := 0.0;
var bodyRotationAngle = Vector2.ZERO;
@export var bodyRotationSpeed := 10;
@export var speedReductionWhileNoInput := 0.9; ##Slipperiness.
var lastInputtedMV = Vector2.ZERO;

##Physics process step for motion.

# custom physics handling for player movement. regular movement feels flat and boring.
func phys_process_motion(delta):
	##Reset movement vector for the frame.
	movementVector = Vector2.ZERO;
	
	##If conscious, get the current movement vector.
	if is_conscious():
		movementVector = get_movement_vector(true);
	
	##If not frozen, apply the current movement vector.
	if not is_frozen():
		#print("MV",movementVector);
		move_and_rotate_towards_movement_vector(delta)
	
	pass;

func move_and_rotate_towards_movement_vector(delta : float):
	#print("MV2",movementVector);
	##Rotating the body mesh towards the movement vector
	var rotatedMV = movementVector.rotated(deg_to_rad(90.0));
	#print("MV3",movementVector);

	if is_inputting_movement():
		var movementVectorRotated = movementVector.rotated(deg_to_rad(90.0 + randf()))
		var vectorToRotTo = Vector2(movementVectorRotated.x, -movementVectorRotated.y)
		bodyRotationAngle = vectorToRotTo
		
	
	var rotateVector = Vector3(bodyRotationAngle.x, 0.0, bodyRotationAngle.y) + body.global_position

	body.update_target_rotation(bodyRotationAngle, delta * bodyRotationSpeed);
	#Utils.look_at_safe(meshes, rotateVector);
	
	##Get 
	if is_inputting_movement():
		#print("HI")
		var forceVector = Vector3.ZERO;
		var bodBasis := body.global_basis;
		forceVector += body.global_transform.basis.x * movementVector.x * -acceleration;
		forceVector += body.global_transform.basis.z * movementVector.y * -acceleration;
		#print(forceVector)
		var bodBasisRotationOrthonormalized := bodBasis.orthonormalized();
		var bodBasisRotation = bodBasisRotationOrthonormalized.get_euler();

		##Rotate the force vector so the body's rotation doesn't meddle with it.
		forceVector = forceVector.rotated(Vector3(0.0,1.0,0.0), float(-bodBasisRotation.y));
		#print(forceVector)
		body.apply_central_force(forceVector);
		#print(movementVector)
		lastInputtedMV = Vector2(body.linear_velocity.x, body.linear_velocity.z)
	else:
		body.linear_velocity *= speedReductionWhileNoInput;
	
	clamp_speed();

##This is empty here, but the Player and Enemy varieties of this should have things for gathering input / getting player location respectively.
func get_movement_vector(rotatedByCamera : bool = false) -> Vector2:
	var vectorOut = Vector2(0.0,0.0);
	movementVector = vectorOut;
	movementVectorRotation = movementVector.angle();
	return movementVector.normalized();

var inputtingMovementThisFrame := false; ##This should be set by AI bots before phys_process_motion is called to notify whether to update their position or not this frame.
func is_inputting_movement():
	return inputtingMovementThisFrame;

func _on_collision(collider: PhysicsBody3D, thisComponent: PhysicsBody3D = body):
	SND.play_collision_sound(thisComponent, collider, Vector3.ZERO, 0.45)
	Hooks.OnCollision(thisComponent, collider);

# make sure the bot's speed doesn't go over its max speed
func clamp_speed():
	body.clamp_speed()
	return;
	var speedMin = Vector2(maxSpeed, maxSpeed)
	body.linear_velocity.x = clamp(body.linear_velocity.x, -maxSpeed, maxSpeed);
	body.linear_velocity.z = clamp(body.linear_velocity.z, -maxSpeed, maxSpeed);

##################################################### 3D INVENTORY STUFF

@export_category("Piece Management")
var active_pieces := []

##Whenever a new piece is added, add it to the list.
##There needs to be UI for all pieces you have active.


##Returns a freshly gathered array of all pieces attached to this Robot.
func get_all_pieces() -> Array[Piece]:
	var piecesGathered : Array[Piece] = [];
	for child in Utils.get_all_children(body):
		if child is Piece:
			if child.hostRobot == self:
				piecesGathered.append(child);
	return piecesGathered;
