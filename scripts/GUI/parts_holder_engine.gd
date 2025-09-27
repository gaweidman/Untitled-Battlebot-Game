extends Control

class_name PartsHolder_Engine

signal buttonPressed(x:int,y:int);

func disable(disabled:bool):
	for button in get_buttons():
			button.disable(disabled);

@export var bgTiles : TileMapLayer;

func set_pattern(coordsArray : Array[Vector2i]):
	#print("Setting Pattern at ",Time.get_datetime_dict_from_system(), ": ",coordsArray)
	bgTiles.clear();
	var pat = bgTiles.tile_set.get_pattern(0);
	
	##Set up all the plug faces.
	for index in coordsArray:
		bgTiles.set_pattern(index * 2, pat);
	
	##Make the tiles fancy.
	var used = bgTiles.get_used_cells();
	bgTiles.set_cells_terrain_connect(used, 0, 0);
	
	##Set up all the plug faces a second time to cover up the weirdness.
	for index in coordsArray:
		bgTiles.set_pattern(index * 2, pat);
	
	update_all_availability_to_reflect_pattern(coordsArray);

func set_availability_of_tile(availabilityVal: bool, coords : Vector2i):
	for button in get_buttons():
		if Vector2i(button.coordX, button.coordY) == coords:
			button.set_availability(availabilityVal);

func get_Vector2i_coords_of_button(button : PartHolderButton) -> Vector2i:
	return Vector2i(button.coordX, button.coordY);

func update_all_availability_to_reflect_pattern(coordsArray : Array[Vector2i]):
	for button in get_buttons():
		var vector = get_Vector2i_coords_of_button(button);
		#print(button, vector, vector in coordsArray)
		button.set_availability(vector in coordsArray);

func get_buttons() -> Array[PartHolderButton]:
	var buttons : Array[PartHolderButton] = [];
	for child in get_children():
		if child is PartHolderButton:
			buttons.append(child);
	return buttons;
