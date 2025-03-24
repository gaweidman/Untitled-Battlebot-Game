extends Control

class_name Inventory

var slots := {
	## Row 0
	Vector2i(0,0) : null,
	Vector2i(1,0) : null,
	Vector2i(2,0) : null,
	Vector2i(3,0) : null,
	Vector2i(4,0) : null,
	## Row 1
	Vector2i(0,1) : null,
	Vector2i(1,1) : null,
	Vector2i(2,1) : null,
	Vector2i(3,1) : null,
	Vector2i(4,1) : null,
	## Row 2
	Vector2i(0,2) : null,
	Vector2i(1,2) : null,
	Vector2i(2,2) : null,
	Vector2i(3,2) : null,
	Vector2i(4,2) : null,
	## Row 3
	Vector2i(0,3) : null,
	Vector2i(1,3) : null,
	Vector2i(2,3) : null,
	Vector2i(3,3) : null,
	Vector2i(4,3) : null,
	## Row 4
	Vector2i(0,4) : null,
	Vector2i(1,4) : null,
	Vector2i(2,4) : null,
	Vector2i(3,4) : null,
	Vector2i(4,4) : null,
}

var listOfPieces = []

func clear_slot_at(x: int, y: int):
	var index = Vector2i(x, y);
	if index in slots.keys():
		slots[index] = null;

func get_slot_at(x: int, y: int):
	var index = Vector2i(x, y);
	var pointer = null;
	
	if index in slots.keys():
		pointer = slots[index];
	
	return pointer

func is_slot_free(x: int, y: int) -> bool:
	
	var index = Vector2i(x, y);
	
	if index in slots.keys():
		if get_slot_at(x, y) == null:
			return true;
	return false;

func get_modified_part_dimensions(part: Node, modifier: Vector2i):
	var dimensions = part.dimensions;
	var coords = [];
	for index in dimensions:
		var newCoord = index + modifier;
		coords.append(newCoord);
	
	return coords

func add_part(part: Node, invPosition : Vector2i):
	var coordsToCheck = get_modified_part_dimensions(part, invPosition);
	
	if check_coordinate_table_is_free(coordsToCheck):
		for index in coordsToCheck:
			set_slot_at(index.x, index.y, part);
		listOfPieces.append(part);
		part.invPosition = invPosition;
	else:
		pass 
	pass

func remove_part(part: Node):
	var coordsToRemove = get_modified_part_dimensions(part, part.invPosition);
	
	for coord : Vector2i in coordsToRemove:
		clear_slot_at(coord.x, coord.y);
	
	while listOfPieces.find(part) != -1:
		listOfPieces.remove_at(listOfPieces.find(part));

func check_coordinate_table_is_free(coords:Array):
	for index in coords:
		if is_slot_free(index.x, index.y):
			pass
		else:
			return false
	return true

func set_slot_at(x: int, y: int, part: Node):
	if is_slot_free(x, y):
		var index = Vector2i(x, y);
