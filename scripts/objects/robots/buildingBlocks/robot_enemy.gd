@icon ("res://graphics/images/class_icons/robot_enemy.png")
extends Robot

class_name Robot_Enemy
## Holds some helper functions for enemy [Robot]s that would be useless for a [Robot_Player].

var frontRay : RayCast3D;
var playerRay : RayCast3D;
var directionRay : RayCast3D;
@export_subgroup("Salvage Pricing")
@export var salvagePrice := 1; ## How much money the player earns from killing this, ON TOP OF the salvage price of each piece.
@export var salvagePriceMultiplier := 2./5.; ## Multiplied by the salvage value of each piece, plus [member salvagePrice].
@export var salvagePricePieceChange := 2./3.; ## The rough chance that each piece gives its salvage value on death.

@export_subgroup("AI Properties")
var frontRayCollision = null;## Collider gathered in [method update_front_ray_result]. Set to null if invalid.
var frontRayColType : rayColTypes = rayColTypes.NONE; ## Collider type in [enum rayColTypes] gathered in [method update_front_ray_result] based on [member frontRayCollision]. 
var frontRayNormal = Vector3(0,0,0).normalized();## Collision normal gathered in [method update_front_ray_result]. Set to null if invalid.
var frontDirection := Vector2(0,1).normalized();## The front of the robot, determined by body rotation.
@export var frontRayDistance = 5.0; ## How long the front collision ray should be.
var frontRayDistanceToPoint = 0.0; ## Calculated in [method update_front_ray_result]. how far away from colliding the bot is directly in front of it.
@export var chasesPlayerInReverse := false; ##@experimental: When set to true, this bot will go into reverse when the player is behind them.
@export var playerChaseDistance := 30.; ## The distance from the player this enemy needs to be for this robot to notice them.
@export var playerKiteDistance := 15.; ## The distance form the player this enemy needs to be before they can start to kite.
@export var playerStrafeDistance := 9.; ## The distance from the player this enemy needs to be before they can start to strafe or idle.
@export var playerCloseDistance := 7.; ## The distance from the player this enemy needs to be before they are considered "too close".
@export var kitingAngle := 80.0; ## The angle at which the bot will kite or strafe towards, if it has that behavior.
var kitingDir = 80.0; ## The current strafe/kite angle.
## Used by pointer swivels. They will try to point to this global position when on an enemy.
var pointerTarget := Vector3(0,0,0);
var pointerTargetAngleOffsetStorage := 0.0;
var playerWallDodgeVector : Vector2;
var playerWallDodgeAngle : float;

var homePosition := Vector3.ZERO;
var regenLenToHome := false;
var currentLenToHome : float = -1.:
	get:
		if regenLenToHome or currentLenToHome < 0:
			currentLenToHome = (homePosition - get_global_body_position()).length();
		return currentLenToHome;
@export var homeRetreatDistance := 20.; ## The distance away from this robot's spawn position it's allowed to stray from, if it has the trait [enum traits.RETREATS_TO_HOME].

@export_range(0.1, 100., 0.0001, "or_greater") var timeBetweenCharges_min := 5.0; ## The minimum amount of time between charges, for use if it has the trait [enum traits.CHARGES_PERIODICALLY].
@export_range(0.1, 100., 0.0001, "or_greater") var timeBetweenCharges_max := 7.0; ## The maximum amount of time between charges, for use if it has the trait [enum traits.CHARGES_PERIODICALLY].
var chargeStartTimer := timeBetweenCharges_max;
@export var chargeTime := 5.0; ## The amount of time a charge can last before it auto-expires, if it has the trait [enum traits.CHARGES_PERIODICALLY].
var chargeRunTimer := -1.;
var canCharge :bool:
	get:
		return is_zero_approx(chargeStartTimer) and is_zero_approx(chargeRunTimer);
var isCharging :bool:
	get:
		return chargeRunTimer > 0;
var chargeVector :=Vector2.ZERO;
func tick_charging_cooldowns(delta):
	if chargeRunTimer > 0:
		chargeRunTimer -= delta;
	else:
		if chargeStartTimer > 0:
			chargeStartTimer -= delta;
func try_start_charge():
	if canCharge:
		chargeRunTimer = chargeTime;
		chargeStartTimer = randf_range(timeBetweenCharges_min, timeBetweenCharges_max);
		chargeVector = get_basic_player_chase_vector();
		return true;
	return false;

func on_collision_with_robot_body():
	chargeRunTimer = -1;
	reverse_kiting();


@export var cowardiceHealthPercent: float = 0.40; ## The percentage of health the bot needs to be below before it will start to run away, if it has the trait [enum traits.HEALTH_COWARD].
## [code]true[/code] if current health is below [member cowardiceHealthPercent].
var healthCowardTime : bool:
	get:
		return (get_stat("Health") / get_stat("HealthMax")) <= cowardiceHealthPercent;

## Switches the direction of the kiting.
func reverse_kiting():
	kitingDir *= -1;

## @experimental: A list of traits that make up an enemy's decision-making.
enum traits {
	CHASES, ## The bot will attempt to chase the player relentlessly.
	CHASE_IN_REVERSE, ## Requires [enum traits CHASES].[br]The bot will attempt to chase you with its treads put into reverse.
	CHASE_AVOIDS_WALLS, ## Requires [enum traits CHASES].[br]If the bot has this trait, it will attempt to avoid walls using its raycast each frame while it chases you. 
	RUNS_WHEN_CLOSE, ## The bot will attempt to run away from the player when they get close, based on [member playerCloseDistance]. 
	PLAYS_KEEPAWAY, ## When the player is below [member playerStrafeDistance], this bot will stand. Good paired with [enum traits.RUNS_WHEN_CLOSE].
	WANDERS_WHEN_IDLE, ## When the player is not in chase range, the bot will wander.
	STRAFES, ## When the bot is within [member playerStrafeDistance] from the player, they will attempt to strafe until they bonk into a wall.
	KITES, ## When the bot is within [member playerKiteDistance] from the player, they will attempt to kite until they bonk into a wall.
	CIRCLES_WHEN_CLOSE, ## When the bot is within [member playerCloseDistance] from the player, they will attempt to kite until they bonk into a wall.
	RANDOMLY_CHANGES_KITING_DIRECTION, ## The bot will switch its kiting direction at a ~30% chance each frame.
	COOLDOWN_COWARD, ## The bot will try to run away from the player if one of its active abilities are on cooldown. It will run until it is outside of [member playerStrafeDistance].
	HEALTH_COWARD, ## The bot will try to run away from the player it is below half health. It will run until it is outside of [member playerKiteDistance].
	SMART_AIMING, ## The position this robot will try to aim at will be the player's position + velocity.
	SMART_CHASING, ## The position this robot will try to chase will be the player's position + velocity.
	STAND_WHEN_CLOSE, ## The robot will stop moving if the player is within [member playerCloseDistance].
	CHARGES_PERIODICALLY, ## The robot will start charging the player on a cycle. The charge will end when the body collides with another [Robot] or the charging cooldown ends. The charge will start if the player is within strafing distance ([member playerStrafeDistance])
	RETREATS_TO_HOME, ## The robot will try to move towards its initial spawning location ([member homePosition]) if it gets beyond [member homeRetreatDistance] away from it.
	POINTER_SWIVEL_ROTATES_TOWARD_FRONT, ## The bot rotates its pointer swivels towards its current movement vector.
	POINTER_SWIVEL_ROTATES_CLOCKWISE, ## The bot rotates its pointer swivels clockwise.
	POINTER_SWIVEL_ROTATES_COUNTERCLOCKWISE, ## The bot rotates its pointer swivels counter-clockwise.
	POINTER_SWIVEL_ROTATES_WITH_KITING_DIRECTION, ## The bot rotates its pointer swivels in a direction tied to its current kiting angle.
	POINTER_SWIVEL_ROTATES_TO_AIM_AT_PLAYER, ## The bot rotates its pointer swivels towards the player. If active with any other pointer swivel related trais, the others will come into effect when the player is out of range.
}
## @experimental: The different movement states the robot can be in.
enum behaviors {
	CHASE, ## The bot is moving towards the player.
	RUN, ## The bot is running away from the player, tactically.
	COWARDICE, ## The bot is running away from the player, like a coward.
	CHARGE, ## The bot is charging towards the player.
	STRAFE, ## The bot is strafing or kiting around the player.
	STAND, ## The bot is being ordered not to move.
	WANDER, ## The bot is not in range and is moving.
	IDLE, ## The bot is not being moved.
	STUN, ## The bot cannot move.
	FREEZE, ## The bot REALLY cannot move.
	RETREAT_TO_HOME, ## The bot is retreating to its home.
}
## @experimental: The priority each state in [enum behaviors] gets.[br]The higher the number, the greater the priority; the highest priority behavior in a frame will be the one chosen.[br]If two states have equal priority, then it will choose randomly between the two. 
const behavioral_priority : Dictionary[behaviors, int]= {
	behaviors.IDLE : 0,
	behaviors.WANDER : 1, 
	behaviors.CHASE : 5,
	behaviors.STRAFE : 10,
	behaviors.STAND : 15,
	behaviors.RUN : 15,
	behaviors.CHARGE : 25,
	behaviors.COWARDICE : 35,
	behaviors.RETREAT_TO_HOME : 40,
	behaviors.STUN : 998,
	behaviors.FREEZE : 999,
}
## @experimental: The AI traits this robot gets, from [enum traits]. If this is empty, the bot will not move.
@export var myTraits : Array[traits] = [traits.CHASES, traits.WANDERS_WHEN_IDLE]
## @experimental: The current behavior the robot is in this frame.
var actionThisFrame : behaviors = behaviors.IDLE;

func has_trait(behavioralTrait : traits) -> bool:
	return behavioralTrait in myTraits;

## Based on the bot's current traits, 
func get_movement_vector(_rotatedByCamera := false):
	var delta = get_physics_process_delta_time();
	
	var currentBehaviors : Array[behaviors] = [behaviors.IDLE];
	inputtingMovementThisFrame = false;
	
	if is_frozen():
		try_add_behavior_state(currentBehaviors, behaviors.FREEZE);
	elif is_asleep():
		try_add_behavior_state(currentBehaviors, behaviors.STUN);
	else:
		## Wander instead of idle.
		if has_trait(traits.WANDERS_WHEN_IDLE):
			try_add_behavior_state(currentBehaviors, behaviors.WANDER)
		
		regenLenToPlayer = true;
		regenLenToHome = true;
		
		## Retreat to home.
		if has_trait(traits.RETREATS_TO_HOME):
			regenLenToHome = true;
			if currentLenToHome > homeRetreatDistance:
				try_add_behavior_state(currentBehaviors, behaviors.RETREAT_TO_HOME);
		
		## Deal with any cowardice.
		if has_trait(traits.COOLDOWN_COWARD):
			if anyActivesOnCooldown:
				try_add_behavior_state(currentBehaviors, behaviors.COWARDICE);
		if has_trait(traits.HEALTH_COWARD):
			if healthCowardTime:
				try_add_behavior_state(currentBehaviors, behaviors.COWARDICE);
		
		## States that can only happen when the player is in chasing distance.
		if player_in_range(playerChaseDistance):
			if has_trait(traits.CHASES):
				try_add_behavior_state(currentBehaviors, behaviors.CHASE);
			
			## Tick charging cooldowns if the player is at all in range.
			if has_trait(traits.CHARGES_PERIODICALLY):
				tick_charging_cooldowns(delta);
			
			if player_in_range(playerKiteDistance):
				if has_trait(traits.KITES):
					try_add_behavior_state(currentBehaviors, behaviors.STRAFE);
			if player_in_range(playerStrafeDistance):
				## Start a charge if you can.
				if has_trait(traits.CHARGES_PERIODICALLY):
					if try_start_charge():
						try_add_behavior_state(currentBehaviors, behaviors.CHARGE);
				if has_trait(traits.STRAFES):
					try_add_behavior_state(currentBehaviors, behaviors.STRAFE);
				if has_trait(traits.PLAYS_KEEPAWAY):
					try_add_behavior_state(currentBehaviors, behaviors.STAND);
			if player_in_range(playerCloseDistance):
				if has_trait(traits.CIRCLES_WHEN_CLOSE):
					try_add_behavior_state(currentBehaviors, behaviors.RUN);
				if has_trait(traits.RUNS_WHEN_CLOSE):
					try_add_behavior_state(currentBehaviors, behaviors.RUN);
				if has_trait(traits.STAND_WHEN_CLOSE):
					try_add_behavior_state(currentBehaviors, behaviors.STRAFE);
	
	actionThisFrame = currentBehaviors.pick_random();
	
	var fireAbilities = false;
	
	match actionThisFrame:
		behaviors.WANDER :
			inputtingMovementThisFrame = true;
			
			movementVector = get_wandering_movement();
			pass;
		behaviors.IDLE :
			movementVector = Vector2.ZERO;
			pass;
		behaviors.CHASE :
			inputtingMovementThisFrame = true;
			
			if has_trait(traits.CHASE_IN_REVERSE):
				if player_is_behind():
					put_in_reverse();
			
			movementVector = get_basic_player_chase_vector();
			fireAbilities = true;
			
			if has_trait(traits.CHASE_AVOIDS_WALLS):
				movementVector = movementVector.rotated(playerWallDodgeAngle)
			
			pass;
		behaviors.STRAFE :
			inputtingMovementThisFrame = true;
			
			if has_trait(traits.CHASE_IN_REVERSE):
				if player_is_behind():
					put_in_reverse();
			
			movementVector = get_basic_player_chase_vector();
			
			movementVector = movementVector.rotated(deg_to_rad(kitingDir));
			
			fireAbilities = true;
			pass;
		behaviors.STAND :
			movementVector = Vector2.ZERO;
			fireAbilities = true;
			pass;
		behaviors.RUN :
			inputtingMovementThisFrame = true;
			
			if has_trait(traits.CHASE_IN_REVERSE):
				if player_is_behind():
					put_in_reverse();
			
			movementVector = get_basic_player_chase_vector(true, false);
			
			fireAbilities = true;
			pass;
		behaviors.CHARGE :
			inputtingMovementThisFrame = true;
			
			movementVector = chargeVector;
			
			fireAbilities = true;
			pass;
		behaviors.COWARDICE :
			inputtingMovementThisFrame = true;
			
			movementVector = get_basic_player_chase_vector(true);
			
			fireAbilities = true;
			pass;
		behaviors.RETREAT_TO_HOME :
			inputtingMovementThisFrame = true;
			
			movementVector = get_home_retreat_vector();
			
			fireAbilities = true;
			pass;
		behaviors.STUN :
			movementVector = Vector2.ZERO;
			pass;
		behaviors.FREEZE :
			movementVector = Vector2.ZERO;
			pass;
		_ :
			movementVector = Vector2.ZERO;
			pass;
	
	if fireAbilities:
		## Fire active abilities after all this.
		try_fire_actives();
	
	if is_inputting_movement():
		movementVectorRotation = movementVector.angle();
	
	if has_trait(traits.POINTER_SWIVEL_ROTATES_CLOCKWISE) or has_trait(traits.POINTER_SWIVEL_ROTATES_COUNTERCLOCKWISE) or has_trait(traits.POINTER_SWIVEL_ROTATES_WITH_KITING_DIRECTION):
		var angleToRot = pointerTargetAngleOffsetStorage;
		
		if targetPointerWasSetManually:
			pointerTargetAngleOffsetStorage = 0;
			pointerTarget = Vector3(0.,0.,1.);
			targetPointerWasSetManually = false;
		
		if has_trait(traits.POINTER_SWIVEL_ROTATES_CLOCKWISE):
			angleToRot += deg_to_rad(5. * delta)
		if has_trait(traits.POINTER_SWIVEL_ROTATES_COUNTERCLOCKWISE):
			angleToRot += deg_to_rad(-5. * delta)
		if has_trait(traits.POINTER_SWIVEL_ROTATES_WITH_KITING_DIRECTION):
			angleToRot += deg_to_rad(5. * delta)
			if kitingDir < 0:
				angleToRot *= -1;
		
		pointerTargetAngleOffsetStorage = angleToRot;
		
		
		pointerTarget = pointerTarget.rotated(Vector3.UP, angleToRot)
		
		#print(pointerTarget)
	
	## Moving the target pointer.
	if is_inputting_movement():
		if has_trait(traits.POINTER_SWIVEL_ROTATES_TOWARD_FRONT):
			set_pointer_to_look_at_movement_vector(movementVector);
			targetPointerWasSetManually = true;
	elif player_in_range(playerChaseDistance):
		if has_trait(traits.POINTER_SWIVEL_ROTATES_TO_AIM_AT_PLAYER):
			set_pointer_to_look_at_player();
			targetPointerWasSetManually = true;
	
	return movementVector.normalized();

func try_add_behavior_state(currentBehaviors:Array[behaviors], behavioralState : behaviors):
	if currentBehaviors.has(behavioralState):
		return currentBehaviors;
	if currentBehaviors.is_empty():
		currentBehaviors.append(behavioralState);
		return currentBehaviors;
	var currentPriority = behavioral_priority[currentBehaviors.front()]
	var newPriority = behavioral_priority[behavioralState]
	if newPriority < currentPriority:
		return currentBehaviors;
	elif newPriority == currentPriority:
		currentBehaviors.append(behavioralState);
		return currentBehaviors;
	elif newPriority > currentPriority:
		currentBehaviors.clear();
		currentBehaviors.append(behavioralState);
		return currentBehaviors;


var targetPointerWasSetManually := true;

## @experimental: The requirements an [AbilityManager] needs to meet for it to be fired this frame.
enum active_ability_fire_requirements {
	BASIC, ## The ability will attempt to fire whenever it is not on cooldown.
	PLAYER_IN_CHASE_RANGE, ## The player must be inside [member playerChaseDistance].
	PLAYER_IN_KITING_RANGE, ## The player must be inside [member playerKiteDistance].
	PLAYER_IN_STRAFING_RANGE, ## The player must be inside [member playerStrafeDistance].
	PLAYER_IN_CLOSE_RANGE, ## The player must be inside [member playerCloseDistance].
	PLAYER_OUTSIDE_CHASE_RANGE, ## The player must be outside [member playerChaseDistance].
	PLAYER_IN_PROJECTILE_RANGE, ## The [Piece] this is from must be a [Piece_Projectile], and must return true with [method Piece_Projectile.player_in_range]. If it is not a [Piece_Projectile], this acts like [enum active_ability_fire_requirements.BASIC].
	WHEN_CHARGING, ## Only fires when the enemy is charging (as per [member isCharging]). 
	
	PROJECTILE_NEARBY, ## The ability will fire if a [Bullet] is nearby.
	PLAYER_OR_PROJECTILE_NEARBY, ## The ability will fire if the player is inside [member playerCloseDistance] or there is a [Bullet] nearby.
}

var anyActivesOnCooldown := false;
func try_fire_actives():
	if ! is_conscious(): return false;
	
	anyActivesOnCooldown = false;
	
	for abilityIndex in active_abilities:
		var ability = active_abilities[abilityIndex]
		if ability != null:
			if ability is AbilityData:
				if ability.is_on_cooldown():
					anyActivesOnCooldown = true;
				else:
					var host = ability.assignedPieceOrPart;
					var canUse = false;
					var manager = ability.manager;
					if host is Piece:
						canUse = host.can_use_ability(manager);
					if host is Part:
						canUse = host.can_use_ability(manager);
					
					if canUse:
						var fireMe = false;
						match manager.aiFireRequirement:
							active_ability_fire_requirements.BASIC:
								fireMe = true;
							active_ability_fire_requirements.PLAYER_IN_CHASE_RANGE:
								fireMe = player_in_range(playerChaseDistance);
							active_ability_fire_requirements.PLAYER_IN_KITING_RANGE:
								fireMe = player_in_range(playerKiteDistance);
							active_ability_fire_requirements.PLAYER_IN_STRAFING_RANGE:
								fireMe = player_in_range(playerStrafeDistance);
							active_ability_fire_requirements.PLAYER_IN_CLOSE_RANGE:
								fireMe = player_in_range(playerCloseDistance);
							active_ability_fire_requirements.PLAYER_OUTSIDE_CHASE_RANGE:
								fireMe = !player_in_range(playerChaseDistance);
							active_ability_fire_requirements.PLAYER_IN_PROJECTILE_RANGE:
								if host is Piece_Projectile:
									fireMe = host.player_in_range();
								else:
									fireMe = true;
							active_ability_fire_requirements.WHEN_CHARGING:
								fireMe = isCharging;
							_:
								fireMe = true;
						
						if fireMe:
							fire_active(abilityIndex);

######## STARTUP STUFF

func _ready():
	super();
	

func stat_registry():
	super();

func die():
	if ! aliveLastFrame: return false;
	if lastAttacker is Robot_Player:
		ScrapManager.add_scrap(get_salvage_price(), "Kill");
	super();

func live():
	super();
	homePosition = get_global_body_position();


func get_salvage_price():
	var priceTally = salvagePrice;
	for piece in allPieces:
		if randf_range(0.0, 1.0) <= salvagePricePieceChange:
			priceTally += piece.get_salvage_price_piece_only(ScrapManager.get_discount_for_type(ScrapManager.priceTypes.SALVAGE));
	return ceili(priceTally * salvagePriceMultiplier);

func assign_references(forceTemp := false):
	if !forceTemp and referencesAssigned: return;
	super(forceTemp);
	if !is_instance_valid(frontRay):
		var newRay = RayCast3D.new();
		newRay.set_collision_mask_value(11, true);
		add_child(newRay);
		frontRay = newRay;
		frontRay.enabled = true;
		frontRay.add_exception(body);
		frontRay.set_debug_shape_thickness(5)
		frontRay.set_debug_shape_custom_color(Color(0,1,0))
	if !is_instance_valid(playerRay):
		var newRay = RayCast3D.new();
		newRay.set_collision_mask_value(11, true);
		add_child(newRay);
		playerRay = newRay;
		playerRay.enabled = true;
		playerRay.add_exception(body);
		playerRay.set_debug_shape_thickness(5)
		playerRay.set_debug_shape_custom_color(Color(1,0,1))
	if !is_instance_valid(directionRay):
		var newRay = RayCast3D.new();
		newRay.set_collision_mask_value(11, true);
		add_child(newRay);
		directionRay = newRay;
		directionRay.enabled = true;
		directionRay.add_exception(body);
		directionRay.set_debug_shape_thickness(5)
		directionRay.set_debug_shape_custom_color(Color(1,0,1))

func get_front_direction_vector3(inVector := frontDirection):
	return Vector3(inVector.x, 0, inVector.y);

func phys_process_pre(delta):
	#return;
	super(delta);
	## Set the calculated 'front' direction this frame.
	frontDirection = Vector2.from_angle(body.global_rotation.y - PI/2)
	frontDirection.y *= -1;

var randomizedVector : Vector2;
var randomizedVectorTimer := 0.0;
var randomizedFactor := 1.0; ## 1.0 or -1.0 based on the randomizedVectorTimer loop.
func phys_process_timers(delta):
	#return;
	super(delta);
	if not is_frozen():
		## Subtract delta from rayCheckTimer.
		## If the bot is asleep, set the timer to that instead.
		rayCheckTimer = max(rayCheckTimer - delta, sleepTimer, 0);
		
		if rayCheckTimer <= 0:
			frontRay.global_position = body.global_position
			#frontRay.global_position += Vector3(0,4,0);
			frontRay.enabled = true;
			rayCheckTimer = rayCheckFrequency;
			#print(rayCheckFrequency)
			phys_process_detection(delta)
		else:
			#frontRay.enabled = false;
			pass;
		
		
		##For wandering movement.
		randomizedVectorTimer -= delta;
		
		if randomizedVectorTimer < 0:
			randomizedVectorTimer += randf_range(0.5,2.0);
			if randi_range(0,10) > 3:
				randomizedVector = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized();
			else:
				randomizedVector = Vector2.ZERO;
			if randi_range(1,10) > 5:
				randomizedFactor = 1.0;
			else:
				randomizedFactor = -1.0;
	
			## Switch the kiting direction.
			if has_trait(traits.RANDOMLY_CHANGES_KITING_DIRECTION):
				if randf() < 0.3:
					reverse_kiting();

func get_wandering_movement() -> Vector2:
	return randomizedVector;

@export var rayCheckFrequency := 0.10; ## The amount of time between [method phys_process_detection] updates.
var rayCheckTimer := 0.15; ## The amount of time before the next [method phys_process_detection] call.[br]If [member sleepTimer] is greater than this value, it gets set to it.
## Runs after [method phys_process_timers] if [method is_frozen] does not return true, and when rayCheckTimer < 0.
func phys_process_detection(delta):
	update_if_ray_colliding_with_player(0.0,true);
	update_front_ray_result();
	playerWallDodgeAngle = rotation_to_dodge_walls_and_move_towards_player();

func phys_process_motion(delta):
	super(delta);

var playerInRaySight := false; ## Updated in [method update_if_ray_colliding_with_player]. True if [member playerRay] was colliding with the player that frame.
var wallInWayOfPlayer := false; ## Updated in [method update_if_ray_colliding_with_player]. True if [member playerRay] was colliding with a wall that frame.
var enemyInWayOfPlayer := false; ## Updated in [method update_if_ray_colliding_with_player]. True if [member playerRay] was colliding with a [Robot] that wasn't a [Robot_Player] that frame.
var playerInRaySightOG := false; ## Updated in [method update_if_ray_colliding_with_player] if [param update_if_ray_colliding_with_player.isOriginal] == true. True if [member playerRay] was colliding with the player that frame. Serves to show what the value was at the start of the frame before doing any dodging or whatever.
var wallInWayOfPlayerOG := false; ## Updated in [method update_if_ray_colliding_with_player] if [param update_if_ray_colliding_with_player.isOriginal] == true. True if [member playerRay] was colliding with a wall that frame. Serves to show what the value was at the start of the frame before doing any dodging or whatever.
var enemyInWayOfPlayerOG := false; ## Updated in [method update_if_ray_colliding_with_player] if [param update_if_ray_colliding_with_player.isOriginal] == true. True if [member playerRay] was colliding with a [Robot] that wasn't a [Robot_Player] that frame. Serves to show what the value was at the start of the frame before doing any dodging or whatever.
## Sets [member playerRay] directly forward and updates stuff based on what it hits. 
func update_if_ray_colliding_with_player(rotationalOffset := 0.0, isOriginal := false) -> bool:
	wallInWayOfPlayer = false;
	playerInRaySight = false;
	enemyInWayOfPlayer = false;
	if isOriginal:
		wallInWayOfPlayerOG = false;
		playerInRaySightOG = false;
		enemyInWayOfPlayerOG = false;
	if is_instance_valid(playerRay) and player_in_range():
		playerRay.global_position = body.global_position;
		playerRay.target_position = GameState.get_player_pos_offset(body.global_position);
		if rotationalOffset != 0.0:
			playerRay.target_position = playerRay.target_position.rotated(Vector3(0,1,0),rotationalOffset);
		
		playerRay.force_raycast_update();
		var col = null;
		if playerRay.is_colliding():
			col = playerRay.get_collider();
		
		match parse_ray_collider_result(col):
			rayColTypes.NONE:
				playerRay.set_debug_shape_custom_color(Color(0.8,0.8,0.8));
				pass;
			rayColTypes.PLAYER:
				playerRay.set_debug_shape_custom_color(Color(0,1,0));
				if isOriginal:
					playerInRaySightOG = true;
				playerInRaySight = true;
				pass;
			rayColTypes.ENEMY:
				playerRay.set_debug_shape_custom_color(Color(0,0,1));
				if isOriginal:
					enemyInWayOfPlayerOG = true;
				enemyInWayOfPlayer = true;
				pass;
			rayColTypes.OBSTACLE:
				playerRay.set_debug_shape_custom_color(Color(1,1,0));
				if isOriginal:
					wallInWayOfPlayerOG = true;
				wallInWayOfPlayer = true;
				pass;
			rayColTypes.WALL:
				playerRay.set_debug_shape_custom_color(Color(0.5,0.5,0));
				if isOriginal:
					wallInWayOfPlayerOG = true;
				wallInWayOfPlayer = true;
				pass;
			rayColTypes.FLOOR:
				playerRay.set_debug_shape_custom_color(Color(0.5,0.5,0));
				if isOriginal:
					wallInWayOfPlayerOG = true;
				wallInWayOfPlayer = true;
				pass;
		
		return playerInRaySight;
	
	playerRay.set_debug_shape_custom_color(Color(0.0,0.0,0.0));
	playerInRaySight = false;
	if isOriginal:
		playerInRaySightOG = true;
	return playerInRaySight;

## Sets [member frontRay] directly forward and updates stuff based on what it hits. 
func update_front_ray_result(positionOffset := Vector3.ZERO):
	if is_instance_valid(frontRay):
		var dist = frontRayDistance;
		if is_in_reverse():
			dist *= -1;
		frontRay.position += positionOffset;
		frontRay.target_position = get_front_direction_vector3() * dist;
		#prints(frontRay.target_position, get_front_direction_vector3() * dist, dist);
		frontRay.force_raycast_update();
		if frontRay.is_colliding():
			frontRayCollision = frontRay.get_collider();
			frontRayNormal = frontRay.get_collision_normal();
			frontRayDistanceToPoint = frontRay.get_collision_point().distance_to(frontRay.global_position);
		else:
			frontRayCollision = null;
			frontRayNormal = null;
			frontRayDistanceToPoint = -1;
		
		frontRayColType = parse_ray_collider_result(frontRayCollision);

func get_angle_to_player_from_front(inDegrees := false) -> float:
	var playerOffset = GameState.get_player_pos_offset(body.global_position);
	var ply2 = Vector2(playerOffset.x, playerOffset.z);
	var glb2 = frontDirection;
	var plyA = ply2.angle();
	var glbA = glb2.angle();
	
	var angle = Utils.angle_difference_relative(plyA, glbA);
	
	if inDegrees:
		return rad_to_deg(angle);
	return angle;

## Returns true when the player's angle from [member frontDirection] is > 90 degrees (PI/2).
func player_is_behind():
	return get_angle_to_player_from_front(false) > PI/2;

func get_basic_player_chase_vector(reverse := false, addVelocity := has_trait(traits.SMART_CHASING)):
	var plyOffset = GameState.get_player_pos_offset(body.global_position, addVelocity);
	#var length = GameState.get_len_to_player(body.global_position);
	var vectorOut = Vector2(-plyOffset.x, -plyOffset.z);
	if reverse:
		vectorOut = vectorOut.rotated(PI);
	return vectorOut;

func get_home_retreat_vector():
	var homeOffset = homePosition - body.global_position;
	var vectorOut = Vector2(-homeOffset.x, -homeOffset.z);
	return vectorOut;

func set_pointer_to_look_at_player(angleOffset := 0.0, addVelocity := has_trait(traits.SMART_AIMING)):
	var plyOffset = GameState.get_player_pos_offset(body.global_position, addVelocity);
	pointerTarget = plyOffset;
	pointerTarget.z *= -1;
	pointerTarget = pointerTarget.rotated(Vector3.UP, -PI/2)
	pointerTarget = pointerTarget.rotated(Vector3.UP, angleOffset)
	#print(pointerTarget);

func set_pointer_to_look_at_movement_vector(vectorIn := movementVector):
	var vector = vectorIn;
	pointerTarget = get_front_direction_vector3(vector);
	pointerTarget.z *= -1;
	pointerTarget = pointerTarget.rotated(Vector3.UP, -PI/2)
	#print(pointerTarget);
## Rotates the [param invector] in steps of [param degreeStep] until its absolute value reaches [param maxRotation] in either direction, or [method update_if_ray_colliding_with_player] returns a result that has the player not obscured by a wall ( [code]playerInRaySight == true[/code] ).[br][br]
## [color=pink][i]This is probably pretty pricey since it deals with raycasts.
func rotate_movement_vector_to_dodge_walls_and_move_towards_player(invector : Vector2 = get_basic_player_chase_vector(), maxRotation := PI * 2/3, degreeStep := 20.) -> Vector2:
	return invector.rotated(rotation_to_dodge_walls_and_move_towards_player(invector, maxRotation, degreeStep));

func rotation_to_dodge_walls_and_move_towards_player(invector : Vector2 = get_basic_player_chase_vector(), maxRotation := PI * 1/3, degreeStep := 20.) -> float:
	var outvector = invector;
	if !(wallInWayOfPlayer or enemyInWayOfPlayer): 
		if playerInRaySight: return 0.0; ## If the player's in sight, ignore this function.
	
	var amtOfRotation = 0.;
	var angleToPlayer = get_angle_to_player_from_front();
	var factor = 1;
	
	## Determine factor based on which angle to them would be closest.
	if angleToPlayer < 0:
		factor = -1;
	## Loop over the rotation until it's reached its maximum.
	while (
		abs(amtOfRotation) < abs(maxRotation)
		and 
		(wallInWayOfPlayer or enemyInWayOfPlayer)
	):
		amtOfRotation += deg_to_rad(degreeStep * factor);
		
		## If this first check passed, we're done here.
		if update_if_ray_colliding_with_player(amtOfRotation):
			return amtOfRotation;
	
	## If the player ray still isn't in sight, check the other way.
	## Save the old result.
	var firstAmt = amtOfRotation;
	## Flip the factor, reset the amount, and try the while again.
	factor *= -1;
	amtOfRotation = 0.0;
	
	## Check the other way.
	while (
		abs(amtOfRotation) < abs(maxRotation)
		and 
		(wallInWayOfPlayer or enemyInWayOfPlayer)
		and 
		abs(amtOfRotation) < abs(firstAmt) ## Don't keep looping if the next loop would bring us over the original check.
	):
		amtOfRotation += deg_to_rad(degreeStep * factor);
		
		## If this second check passed, then we're done here.
		if update_if_ray_colliding_with_player(amtOfRotation):
			return amtOfRotation;
	
	var secondAmt = amtOfRotation;
	
	#outvector = outvector.rotated(amtOfRotation);
	## If the new amt is less than the first, rotate using it.
	if abs(secondAmt) < abs(firstAmt):
		return secondAmt;
	## If the first amt is less than the new, rotate using it.
	elif abs(secondAmt) > abs(firstAmt):
		return firstAmt;
	
	## If neither of the checks passed, and both angles are equal, then it chooses either the second result or the input, at random (50%).
	## The 2nd result is chosen because it will likely move the bot away from the player, and subsequently any walls in the way.
	if randomizedFactor > 0:
		return secondAmt;
	else: 
		return firstAmt;

## The current length to the player.
var currentLenToPlayer : float = -1:
	get:
		if regenLenToPlayer or currentLenToPlayer < 0:
			regenLenToPlayer = false;
			currentLenToPlayer = GameState.get_len_to_player(body.global_position);
		return currentLenToPlayer;
var regenLenToPlayer := true;
func player_in_range(distanceOverride := playerChaseDistance):
	return currentLenToPlayer <= distanceOverride;

enum rayColTypes {
	FLOOR,
	WALL,
	OBSTACLE,
	NONE,
	PLAYER,
	ENEMY
}
func parse_ray_collider_result(collision : CollisionObject3D = frontRayCollision) -> rayColTypes:
	if !is_instance_valid(collision):
		return rayColTypes.NONE;
	if collision is RobotBody:
		var bot = collision.get_robot();
		if bot is Robot_Player:
			return rayColTypes.PLAYER;
		return rayColTypes.ENEMY;
	if collision.is_in_group("Obstacle"):
		return rayColTypes.OBSTACLE;
	if collision.is_in_group("WorldWall"):
		return rayColTypes.WALL;
	if collision.is_in_group("World"):
		return rayColTypes.FLOOR;
	return rayColTypes.NONE;
