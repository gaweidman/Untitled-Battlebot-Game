extends GridMap

class_name ArenaObstacleGrid

@export var wallPiecesSceneFolder := "res://scenes/prefabs/arenas/wall-pieces/"
var built := false;
var started := false;

var cells = [];
## Starts the building sequence. Returns the amount of cells to build.
func start_building_sequence() -> int:
	cells = get_used_cells();
	started = true;
	built = false;
	return cells.size() + 1;

func _process(delta):
	if cells.size() > 0:
		built = false;
		var tileCoord = cells.pop_front();
		var tileIDX = get_cell_item(tileCoord);
		var tileName = mesh_library.get_item_name(tileIDX);
		print(tileName);
		var fileNameToCheck = str(wallPiecesSceneFolder, tileName.to_snake_case(), ".tscn");
		if FileAccess.file_exists(fileNameToCheck):
			print("file found");
			var newThing = load(fileNameToCheck).instantiate();
			set_cell_item(tileCoord, INVALID_CELL_ITEM);
			add_child(newThing);
			var pos = to_global(map_to_local(tileCoord));
			newThing.global_position = pos;
	else:
		if started:
			built = true;
