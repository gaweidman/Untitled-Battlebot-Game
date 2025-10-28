@icon("res://graphics/images/class_icons/arena_white.png")

extends Resource
class_name BiomeData
## Holds any and all data related to a particular biome.
##
## This includes all the filepaths for the arenas within the biome.
## TODO: This includes local enemy pool data and shop pool data.
@export var biomeName := "Arena";
@export var arenaScenes : Dictionary[String,PackedScene] = {
	"Workshop" : preload("res://scenes/levels/biome_workshop/arena_workshop/workshop.tscn")
};

func get_random_arena() -> PackedScene:
	var all = arenaScenes.duplicate(true);
	var keys = all.keys();
	keys.shuffle();
	var key = keys.pop_front();
	return arenaScenes[key];

func get_named_arena(arenaName) -> PackedScene:
	if arenaName in arenaScenes:
		return arenaScenes[arenaName];
	return null;
