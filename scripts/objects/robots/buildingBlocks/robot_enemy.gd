extends Robot

class_name Robot_Enemy
## Holds some helper functions for enemy [Robot]s that would be useless for a [Robot_Player].

var frontRay : RayCast3D;
var playerRay : RayCast3D;
var directionRay : RayCast3D;

var frontRayCollision = null;## Collider gathered in [method update_front_ray_result]. Set to null if invalid.
var frontRayColType : rayColTypes = rayColTypes.NONE;## Collider type in [enum rayColTypes] gathered in [method update_front_ray_result] based on [member frontRayCollision]. 
var frontRayNormal = Vector3(0,0,0).normalized();## Collision normal gathered in [method update_front_ray_result]. Set to null if invalid.
var frontDirection = Vector2(0,1).normalized();## The front of the robot, determined by body rotation.
@export var frontRayDistance = 5.0; ## How long the front collision ray should be.
var frontRayDistanceToPoint = 0.0; ## Calculated in [method update_front_ray_result]. how far away from colliding the bot is directly in front of it.
@export var chasesPlayerInReverse := false; ##@experimental: When set to true, this bot will go into reverse when the player is behind them.
@export var playerChaseDistance := 30.;

func _ready():
	super();

func grab_references():
	super();
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

func get_front_direction_vector3():
	return Vector3(frontDirection.x, 0, frontDirection.y);

func phys_process_pre(delta):
	super(delta);
	## Set the calculated 'front' direction this frame.
	frontDirection = Vector2.from_angle(body.global_rotation.y - PI/2)
	frontDirection.y *= -1;

func phys_process_timers(delta):
	super(delta);
	if not is_frozen():
		## Subtract delta from rayCheckTimer.
		## If the bot is asleep, set the timer to that instead.
		rayCheckTimer = max(rayCheckTimer - delta, sleepTimer);
		
		if rayCheckTimer < 0:
			frontRay.global_position = body.global_position
			#frontRay.global_position += Vector3(0,4,0);
			frontRay.enabled = true;
			rayCheckTimer = rayCheckFrequency;
			#print(rayCheckFrequency)
			phys_process_detection(delta)
		else:
			#frontRay.enabled = false;
			pass;

@export var rayCheckFrequency := 0.10; ## The amount of time between [method phys_process_detection] updates.
var rayCheckTimer := 0.15; ## The amount of time before the next [method phys_process_detection] call.[br]If [member sleepTimer] is greater than this value, it gets set to it.
## Runs after [method phys_process_timers] if [method is_frozen] does not return true, and when rayCheckTimer < 0.
func phys_process_detection(delta):
	update_if_ray_colliding_with_player();
	update_front_ray_result();

func phys_process_motion(delta):
	if not is_frozen():
		if chasesPlayerInReverse:
			if player_is_behind():
				put_in_reverse();
	super(delta);

var playerInRaySight := false; ## Updated in [method update_if_ray_colliding_with_player]. True if [member playerRay] was colliding with the player that frame.
var wallInWayOfPlayer := false; ## Updated in [method update_if_ray_colliding_with_player]. True if [member playerRay] was colliding with a wall that frame.
## Sets [member playerRay] directly forward and updates stuff based on what it hits. 
func update_if_ray_colliding_with_player(rotationalOffset := 0.0) -> bool:
	if is_instance_valid(playerRay) and player_in_chase_range():
		playerRay.global_position = body.global_position;
		playerRay.target_position = GameState.get_player_pos_offset(body.global_position);
		if rotationalOffset != 0.0:
			playerRay.target_position = playerRay.target_position.rotated(Vector3(0,1,0),rotationalOffset);
		
		playerRay.force_raycast_update();
		wallInWayOfPlayer = false;
		playerInRaySight = false;
		if playerRay.is_colliding():
			var col = playerRay.get_collider();
			
			if col is RobotBody:
				var bot = col.get_robot();
				if bot is Robot_Player:
					playerInRaySight = true;
			
			wallInWayOfPlayer = col.is_in_group("World");
		
		if playerInRaySight:
			playerRay.set_debug_shape_custom_color(Color(0,1,0));
		else:
			if wallInWayOfPlayer:
				playerRay.set_debug_shape_custom_color(Color(1,1,0));
			else:
				playerRay.set_debug_shape_custom_color(Color(0.8,0.8,0.8));
		
		return playerInRaySight;
	
	frontRay.set_debug_shape_custom_color(Color(0.0,0.0,0.0));
	grab_references();
	playerInRaySight = false;
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

## Rotates the [param invector] in steps of [param degreeStep] until its absolute value reaches [param maxRotation] in either direction, or [method update_if_ray_colliding_with_player] returns a result that has the player not obscured by a wall ( [code]playerInRaySight == true[/code] ).[br][br]
## [color=pink][i]This is probably pretty pricey since it deals with raycasts.
func rotate_movement_vector_to_dodge_walls_and_move_towards_player(invector : Vector2, maxRotation := PI/2, degreeStep := 20.) -> Vector2:
	if playerInRaySight: return invector; ## If the player's in sight, ignore this function.
	
	var amtOfRotation = 0.;
	var angleToPlayer = get_angle_to_player_from_front();
	var factor = 1;
	if angleToPlayer < 0:
		factor = -1;
	## Loop over the rotation until it's reached its maximum.
	while (
		abs(amtOfRotation) < abs(maxRotation)
		and 
		wallInWayOfPlayer == true
	):
		amtOfRotation += deg_to_rad(degreeStep * factor);
		
		## If this first check passed, we're done here.
		if update_if_ray_colliding_with_player(amtOfRotation):
			invector = invector.rotated(amtOfRotation);
			return invector;
	
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
		wallInWayOfPlayer == true
		and 
		abs(amtOfRotation) < abs(firstAmt) ## Don't keep looping if the next loop would bring us over the original check.
	):
		amtOfRotation += deg_to_rad(degreeStep * factor);
		
		## If this second check passed, then we're done here.
		if update_if_ray_colliding_with_player(amtOfRotation):
			invector = invector.rotated(amtOfRotation);
			return invector;
	
	var secondAmt = amtOfRotation;
	
	#invector = invector.rotated(amtOfRotation);
	## If the new amt is less than the first, rotate using it.
	if abs(secondAmt) < abs(firstAmt):
		invector = invector.rotated(secondAmt);
		return invector;
	## If the first amt is less than the new, rotate using it.
	elif abs(secondAmt) > abs(firstAmt):
		invector = invector.rotated(firstAmt);
		return invector;
	## If neither of the checks passed, and both angles are equal, then it chooses either the second result or the input, at random (50%).
	## The 2nd result is chosen because it will likely move the bot away from the player, and subsequently any walls in the way.
	if randf() >= 0.5:
		invector = invector.rotated(secondAmt);
		return invector;
	return invector;

func player_in_chase_range(distanceOverride := playerChaseDistance):
	return GameState.get_len_to_player(body.global_position) <= playerChaseDistance;

enum rayColTypes {
	FLOOR,
	WALL,
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
			rayColTypes.PLAYER;
		return rayColTypes.ENEMY;
	if collision.is_in_group("WorldWall"):
		return rayColTypes.WALL;
	if collision.is_in_group("World"):
		return rayColTypes.FLOOR;
	return rayColTypes.NONE;
