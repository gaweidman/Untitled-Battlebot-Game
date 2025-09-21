extends Node

##Returns an array of every single child and grandchild of a Node.
func get_all_children(node, ownerToCheck : Node = null) -> Array:
	var nodes : Array = [];
	#print(node.owner)
	for N in node.get_children():
		##In theory this bit here will allow to check only nodes from the thing's original scene...
		if ownerToCheck != null:
			#print("Checking if " , ownerToCheck ," is owner of ", N)
			if N.owner != ownerToCheck:
				#print("Not owner, returning")
				return nodes;
			#print("Is owner, continuing")
		
		if N.get_child_count() > 0:
			nodes.append(N);
			nodes.append_array(get_all_children(N, ownerToCheck));
		else:
			nodes.append(N);
	return nodes;

##Returns an array of every single child of a certain type.
##If you just want to iterate over children of a certain type, this is probably less efficent than just running over get_all_children() and then checking if the node is the Class you want to check for.
func get_all_children_of_type(node, type : Object = Node, ownerToCheck : Node = null) -> Array:
	var nodes : Array = [];
	var all = get_all_children(node, ownerToCheck);
	#print(all)
	for child in all:
		if is_instance_of(child, type):
			nodes.append(child);
	return nodes;

##Appends an item to a given @Array only if the array does not already contain that item.
##Returns the array as well, if you need it.
func append_unique(hostArray : Array, input : Variant):
	if hostArray.has(input):
		hostArray.append(input);
	return hostArray;

##Appends all items in the inputArray into hostArray, except for items hostArray already contains.
##Returns the array as well, if you need it.
func append_array_unique(hostArray : Array, inputArray):
	for item in inputArray:
		append_unique(hostArray, item);
	return hostArray;

##Appends an item to a given Array only if the array does not already contain that item.
##If the input is an Array, it runs this function again on each item within it.
##This essentially unfurls every array and creates one massive one.
func append_recursive_unique(hostArray : Array, input : Variant):
	if input is Array:
		for item in input:
			append_recursive_unique(hostArray, input);
	else:
		append_unique(hostArray, input);
	return hostArray;

##Takes an angle in Degrees and then returns a Radian equivalent between -360 and 360 degrees.
func fix_angle_deg_to_rad(inAngle : float) -> float:
	while inAngle > 360.0:
		inAngle -= 360.0;
	while inAngle < -360.0:
		inAngle += 360.0; 
	return deg_to_rad(inAngle);

##Takes an angle in Radians and then returns a Radian equivalent between -360 and 360 degrees.
func fix_angle_rad_to_rad(inAngle : float) -> float:
	inAngle = rad_to_deg(inAngle);
	while inAngle > 360.0:
		inAngle -= 360.0;
	while inAngle < -360.0:
		inAngle += 360.0; 
	return deg_to_rad(inAngle);

##Runs look_at() only if the target and node do not share a position.
func look_at_safe(node : Node3D, target : Vector3):
	if node.global_transform.origin.is_equal_approx(target): return;
	node.look_at(target);
