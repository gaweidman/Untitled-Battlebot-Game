extends StaticBody3D
class_name AINode

func get_ylevel():
	var position = get_position();
	return position.y > 1.75 and 1 or 2;
