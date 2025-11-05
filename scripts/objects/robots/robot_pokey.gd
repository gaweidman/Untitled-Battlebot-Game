extends Robot_Enemy

class_name Robot_Pokey

##This is empty here, but the Player and Enemy varieties of this should have things for gathering input / getting player location respectively.
func get_movement_vector(_rotatedByCamera : bool = false) -> Vector2:
	var vectorOut = Vector2.ZERO;
	var speedMult = 1.;
	inputtingMovementThisFrame = true;
	#if frontRayCollision != null:
		#speedMult = (1. - (frontRayDistance / 5.)) * 0.75;
		#vectorOut = - randomizedVector;
		#print(vectorOut, speedMult)
	#else:
	#print(wallInWayOfPlayerOG);
	if player_in_range():
		randomizedVector = Vector2.ZERO;
		randomizedVectorTimer = 3.0;
		
		##Movement vector
		if rocketAttemptTimer > 1.5:
			if player_in_range(7): 
				vectorOut = get_basic_player_chase_vector(true);
			elif player_in_range(9): 
				vectorOut = get_basic_player_chase_vector(false);
				speedMult = 0.5;
			else:
				vectorOut = get_basic_player_chase_vector(false);
		else:
			vectorOut = get_basic_player_chase_vector(false);
		
		## Rocket point
		if rocketPostAttemptTimer == 0.0:
			if wallInWayOfPlayerOG:
				if get_angle_to_player_from_front() > 0:
					set_pointer_to_look_at_player(PI/-2);
				else:
					set_pointer_to_look_at_player(PI/2);
			else:
				set_pointer_to_look_at_player(0);
		
		match frontRayColType:
			rayColTypes.WALL:
				vectorOut *= -1;
	else:
		speedMult = 0.75;
		vectorOut = get_wandering_movement();
	
	vectorOut = vectorOut.rotated(playerWallDodgeAngle);
	
	directionRay.global_position = body.global_position;
	directionRay.global_position += Vector3.UP;
	directionRay.target_position = get_front_direction_vector3(-vectorOut) * speedMult;
	
	return vectorOut.normalized() * speedMult;

func phys_process_timers(delta):
	super(delta);
	
	rocketAttemptTimer = max(rocketAttemptTimer - delta, 0)
	rocketPostAttemptTimer = max(rocketPostAttemptTimer - delta, 0)

var rocketAttemptTimer := 0.0;
var rocketPostAttemptTimer := 0.0;
func phys_process_combat(delta):
	super(delta);
	if is_conscious():
		
		if player_in_range(10) and rocketAttemptTimer <= 0 and !wallInWayOfPlayer:
			if fire_active(2):
			#rocketAttemptTimer += 6;
				#print("BLASTOFF")
				rocketAttemptTimer = randf_range(3, 7);
				rocketPostAttemptTimer = 1.0;
			pass;
