extends Piece_Swivel

class_name Piece_SwivelManual

func ability_registry():
	register_active_ability("Rotate Clockwise", "Rotates this swivel clockwise.", func(): rotate_clockwise(), [])
	register_active_ability("Rotate Counter-Clockwise", "Rotates this swivel clockwise.", func(): rotate_counter_clockwise(), [])

func rotate_clockwise():
	var physDelta = get_physics_process_delta_time();
	targetRotation += 10 * physDelta;
func rotate_counter_clockwise():
	var physDelta = get_physics_process_delta_time();
	targetRotation += -10 * physDelta;
