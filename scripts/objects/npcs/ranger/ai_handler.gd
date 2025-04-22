extends AIHandlerBase

@export var CHARGEDIST := 22.0;
@export var RUNDIST := 6.0;
#var REGULARSPEED := 5000.0;
@export var REGULARSPEED := 0.0;
@export var RUNSPEED := 4000.0;

func ready():
	pass

func get_movement_vector():
	var ply = GameState.get_player();
	
	if ply:
		var posDiff = GameState.get_player_pos_offset(get_parent().body.global_position);
		
		if posDiff.length() > CHARGEDIST:
			var normalized = posDiff.normalized();
			return Vector2(normalized.x, normalized.z) * REGULARSPEED;
		elif posDiff.length() < RUNDIST:
			var normalized = posDiff.normalized();
			return Vector2(normalized.x, normalized.z) * -RUNSPEED;
		
	return Vector2.ZERO;
