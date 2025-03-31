extends Node3D

func ready():
	pass
	
func get_movement_vector():
	var ply = GameState.get_player();
	
	if ply:
		var posDiff = get_parent().get_node("Body").get_global_position() - ply.get_node("Body").get_global_position()
		posDiff = posDiff.normalized();
		
		return Vector2(posDiff.x, posDiff.z)
