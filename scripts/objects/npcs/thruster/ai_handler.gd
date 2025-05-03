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
	
	var badPosDiff = thisBot.get_global_body_position() - ply.get_global_body_position();
	badPosDiff = badPosDiff.normalized();
	
	return Vector2(badPosDiff.x, badPosDiff.z) * 120000;
	
	print_rich("[color=cyan]TESTING [/color]", thisBot.get_closest_ainode());
	var nextObjective = await get_next_path_objective();
	
	var posDiff = nextObjective - ply.get_global_body_position();
	posDiff = posDiff.normalized();
		
	return 120000 * Vector2(posDiff.x, posDiff.z);
	
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

func advance_in_path():
	curPointIndex += 1;
	return curPointIndex;
	
func get_current_path_objective():
	if curPointIndex < curPath.size():
		return curPath[curPointIndex];
	else: 
		var thisBot = get_parent();
		return thisBot.get_global_body_position();
	
func calculate_path(endPos: Vector3):
	print_rich("[color = darkorange]CALCULATING NEW PATH[/color]");
	var thisBot = get_parent()
	var startPos = thisBot.get_global_body_position()
	curPath = AI.find_path(startPos, curTargetPos);
	curPointIndex = 0;

# determines if there's been a change in the endpoint. returns the the new end node
# if there has been one, returns true. otherwise, returns false
func refresh_target() -> bool:
	var ply = GameState.get_player();
	var thisBot = get_parent();
	
	var newTargetNode = get_target_node();
	
	#print_rich("[color=Darkorange] ", newTargetNode, " ", ply.get_closest_ainode(), "[/color]")
	
	# bad fix but let's see if it works
	if !newTargetNode: 
		return false;
	
	# just putting newTargetNode != curTargetNode would probs work because
	# get_target_node *should* never return a null value, but this is 
	# more clear from a readability standpoint.
	
	# if the target node has changed
	if !curTargetNode && newTargetNode || newTargetNode != curTargetNode:
		# set the current target node to the new one
		curTargetNode = newTargetNode;
		return true;
		
	return false;

# determines if there's been a change in the target's position. if there has,
# sets the instance variable for it and returns true. otherwise, returns false.
func refresh_target_position():
	var ply = GameState.get_player();
	
	# if the current target node is the player
	if curTargetNode == ply:
		var plyPos = ply.get_global_body_position();
		if plyPos != curTargetPos:
			curTargetPos = plyPos;
			return true;
	elif curTargetNode is AINode:
		var newTargetPos = curTargetNode.get_global_position();
		if newTargetPos != curTargetPos:
			curTargetPos = newTargetPos;
			return true;
	else:
		var thisBot = get_parent();
		curTargetPos = thisBot.get_global_body_position();
		return false;
			
	return false;

func get_next_path_objective():
	var thisBot = get_parent();
	var ply = GameState.get_player();
	
	if ply:	
		var pathNeedsRecalculated = refresh_target() || refresh_target_position();
		
		if pathNeedsRecalculated:
			await calculate_path(curTargetPos);
			
		var currentPathObjective = get_current_path_objective();
		advance_in_path();
		return currentPathObjective;
	else:
		return thisBot.get_global_body_position();

func _process(delta):
	var ply = GameState.get_player();
	if ply.get_closest_ainode():
		#%DebugSphere.set_global_position(ply.get_closest_ainode().get_global_position());
		pass
	else:
		print("NO PLAYER :(")
	
	var posDiff = get_current_path_objective() - ply.get_global_body_position();
	posDiff = posDiff.normalized();
	if get_parent().get_closest_ainode():
		#%DebugSphere2.set_global_position(get_parent().get_closest_ainode().get_global_position());
		pass
	else:
		print("CULDN'T FIND ENEMY")
