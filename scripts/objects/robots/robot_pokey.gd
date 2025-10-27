extends Robot_Enemy

class_name Robot_Pokey

##This is empty here, but the Player and Enemy varieties of this should have things for gathering input / getting player location respectively.
func get_movement_vector(rotatedByCamera : bool = false) -> Vector2:
	var vectorOut = Vector2.ZERO;
	var speedMult = 1.;
	inputtingMovementThisFrame = true;
	#if frontRayCollision != null:
		#speedMult = (1. - (frontRayDistance / 5.)) * 0.75;
		#vectorOut = - randomizedVector;
		#print(vectorOut, speedMult)
	#else:
	if player_in_chase_range():
		randomizedVector = Vector2.ZERO;
		randomizedVectorTimer = 3.0;
		vectorOut = rotate_movement_vector_to_dodge_walls_and_move_towards_player();
		match frontRayColType:
			rayColTypes.WALL:
				vectorOut *= -1;
	else:
		speedMult = 0.75;
		vectorOut = randomizedVector;
	
	directionRay.global_position = body.global_position;
	directionRay.target_position = get_front_direction_vector3(-vectorOut) * speedMult;
	
	return vectorOut.normalized() * speedMult;

var randomizedVector : Vector2;
var randomizedVectorTimer := 0.0;
func phys_process_timers(delta):
	super(delta);
	
	randomizedVectorTimer -= delta;
	
	if randomizedVectorTimer < 0:
		randomizedVectorTimer += randf_range(0.5,2.0);
		if randi_range(0,10) > 3:
			randomizedVector = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized();
		else:
			randomizedVector = Vector2.ZERO;
