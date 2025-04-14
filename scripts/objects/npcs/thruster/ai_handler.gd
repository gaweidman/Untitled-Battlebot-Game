extends Node3D

func ready():
	pass
	
func get_movement_vector():
	var ply = GameState.get_player();
	
	if ply:
		var posDiff = ply.get_node("Body").get_global_position() - get_parent().get_node("Body").get_global_position();
		posDiff = posDiff.normalized();
		
		return 120000 * Vector2(posDiff.x, posDiff.z);
