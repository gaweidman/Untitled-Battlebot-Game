extends StatHolder3D;

##This entity can be frozen and paused, and can hold stats.
##This entity is a Robot.
class_name Robot

@export_category("General")
@export var meshes : Node3D;
@export var bodyPiece : Piece; ##The Piece this Robot is using as the 3D representation of its body.
@export var bodySocket : Socket; ## The Socket the bodyPiece gets plugged into.
var gameBoard : GameBoard;
var camera : Camera;
@export var robotNameInternal : String = "Base";
@export var robotName : String = "Basic";
@export var treads : UnderbellyContactPoints;


################################## GODOT PROCESSING FUNCTIONS

func _ready():
	load_from_startup_generator();
	super();
	grab_references();
	reassign_body_collision();
	freeze(true, true);
	detach_pipette();

func _process(delta):
	process_pre(delta);
	process_hud(delta);
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
	if not is_instance_valid(bodySocket):
		bodySocket = $Body/Meshes/Socket;
	if not is_instance_valid(bodyPiece):
		bodyPiece = $Body/Meshes/Socket/Piece_BodyCube;
	if not is_instance_valid(treads):
		treads = $Body/Treads;

func stat_registry():
	super();
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

################## SAVING/LOADING

##Stores the data required to load this robot from an editor save. Stored as the data [method bodySocket] needs to initialize the chain reaction.
@export var startupGenerator : Dictionary = { "rotation": 0.0, "occupant" : { "res://scenes/prefabs/objects/pieces/piece_bodyCube.tscn": { "sockets": { 0: { "occupant": "null", "rotation": 0.0 }, 1: { "occupant": "null", "rotation": 3.14159 }, 2: { "occupant": "null", "rotation": -2.25163 }, 3: { "occupant": "null", "rotation": -2.25158 }, 4: { "occupant": "null", "rotation": 0.0 } } } }
};

func prepare_to_save():
	print("SAVE: prep function")
	reset_collision_helpers();
	create_startup_generator();

############################## SAVE/LOAD

## Creates the data that builds this robot at _ready().
func create_startup_generator():
	#print("SAVE: generating")
	startupGenerator = { "occupant" = bodyPiece.create_startup_data(), "rotation" = 0.0 };
	#print("SAVE: end result: ", startupGenerator)
	pass;

## Creates this robot from data saved to it. If there is none, it doesn't run.
func load_from_startup_generator():
	print("SAVE: Checking validation of startupGenerator: ", is_instance_valid(startupGenerator), startupGenerator is Dictionary)
	if startupGenerator is Dictionary and not startupGenerator.is_empty():
		#bodySocket.remove_occupant(true);
		print("SAVE: Loading startup generator: ", startupGenerator)
		#print(startupGenerator);
		bodySocket.hostRobot = self;
		print("SOCKET HOST BEFORE ADDING STARTUP DATA:", bodySocket, bodySocket.hostRobot)
		bodySocket.load_startup_data(startupGenerator)
	pass;

########## HUD

func process_hud(delta):
	if Input.is_action_just_pressed("StashSelected"):
		print("Stash button pressed")
		stash_selected_piece();
		update_stash_hud();
	if Input.is_action_just_pressed("Unselect"):
		print("Unselect button pressed")
		deselect_everything();

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
	
	update_stash_hud();

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


################################# STASH

var stashHUD : PieceStash;
##The effective "inventory" of this robot. Inaccessible outside of Maker Mode for [@Robot]s that are not a [@Robot_Player].
var stashPieces : Array[Piece] = []
var stashParts : Array[Part] = []

func get_stash_pieces(equippedStatus : PieceStash.equippedStatus):
	var ret = [];
	match equippedStatus:
		PieceStash.equippedStatus.ALL:
			ret.append_array(stashPieces);
			ret.append_array(get_all_pieces());
		PieceStash.equippedStatus.EQUIPPED:
			ret.append_array(get_all_pieces());
		PieceStash.equippedStatus.NOT_EQUIPPED:
			ret.append_array(stashPieces);
	return ret;
func get_stash_parts(equippedStatus : PieceStash.equippedStatus):
	var ret = [];
	match equippedStatus:
		PieceStash.equippedStatus.ALL:
			ret.append_array(stashParts);
			ret.append_array(get_all_parts());
		PieceStash.equippedStatus.EQUIPPED:
			ret.append_array(get_all_parts());
		PieceStash.equippedStatus.NOT_EQUIPPED:
			ret.append_array(stashParts);
	return ret;
func get_stash_all(equippedStatus : PieceStash.equippedStatus):
	var ret = [];
	ret.append_array(stashPieces);
	ret.append_array(stashParts);
	return ret;

func remove_something_from_stash(inThing):
	if inThing is Piece:
		var count = 0;
		for item in stashPieces:
			if item == inThing:
				stashPieces.remove_at(count);
			count += 1;
	if inThing is Part:
		var count = 0;
		for item in stashParts:
			if item == inThing:
				stashParts.remove_at(count);
			count += 1;
	
	update_stash_hud();

func add_something_to_stash(inThing):
	if inThing is Piece:
		add_instantiated_piece_to_stash(inThing);
		update_stash_hud();
		return true;
	if inThing is Part:
		add_instantiated_part_to_stash(inThing);
		update_stash_hud();
		return true;
	if inThing is PackedScene:
		add_packed_piece_or_part_to_stash(inThing);
		update_stash_hud();
		return true;
	print(inThing, " failed to add to stash.")
	update_stash_hud();
	return false;

func add_packed_piece_or_part_to_stash(inPieceScene : PackedScene):
	var newPiece = inPieceScene.instantiate();
	if newPiece is Piece:
		add_instantiated_piece_to_stash(newPiece);
		return true;
	if newPiece is Part:
		add_instantiated_part_to_stash(newPiece);
		return true;
	print(inPieceScene, " failed to add to stash at packedScene step.")
	return false;

func add_instantiated_piece_to_stash(inPiece : Piece):
	stashPieces = Utils.append_unique(stashPieces, inPiece);
	update_stash_hud();

func add_instantiated_part_to_stash(inPiece : Part):
	Utils.append_unique(stashParts, inPiece);
	update_stash_hud();

func update_stash_hud():
	if is_instance_valid(stashHUD):
		stashHUD.regenerate_list(self);

##The path to the scene the Piece placement pipette is using.
var pipettePiecePath := "";
var pipettePieceScene : PackedScene;
var pipettePieceInstance : Piece;
var pipettePartInstance : Part;

func get_current_pipette():
	if is_instance_valid(pipettePartInstance):
		return pipettePartInstance;
	if is_instance_valid(pipettePieceInstance):
		return pipettePieceInstance;
	if is_instance_valid(pipettePieceScene):
		return pipettePieceScene;
	if is_instance_valid(pipettePiecePath):
		return pipettePiecePath;

func prepare_pipette_from_path(scenePath : String = pipettePiecePath):
	#print("Preparing pipette")
	pipettePiecePath = scenePath;
	pipettePieceScene = load(scenePath);
	prepare_pipette_from_scene(pipettePieceScene);

func prepare_pipette_from_scene(scene := pipettePieceScene):
	var newPiece = scene.instantiate();
	if newPiece is Piece:
		prepare_pipette_from_piece(newPiece);

func prepare_pipette_from_piece(newPiece : Piece):
	deselect_all_pieces();
	pipettePieceInstance = newPiece;
	pipettePieceInstance.hostRobot = self;

func prepare_pipette_from_part(newPart : Part):
	pipettePartInstance = newPart;
	pipettePartInstance.hostRobot = self;

func prepare_pipette(override : Variant = get_current_pipette()):
	if override is String: 
		prepare_pipette_from_path(override);
	if override is PackedScene: 
		prepare_pipette_from_scene(override);
	if override is Piece: 
		prepare_pipette_from_piece(override);
	if override is Part: 
		prepare_pipette_from_part(override);

func unreference_pipette():
	pipettePiecePath = "";
	pipettePieceScene = null;
	pipettePieceInstance = null;
	pipettePartInstance = null;
	update_stash_hud();

func detach_pipette():
	if is_instance_valid(pipettePieceInstance):
		pipettePieceInstance.remove_from_socket();
	unreference_pipette();

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
	#prints("Available energy:", maxEnergy, get_maximum_energy(), get_stat("Energy"))
	#print(statCollection)
	#for stat in statCollection:
		#print(stat.statName, stat.get_stat())
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
func get_global_body_rotation():
	return body.global_rotation;

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
	var colliderIDsInUse = [];
	for piece in get_all_pieces():
		piece.refresh_and_gather_collision_helpers();
		for hurtbox in piece.get_all_hurtboxes():
			print("Hurtbox Collider ID ", hurtbox.get_collider_id(), " ",hurtbox.name," ",hurtbox.originalHost)
			if not ((hurtbox.copiedByBody) or (hurtbox.get_collider_id() in colliderIDsInUse)):
				colliderIDsInUse.append(hurtbox.colliderID);
				var newHurtbox = hurtbox.make_copy();
				newHurtbox.debug_color = Color("af7fff6b");
				newHurtbox.position = Vector3(0,0,0);
				newHurtbox.disabled = false;
				body.add_child(newHurtbox, true);
				newHurtbox.owner = body;
				hurtbox.copiedByBody = true;
				newHurtbox.copiedByBody = true;

##TODO: Reimplement movement.
#@export var topSpeed : 
@export var acceleration: float = 6000.0;
@export var maxSpeed: float = 20.0;
var movementVector := Vector2.ZERO;
var movementVectorRotation := 0.0;
var bodyRotationAngle = Vector2.ZERO;
@export var bodyRotationSpeedBase := 0.80;
@export var bodyRotationSpeedMaxBase := 40.0;
var bodyRotationSpeed := bodyRotationSpeedBase;
@export var speedReductionWhileNoInput := 0.9; ##Slipperiness, basically.
var lastInputtedMV = Vector2.ZERO;

##Physics process step to adjust collision box positions according to the parts they're attached to.
func phys_process_collision(delta):
	for box in get_all_gathered_hurtboxes():
		var boxOrigin = box.originalBox;
		if is_instance_valid(boxOrigin):
			if boxOrigin.is_inside_tree():
				box.global_position = boxOrigin.global_position;
				box.rotation = boxOrigin.global_rotation - get_global_body_rotation() + box.originalRotation;
			else:
				box.disabled = true;
		else:
			box.queue_free();

##Physics process step for motion.
# custom physics handling for player movement. regular movement feels flat and boring.
func phys_process_motion(delta):
	if not is_frozen():
		##Calc the last velocity. 
		if !body.linear_velocity.is_equal_approx(Vector3.ZERO):
			lastLinearVelocity = body.linear_velocity;
		
		##Reset movement vector for the frame.
		movementVector = Vector2.ZERO;
	
		##If conscious, get the current movement vector.
		if is_conscious():
			movementVector = get_movement_vector(true);
	
		##Apply the current movement vector.
		#print("MV",movementVector);
		move_and_rotate_towards_movement_vector(delta);
		update_treads_rotation(delta);
	update_treads_position();
	pass;

func move_and_rotate_towards_movement_vector(delta : float):
	if is_paused(): return;
	#print("MV2",movementVector);
	##Rotating the body mesh towards the movement vector
	var rotatedMV = movementVector.rotated(deg_to_rad(90.0));
	#print("MV3",movementVector);

	if is_inputting_movement():
		lastInputtedMV = movementVector;
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
	else:
		body.linear_velocity *= speedReductionWhileNoInput;
	
	clamp_speed();

var lastLinearVelocity : Vector3 = Vector3.ZERO;
@export var treadsRotationSpeed : float = 6.0;
@export var treadsRotationSpeedClamp : float = 1.0;
var reversing := false;
func update_treads_rotation(delta : float):
	## Rotate the treads to look towards the movement vector.
	#var vel3 = body.linear_velocity
	#if vel3.is_equal_approx(Vector3.ZERO):
		#vel3 = lastLinearVelocity;
		#return;
	#else:
		#lastLinearVelocity = vel3;
	#var bod_vel2 = lastInputtedMV;
	##print(bod_vel2);
	#var bod_angle = bod_vel2.angle(); 
	#
	#var treads_angle = movementVectorRotation;
	#
	###Fix looping around the 180/-180 mark.
	#if treads_angle < PI / -2:
		#if bod_angle > 0:
			#bod_angle += - PI;
	#if treads_angle > PI / 2:
		#if bod_angle < 0:
			#bod_angle += PI;
	#
	#var angleDif = angle_difference(bod_angle, treads_angle);
	#
	###Adjust the body angle so it reads as being reversed when the target rotation would be more than 90 degrees.
	###Effectively, this makes the treads go in reverse instead of forward, when the angle is too steep.
	#var bod_angleAdjusted = bod_angle;
	#var reversing = false;
	#if abs(angleDif) > PI / 2:
		###print("hi")
		#reversing = true;
		#if angleDif < 0:
			#bod_angleAdjusted -= PI * 2;
		#if angleDif > 0:
			#bod_angleAdjusted += PI * 2;
	##if reversing: treads_angle -= deg_to_;
	##if reversing: treads_angle -= deg_to_rad(180);
	#
	#
	##var actualAngleDif = rad_to_deg(angle_difference(treads_angle, bod_angle));
	#var newAngle = lerp_angle(treads.rotation.y, bod_angleAdjusted, treadsRotationSpeed * delta);
	#var angleDif2 = clamp(bod_angleAdjusted - newAngle, deg_to_rad(-treadsRotationSpeedClamp), deg_to_rad(treadsRotationSpeedClamp));
	#
	#if is_inputting_movement():
		#print(angleDif2)
		#print("degrees", rad_to_deg(angleDif2))
	#
	#treads.rotation.y = treads.rotation.y + angleDif2;
	#
	
	var bodMV = body.linear_velocity.normalized();
	if bodMV.is_equal_approx(Vector3.ZERO):
		bodMV = lastLinearVelocity.normalized();
	var bodMV2 = Vector2(bodMV.x, bodMV.z);
	var bodMVA = bodMV2.angle();
	
	var prevMV = lastInputtedMV.normalized();
	var prevMVA = prevMV.angle();
	
	var inputMV = movementVector;
	if ! is_inputting_movement():
		inputMV = prevMV;
	inputMV.y *= -1;
	var inputMVA = inputMV.angle() - PI/2;
	
	var treadsMVA = treads.rotation.y;
	var treadsMV = Vector2.from_angle(treadsMVA);
	
	if treadsMVA < -PI / 2:
		if inputMVA > 0:
			inputMVA -= PI * 2;
	if treadsMVA > PI / 2:
		if inputMVA < 0:
			inputMVA += PI * 2;
	
	var angleDif = angle_difference(treadsMVA, inputMVA);
	
	if angleDif > PI/2:
		angleDif -= PI;
	if angleDif < PI/-2:
		angleDif += PI;
	
	var treadsMVAlerped = lerp_angle(treadsMVA, treadsMVA + angleDif, delta * (treadsRotationSpeed + (get_movement_speed_length() / 5)));
	treadsMVAlerped = clamp(treadsMVAlerped, treadsMVA - treadsRotationSpeedClamp, treadsMVA + treadsRotationSpeedClamp)
	
	var angleDifFromLerp = treadsMVA - treadsMVAlerped;
	
	if !is_zero_approx(get_movement_speed_length()):
		treads.rotation.y = treadsMVAlerped;
	
	var angleDif3 = 0;
	
	#if is_inputting_movement():
		#prints(prevMV, inputMV, treadsMV, rad_to_deg(treadsMVA), rad_to_deg(inputMVA), rad_to_deg(angleDif))
		#prints(rad_to_deg(inputMVA), rad_to_deg(angleDifFromLerp))
	
	
	
	treads.update_visuals_to_match_rotation( - angleDifFromLerp, get_movement_speed_length());

func update_treads_position():
	treads.global_position = get_global_body_position();

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
	return min(bodyRotationSpeedBase * spd, bodyRotationSpeedMaxBase);

func _on_collision(collider: PhysicsBody3D, thisComponent: PhysicsBody3D = body):
	SND.play_collision_sound(thisComponent, collider, Vector3.ZERO, 0.45)
	Hooks.OnCollision(thisComponent, collider);

## Makes sure the bot's speed doesn't go over its max speed.
func clamp_speed():
	body.clamp_speed()
	return;

## Runs the Reset function on all collision helpers on all Pieces.
func reset_collision_helpers():
	for piece in get_all_pieces():
		piece.reset_collision_helpers();

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

func on_add_piece(piece:Piece):
	remove_something_from_stash(piece);
	reassign_body_collision();
	piece.owner = self;
	for abilityKey in piece.activeAbilities.keys():
		var ability = piece.activeAbilities[abilityKey];
		if ability is AbilityManager:
			print("Adding ability ", ability.abilityName)
			assign_ability_to_next_active_slot(ability);
	get_all_pieces_regenerate();
	pass;

func on_remove_piece(piece:Piece):
	piece.owner = null;
	remove_abilities_of_piece(piece);
	get_all_pieces_regenerate();
	pass;

func remove_abilities_of_piece(piece:Piece):
	for abilityKey in active_pieces:
		var ability = active_pieces[abilityKey];
		if ability is AbilityManager:
			if ability.get_assigned_piece_or_part() == piece:
				unassign_ability_slot(abilityKey);


var allPieces : Array[Piece]= [];
func get_all_pieces():
	if allPieces.is_empty():
		get_all_pieces_regenerate();
	return allPieces;

##Returns a freshly gathered array of all pieces attached to this Robot and which have it set as their host.
func get_all_pieces_regenerate() -> Array[Piece]:
	var piecesGathered : Array[Piece] = [];
	for child in Utils.get_all_children_of_type(body, Piece):
		if child.hostRobot == self:
			piecesGathered.append(child);
	allPieces = piecesGathered;
	return piecesGathered;

##Returns a freshly gathered array of all pieces attached to this Robot and whih have it set as their host.
func get_all_parts() -> Array[Part]:
	var piecesGathered : Array[Part] = [];
	for piece in get_all_pieces():
		Utils.append_array_unique(piecesGathered, piece.get_all_parts());
	return piecesGathered;

##Returns an array of all PieceCollisionBox nodes that are direct children of the body.
func get_all_gathered_hurtboxes():
	var boxes = []
	for child in body.get_children():
		if child is PieceCollisionBox:
			boxes.append(child)
	return boxes;

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
				unassign_ability_slot(slot);

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


########################## SELECTION

var selectedPiece : Piece;
var selectedPart : Part;

func is_piece_selected() -> bool:
	return is_instance_valid(selectedPiece);
func is_pipette_loaded() -> bool:
	return is_instance_valid(pipettePieceInstance) or is_instance_valid(pipettePartInstance);
## Returns what's selected, or what's in the pipette. Returns [code]null[/code] elsewise.[br]Priority is [member pipettePartPath] > [member pipettePiecePath] > [member selectedPart] > [member selectedPiece] > [code]null[/code].
func get_selected_or_pipette():
	#if is_instance_valid(pipettePartPath): ##TODO: Part pipette logic.
		#return pipettePartPath;
	var pipette = get_current_pipette();
	if is_instance_valid(pipette):
		return pipette;
	var selected = get_selected();
	if is_instance_valid(selected):
		return selected;
	return null;

## Returns what's selected. Returns [code]null[/code] if it's invalid.[br]Priority is [member selectedPart] > [member selectedPiece] > [code]null[/code].
func get_selected():
	if is_instance_valid(selectedPart):
		return selectedPart;
	if is_instance_valid(selectedPiece):
		return selectedPiece;
	return null;

func deselect_everything():
	detach_pipette();
	deselect_all_parts();
	deselect_all_pieces();

func deselect_all_pieces(ignoredPiece : Piece = null):
	for piece in get_all_pieces():
		if ignoredPiece == null or piece != ignoredPiece:
			if piece.get_selected():
				piece.deselect();
	if ignoredPiece == null or selectedPiece != ignoredPiece:
		selectedPiece = null;
	#detach_pipette()
	update_stash_hud();
	pass;

func select_piece(piece : Piece):
	if is_instance_valid(piece):
		var result = piece.select();
		if result:
			selectedPiece = piece;
			print("Selected Piece: ", selectedPiece)
			deselect_all_pieces(piece);
			return piece;
		else:
			deselect_all_pieces();
			selectedPiece = null;
	return null;

func deselect_all_parts(ignoredPart : Part = null):
	for part in get_all_parts():
		if ignoredPart == null or part != ignoredPart:
			part.select(false);
	if ignoredPart == null or selectedPart != ignoredPart:
		selectedPart = null;

func select_part(part : Part):
	if is_instance_valid(part):
		deselect_all_parts(part)
		part.select(true);
		selectedPart = part;
		return part;
	return null;

######################## STASH

func stash_selected_piece():
	if is_instance_valid(selectedPiece):
		print("Attempting to stash ", selectedPiece)
		if selectedPiece.removable:
			selectedPiece.remove_and_add_to_robot_stash(self);

##TODO: Parts and Engine bs.
func stash_selected_part():
	if is_instance_valid(selectedPart):
		print("Attempting to stash ", selectedPart)
		#if selectedPiece.removable:
			#selectedPiece.remove_and_add_to_robot_stash(self);
