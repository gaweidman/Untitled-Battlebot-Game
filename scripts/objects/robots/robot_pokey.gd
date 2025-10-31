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
	if player_in_range():
		randomizedVector = Vector2.ZERO;
		randomizedVectorTimer = 3.0;
		
		if rocketAttemptTimer > 1.5:
			if player_in_range(7): 
				vectorOut = get_basic_player_chase_vector(true);
				
				set_pointer_to_look_at_player(PI);
				
				fire_active(2);
				
			elif player_in_range(9): 
				vectorOut = get_basic_player_chase_vector(false);
				speedMult = 0.5;
				
				set_pointer_to_look_at_player(PI);
				
			else:
				vectorOut = rotate_movement_vector_to_dodge_walls_and_move_towards_player();
				set_pointer_to_look_at_player(0);
		else:
			vectorOut = rotate_movement_vector_to_dodge_walls_and_move_towards_player();
			set_pointer_to_look_at_player(0);
		
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
	
	rocketAttemptTimer = max(rocketAttemptTimer - delta, 0)

var rocketAttemptTimer := 0.0;
func phys_process_combat(delta):
	super(delta);
	if is_conscious():
		
		if player_in_range(10) and rocketAttemptTimer <= 0 and !wallInWayOfPlayer:
			if fire_active(2):
			#rocketAttemptTimer += 6;
				print("BLASTOFF")
				rocketAttemptTimer = randf_range(3, 7);
			pass;
