@icon("res://graphics/images/class_icons/arena.png")
extends Node3D

class_name Arena

@export var fallbackCameraPosition : = Vector3.ZERO; ## Where the camera goes to when there is no player to spy on.
@export var variants : Dictionary[String, String] = {"empty" : "res://scenes/prefabs/arenas/wallgridmap_test.tscn"};
var obstaclesNode : Node3D;
var currentVariant := "empty";
var usedVariants := [];

func get_current_variant():
	return currentVariant;

func load_variant(nameOfVariant := currentVariant):
	if currentVariant != nameOfVariant:
		if variants.keys().has(nameOfVariant):
			var obstaclesPath = variants[nameOfVariant];
			var obstaclesScene = load(obstaclesPath);
			
			if is_instance_valid(obstaclesNode):
				obstaclesNode.queue_free();
			
			var new = obstaclesScene.instantiate();
			add_child(new);
			obstaclesNode = new;
			
			currentVariant = nameOfVariant;

func load_new_random_variant():
	usedVariants.append(get_current_variant());
	var newVar = get_random_variant(usedVariants);
	load_variant(newVar);

## Gets a random variant key from [member variants], excluding* "empty".[br][br]
## * "empty" will be returned if it's the only key in there, or if the table is emptied, for debug purposes.
func get_random_variant(exclusions := []):
	var all = variants.duplicate(true);
	all.erase("empty");
	for entry in exclusions:
		all.erase(entry);
	if all.is_empty():
		return "empty";
	var keys = all.keys();
	keys.shuffle(); ##TODO: Seeded outcomes?
	return keys.pop_front();
