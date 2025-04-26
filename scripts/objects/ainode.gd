extends Node3D

func get_ylevel():
	var position = get_position();
	return position.y > 1.75 and 1 or 2;
