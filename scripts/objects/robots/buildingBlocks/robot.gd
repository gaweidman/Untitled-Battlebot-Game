extends StatHolder3D;

##This entity can be frozen and paused, and can hold stats.
##This entity is a Robot.
class_name Robot

@export_category("General")
@export var meshes : Node3D;
var bodyPiece : Piece; ##The Piece this Robot is using as the 3D representation of its body.
var gameBoard : GameBoard;
var camera : Camera;


################################## GODOT PROCESSING FUNCTIONS

func _ready():
	super();
	grab_references();
	reassign_body_collision();
	freeze(true, true);

func _process(delta):
	process_pre(delta);
	pass

func _physics_process(delta):
	#motion_process()
	super(delta);
	phys_process_collision(delta);
	phys_process_motion(delta);
	phys_process_combat(delta);
	pass

##Process and Physics process that run before anything else.
func process_pre(delta):
	grab_references();
	pass;

func phys_process_pre(delta):
	super(delta);
	grab_references();
	##Freeze this bot before it can do physics stuff.
	if not is_frozen():
		sleepTimer -= delta;
	pass;

##Grab all variable references to nodes that can't be declared with exports.
func grab_references():
	if not is_instance_valid(gameBoard):
		gameBoard = GameState.get_game_board();
	if not is_instance_valid(camera):
		camera = GameState.get_camera();

func stat_registry():
	register_stat("HealthMax", maxHealth, statIconDamage);
	register_stat(
		"Health", 
		maxHealth, 
		statIconDamage, 
		null, 
		(
		func(newValue): 
			health_or_energy_changed.emit(); 
			var newValFixed = clampf(newValue, 0.0, get_stat("HealthMax")); 
			print("new health value", newValFixed); 
			return newValFixed;
			),
		StatTracker.roundingModes.None
		);
	register_stat("EnergyMax", maxEnergy, statIconDamage);
	register_stat("Energy", maxEnergy, statIconEnergy, null, (func(newValue): health_or_energy_changed.emit(); return clampf(newValue, 0.0, get_stat("EnergyMax"))));
	register_stat("EnergyRefreshRate", energyRefreshRate, statIconEnergy);
	register_stat("InvincibilityTime", maxInvincibleTimer, statIconCooldown);
	register_stat("MovementSpeedAcceleration", acceleration, statIconCooldown);
	register_stat("MovementSpeedMax", maxSpeed, statIconCooldown);
	pass;

######################### STATE CONTROL

var spawned := false;
@export var sleepTimerLength := 0.0;
var sleepTimer := sleepTimerLength; ## An amount of time in which this robot isn't allowed to do anything after spawning.
##Returns true if there's an active sleep timer going. Sleep should be used to prevent actions for a bit on enemies, and maybe "stun" status effects in the future.
func is_asleep() -> bool:
	return sleepTimer > 0;

##This function returns true only if the game is not paused, and the bot is spawned in, alive, awake, and not frozen.
func is_conscious():
	return (not paused) and spawned and (not is_asleep()) and (not is_frozen()) and is_alive();

##This function returns true only if the game is not paused, the bot is not frozen, alive, and we're in a game state of play.
func is_playing():
	#return true;
	return (not paused) and (not is_frozen()) and (is_alive()) and GameState.get_in_state_of_play();
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
	body.show();
	spawned = true;
	alive = true;
	set_stat("Health", get_max_health());

func die():
	#Hooks.OnDeath(self, GameState.get_player()); ##TODO: Fix hooks to use new systems before uncommenting this.
	alive = false;
	queue_free();
	##Play the death sound
	if GameState.get_in_state_of_play():
		SND.play_sound_nondirectional(deathSound);
	##Play the death particle effects.
	ParticleFX.play("NutsBolts", GameState.get_game_board(), get_global_body_position());
	ParticleFX.play("BigBoom", GameState.get_game_board(), get_global_body_position());


################################# EDITOR MODE
##The path to the scene the Piece placement pipette is using.
var pipettePiecePath := "res://scenes/prefabs/objects/pieces/piece_bumper_T.tscn";
var pipettePieceScene := preload("res://scenes/prefabs/objects/pieces/piece_bumper_T.tscn");
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

## Emitted when Health or Energy are changed.
signal health_or_energy_changed();

func _on_health_or_energy_changed():
	pass # Replace with function body.

@export var deathSound := "Combatant.Die";

#TODO: Reimplement all stuff involving taking damage, knockback, and invincibility.

@export_category("Health Management")
##Game statistics.
@export var maxHealth := 3.0;

func get_health():
	return get_stat("Health");

func get_max_health():
	##TODO: Add bonuses into this calc.
	return get_stat("HealthMax");

func take_damage(damage:float):
	print("ASASASSA")
	if is_playing():
		print(damage," damage being taken.")
		var health = get_health();
		#if invincible && damage > 0:
			#return;
		#if !(GameState.get_setting("godMode") == true && self is Robot_Player):
			#health -= damage;
		health -= damage;
		set_invincibility();
		if health <= 0.0:
			health = 0.0;
			die();
		if health > get_max_health():
			health = get_max_health();
		set_stat("Health", health);

func heal(health:float):
	take_damage(-health);

func is_alive():
	return alive;

var invincible := false;
var invincibleTimer := 0.0;
@export var maxInvincibleTimer := 0.25; #TODO: Add in bonuses for this.
var alive := false;

##Replaces the invincible timer with the value given (Or maxInvincibleTimer by default) if that value is greater than the current invincibility timer.
func set_invincibility(amountOverride : float = maxInvincibleTimer):
	invincibleTimer = max(invincibleTimer, amountOverride);

func take_knockback(inDir:Vector3):
	body.call_deferred("apply_impulse", inDir);
	pass

##Physics process for combat. 
func phys_process_combat(delta):
	if not is_frozen():
		if invincibleTimer > 0:
			invincibleTimer -= delta;

################################## ENERGY

@export_category("Energy Management")
@export var maxEnergy := 3.0;
@export var energyRefreshRate := 1.65;

##Returns available power. Whenever something is used in a frame, it should detract from the energy variable.
func get_available_energy() -> float:
	return get_stat("Energy");

func get_maximum_energy() -> float:
	return get_stat("EnergyMax");

##Returns true or false depending on whether the sap would work or not.
func try_sap_energy(amount):
	var energy = get_available_energy();
	if amount <= energy:
		energy -= amount;
		set_stat("Energy", energy);
		return true;
	else:
		return false;

##Adds to the energy total. 
##If told to "cap at max" it will not add energy if it is above or at the current maximum, and will clamp it at the max. 
##If told NOT to "cap at max" it will just flat add the energy amount. 
func generate_energy(amount, capAtMax := true):
	var energy = get_available_energy();
	if capAtMax: 
		if energy < get_maximum_energy():
			energy = clamp(energy + amount, 0, get_maximum_energy());
	else:
		energy += amount;
	set_stat("Energy", energy);

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
@export var bodyRotationSpeedBase := 0.80;
var bodyRotationSpeed := bodyRotationSpeedBase;
@export var speedReductionWhileNoInput := 0.9; ##Slipperiness, basically.
var lastInputtedMV = Vector2.ZERO;

##Physics process step to adjust collision box positions according to the parts they're attached to.
func phys_process_collision(delta):
	for box in get_all_gathered_hurtboxes():
		var boxOrigin = box.originalHost;
		box.position = boxOrigin.global_position - get_global_body_position() + box.originalOffset;
		box.global_rotation = boxOrigin.global_rotation;

##Physics process step for motion.
# custom physics handling for player movement. regular movement feels flat and boring.
func phys_process_motion(delta):
	if not is_frozen():
		##Reset movement vector for the frame.
		movementVector = Vector2.ZERO;
	
		##If conscious, get the current movement vector.
		if is_conscious():
			movementVector = get_movement_vector(true);
	
		##Apply the current movement vector.
		#print("MV",movementVector);
		move_and_rotate_towards_movement_vector(delta)
	
	pass;

func move_and_rotate_towards_movement_vector(delta : float):
	if is_paused(): return;
	#print("MV2",movementVector);
	##Rotating the body mesh towards the movement vector
	var rotatedMV = movementVector.rotated(deg_to_rad(90.0));
	#print("MV3",movementVector);

	if is_inputting_movement():
		var movementVectorRotated = movementVector.rotated(deg_to_rad(90.0 + randf()))
		var vectorToRotTo = Vector2(movementVectorRotated.x, -movementVectorRotated.y)
		bodyRotationAngle = vectorToRotTo
		
	
	var rotateVector = Vector3(bodyRotationAngle.x, 0.0, bodyRotationAngle.y) + body.global_position
	
	bodyRotationSpeed = get_rotation_speed();
	
	body.update_target_rotation(bodyRotationAngle, delta * bodyRotationSpeed);
	#Utils.look_at_safe(meshes, rotateVector);
	
	##Get 
	if is_inputting_movement():
		var accel = get_stat("MovementSpeedAcceleration")
		#print("HI")
		var forceVector = Vector3.ZERO;
		var bodBasis := body.global_basis;
		forceVector += body.global_transform.basis.x * movementVector.x * -accel;
		forceVector += body.global_transform.basis.z * movementVector.y * -accel;
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
func get_movement_speed_length():
	return body.linear_velocity.length();

func get_rotation_speed():
	var spd = get_movement_speed_length();
	return bodyRotationSpeedBase * spd;

func _on_collision(collider: PhysicsBody3D, thisComponent: PhysicsBody3D = body):
	SND.play_collision_sound(thisComponent, collider, Vector3.ZERO, 0.45)
	Hooks.OnCollision(thisComponent, collider);

# make sure the bot's speed doesn't go over its max speed
func clamp_speed():
	body.clamp_speed()
	return;

##################################################### 3D INVENTORY STUFF

@export_category("Piece Management")
var active_pieces : Dictionary[int, AbilityManager] = {
	0 : null,
	1 : null,
	2 : null,
	3 : null,
	4 : null,
}

##TODO: There needs to be UI for all pieces you have active, as well as pieces generally in your tree.

##Returns a freshly gathered array of all pieces attached to this Robot and whih have it set as their host.
func get_all_pieces() -> Array[Piece]:
	var piecesGathered : Array[Piece] = [];
	for child in Utils.get_all_children_of_type(body, Piece):
		if child.hostRobot == self:
			piecesGathered.append(child);
	return piecesGathered;

##Returns an array of all PieceCollisionBox nodes that are direct children of the body.
func get_all_gathered_hurtboxes():
	return Utils.get_all_children_of_type(body, PieceCollisionBox, body);

##Adds an AbilityManager to the given slot index in active_pieces.
func assign_ability_to_slot(slotNum : int, abilityManager : AbilityManager):
	if slotNum in active_pieces.keys():
		if is_instance_valid(abilityManager):
			abilityManager.assign_robot(self);
			active_pieces[slotNum] = abilityManager;

##Turns the given slot null and unassigns this robot from that ability on the resource.
func unassign_ability_slot(slotNum : int):
	if slotNum in active_pieces.keys():
		if active_pieces[slotNum] is AbilityManager: 
			var abilityManager = active_pieces[slotNum];
			if is_instance_valid(abilityManager):
				abilityManager.unassign_robot();
	active_pieces[slotNum] = null;

##Runs thru active_pieces and deletes AbilityManager resources that no longer have a valid Piece or Part reference.
func check_abilities_are_valid():
	for slot in active_pieces.keys():
		var ability = active_pieces[slot];
		if ability is AbilityManager:
			if !is_instance_valid(ability.assignedPieceOrPart):
				unassign_ability_slot(ability);

##Attempts to fire the active ability in the given slot, if that slot has one.
func fire_active(slotNum):
	check_abilities_are_valid();
	if slotNum in active_pieces.keys():
		var ability = active_pieces[slotNum];
		if ability is AbilityManager:
			ability.call_ability();

##Grabs the next ability slot that is currently null.
func get_next_available_active_slot():
	check_abilities_are_valid();
	var allKeys = active_pieces.keys().duplicate(true);
	while allKeys.size() > 0:
		var slotNum = allKeys.pop_front();
		var ability = active_pieces[slotNum];
		if ability == null:
			return slotNum;
	return null;

##Assigns an ability to the next available slot, if there are any.
func assign_ability_to_next_active_slot(abilityManager : AbilityManager):
	var slot = get_next_available_active_slot();
	if slot == null: return;
	assign_ability_to_slot(slot, abilityManager);

func deselect_all_pieces(ignoredPiece : Piece):
	for piece in get_all_pieces():
		if piece != ignoredPiece:
			piece.deselect();
	pass;

func select_piece(piece : Piece):
	if is_instance_valid(piece):
		deselect_all_pieces(piece);
		piece.select(true);

func select_part(part : Part):
	part.select(true);
