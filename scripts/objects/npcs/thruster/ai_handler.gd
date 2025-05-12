extends Node3D

var curLink : NavigationLink3D
var curTargetNode
var oldTargetNode
var curTargetPos : Vector3


func ready():
	pass
	
func get_movement_vector():
	var ply = GameState.get_player();
	var thisBot = get_parent();
	
	if ply && ply.is_alive():
		var posDiff = ply.get_node("Body").get_global_position() - get_parent().get_node("Body").get_global_position();
		posDiff = posDiff.normalized();
			
		return 120000 * Vector2(posDiff.x, posDiff.z);
		
		var newTargetNode = get_target_node();
		






		# just putting newTargetNode != curTargetNode would probs work because
		# get_target_node *should* never return a null value, but this is 
		# more clear from a readability standpoint.
		if !curTargetNode || newTargetNode != curTargetNode:
			curTargetNode = newTargetNode;
			curTargetPos = curTargetNode.get_position();
		
		if curTargetNode == ply:
			var plyPos = ply.get_body_position();
			if plyPos != curTargetPos:
				curTargetPos = plyPos;
				make_link(plyPos);
		elif oldTargetNode != curTargetNode:
			make_link(curTargetPos);
			
		var targetPos = get_next_point_on_path();
	return Vector2.ZERO




func get_target_node():
	pass;







func make_link(targetPos : Vector3):
	pass;

func get_next_point_on_path():
	pass;
