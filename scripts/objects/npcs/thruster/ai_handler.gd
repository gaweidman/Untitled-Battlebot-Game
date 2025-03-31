extends Node3D
var thisNpc;

func ready():
	thisNpc = self
	print(thisNpc)
	
func get_movement_vector():
	#print("wE ARE RUNNING LOL ", thisNpc, " ", self);
	var ply = GameState.get_player();
	
	if ply:
		#var posDiff = ply.get_global_position() - thisNpc.get_global_position()
		
		return Vector2.ZERO;
		#return posDiff.normalized();
