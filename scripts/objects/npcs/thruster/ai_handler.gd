extends Node3D

var curPath : PackedVector3Array;
var curPointIndex : int;
var curTargetNode;
var oldTargetNode;
var curTargetPos : Vector3;

func ready():
	pass
	
func get_movement_vector():
	var ply = GameState.get_player();
	var thisBot = get_parent();
	
	var posDiff = ply.get_node("Body").get_global_position() - get_parent().get_node("Body").get_global_position();
	posDiff = posDiff.normalized();
		
	#return 120000 * Vector2(posDiff.x, posDiff.z);
	
	if ply:
		var newTargetNode = get_target_node();
		
		#print_rich("[color=Darkorange] ", newTargetNode, " ", ply.get_closest_ainode(), "[/color]")
		
		# bad fix but let's see if it works
		if !newTargetNode: 
			return Vector2.ZERO;
		
		# just putting newTargetNode != curTargetNode would probs work because
		# get_target_node *should* never return a null value, but this is 
		# more clear from a readability standpoint.
		if !curTargetNode || newTargetNode != curTargetNode:
			curTargetNode = newTargetNode;
			curTargetPos = curTargetNode.get_position();
		
			if curTargetNode == ply:
				var plyPos = ply.get_global_body_position();
				if plyPos != curTargetPos:
					curTargetPos = plyPos;
					make_link(plyPos);
			elif oldTargetNode != curTargetNode:
				make_link(curTargetPos);
				
			#var targetPos = get_next_point_on_path();
			var path = AI.find_path(thisBot.get_global_body_position(), curTargetPos);
	else:
		return Vector2.ZERO;
	
func get_target_node():
	var ply = GameState.get_player();
	var thisBot = get_parent()
	var closestAinode = thisBot.get_closest_ainode();
	if closestAinode == ply.get_closest_ainode():
		return ply;
	else:
		return closestAinode;

func make_link(targetPos : Vector3):
	pass;

func get_next_point_on_path():
	pass;
	
func find_path(startPos: Vector3, endPos: Vector3):
	curPath = AI.find_path(startPos, curTargetPos);
	curPointIndex = 0;
