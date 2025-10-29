@icon("res://graphics/images/class_icons/arena_white.png")

extends Resource
class_name BiomeData
## Holds any and all data related to a particular biome.
##
## This includes all the filepaths for the arenas within the biome.
## TODO: This includes local enemy pool data and shop pool data.
@export var biomeName := "ArenaBiome";
@export var arenaScenes : Dictionary[String,PackedScene] = {
	"Base" : preload("res://scenes/levels/biome_workshop/arena_workshop/workshop.tscn"),
};
var currentArenaName := "None";

func get_random_arena(excludeCurrent := true) -> PackedScene:
	var all = arenaScenes.duplicate(true);
	var keys = all.keys();
	if excludeCurrent:
		keys.erase(currentArenaName);
		if keys.is_empty():
			return arenaScenes["Base"];
	keys.shuffle();
	var key = keys.pop_front();
	return arenaScenes[key];

## Returns the arena by the given name, or "Workshop" as a fallback.
func get_named_arena(arenaName) -> PackedScene:
	if arenaName in arenaScenes:
		return arenaScenes[arenaName];
	return arenaScenes["Base"];
