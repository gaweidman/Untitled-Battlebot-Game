extends Node3D

class_name AIHandlerBase

func ready():
	pass
	
func get_movement_vector():
	var ply = GameState.get_player();
	
	if ply:
		var posDiff = GameState.get_player_pos_offset(get_parent().get_node("Body").get_global_position()).normalized();
		
		return Vector2(posDiff.x, posDiff.z);
