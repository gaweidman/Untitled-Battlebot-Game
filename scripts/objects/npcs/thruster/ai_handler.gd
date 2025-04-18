extends Node3D

var isThrusting = false;
var thrustLength = 0.75;
var thrustTimer;

func ready():
	thrustTimer = thrustLength - lerp(0, thrustLength/2/4, randf())
	pass
	
func get_movement_vector():
	var ply = GameState.get_player();
	
	if ply:
		var posDiff = ply.get_node("Body").get_global_position() - get_parent().get_node("Body").get_global_position();
		posDiff = posDiff.normalized();
		
		if fmod(GameState.curtime, thrustLength * 2) < thrustLength:
			# we do this so the thruster keeps looking at the player, even when not thrusting
			return 0.001 * Vector2(posDiff.x, posDiff.z);
		else:
			return 80000 * Vector2(posDiff.x, posDiff.z);
