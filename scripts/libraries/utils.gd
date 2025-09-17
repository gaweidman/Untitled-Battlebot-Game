extends Node

func get_all_children(node) -> Array:
	var nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_all_children(N))
		else:
			nodes.append(N)
	return nodes

func fix_angle_deg_to_rad(inAngle : float) -> float:
	while inAngle > 360:
		inAngle -= 360;
	while inAngle < -360:
		inAngle += 360; 
	return deg_to_rad(inAngle);

func fix_angle_rad_to_rad(inAngle : float) -> float:
	inAngle = rad_to_deg(inAngle);
	while inAngle > 360:
		inAngle -= 360;
	while inAngle < -360:
		inAngle += 360; 
	return deg_to_rad(inAngle);

func look_at_safe(node, target):
	if node.global_transform.origin.is_equal_approx(target): return;
	node.look_at(target);
