extends Control

class_name PartTileset

@export var tmBase : TileMapLayer;
@export var tmBorder : TileMapLayer;
@export var tmScrew : TileMapLayer;
@export var tileSet : TileSet

var borderDict = {
	Part.partTypes.UNASSIGNED : 0,
	Part.partTypes.PASSIVE : 1,
	Part.partTypes.UTILITY : 2,
	Part.partTypes.RANGED : 3,
	Part.partTypes.MELEE : 4,
	Part.partTypes.TRAP : 5,
}

var screwDict = {
	Part.partRarities.COMMON : 0,
	Part.partRarities.UNCOMMON : 1,
	Part.partRarities.RARE : 2,
}

func _ready():
	tmBase.clear();
	tmBorder.clear();
	tmScrew.clear();

func set_pattern(coordsArray : Array[Vector2i], type : Part.partTypes, rarity : Part.partRarities):
	print("Setting Pattern at ",Time.get_datetime_dict_from_system(), ": ",coordsArray)
	tmBase.clear();
	tmBorder.clear();
	tmScrew.clear();
	for index in coordsArray:
		var pat = tileSet.get_pattern(0);
		tmBase.set_pattern(index * 2, pat);
		tmBorder.set_pattern(index * 2, pat);
		tmScrew.set_pattern(index * 2, pat);
	var used = tmBase.get_used_cells();
	tmBase.set_cells_terrain_connect(used, 0, 0);
	tmBorder.set_cells_terrain_connect(used, 0, borderDict[type]);
	tmScrew.set_cells_terrain_connect(used, 1, screwDict[rarity]);
