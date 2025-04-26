extends Node3D
class_name AIMap;

# Array of Vector3s, points where the raycasts collide with the arena floor.
# These points are actually the nodes. The raycasts are just meant to find
# the exact point on the ground.
var ai_nodes = [];

func _ready() -> void:
	var castContainer = get_node("Raycasts");
	var raycasts = castContainer.get_children();
	for raycast in raycasts:
		raycast.marked = false;
			
func _process(float) -> void:
	# doing this on _ready dosn't work
	var castContainer = get_node("Raycasts");
	var raycasts = castContainer.get_children();
	if raycasts.length() > 0:
		for raycast in raycasts:
			if raycast.is_colliding() && !raycast.marked:
				print("COLLIDING");
				ai_nodes.append(raycast.get_collision_point());
				raycast.queue_free();
				raycast.marked = true;
