extends Control

class_name Inventory

var battleBotBody : RigidBody3D;
var combatHandler : CombatHandler;
var thisBot : Combatant;

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
var selectedPart: Part;

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

func get_modified_part_dimensions(part: Part, modifier: Vector2i):
	var dimensions = part.dimensions;
	var coords = [];
	for index in dimensions:
		var newCoord = index + modifier;
		coords.append(newCoord);
	
	return coords

func add_part(part: Part, invPosition : Vector2i):
	var coordsToCheck = get_modified_part_dimensions(part, invPosition);
	
	if check_coordinate_table_is_free(coordsToCheck):
		print("Coord table is free... somehow ", coordsToCheck)
		for index in coordsToCheck:
			set_slot_at(index.x, index.y, part);
		listOfPieces.append(part);
		part.invPosition = invPosition;
		part.inventoryNode = self;
		if self is InventoryPlayer:
			part.inPlayerInventory = true;
		if part is PartActive:
			part.positionNode = battleBotBody;
			part.meshNode.reparent(battleBotBody);
	else:
		pass 
	pass

func remove_part(part: Part, destroy:=false):
	var coordsToRemove = get_modified_part_dimensions(part, part.invPosition);
	part.invPosition = Vector2i(0,0);
	if part is PartActive:
		part.positionNode = null;
		part.meshNode.reparent(part);
	
	if self is InventoryPlayer:
		part.inPlayerInventory = false;
	
	for coord : Vector2i in coordsToRemove:
		clear_slot_at(coord.x, coord.y);
	
	while listOfPieces.find(part) != -1:
		listOfPieces.remove_at(listOfPieces.find(part));
	
	if destroy:
		part.destroy();

func check_coordinate_table_is_free(coords:Array):
	for index in coords:
		if is_slot_free(index.x, index.y):
			pass
		else:
			return false
	return true

func set_slot_at(x: int, y: int, part: Part):
	if is_slot_free(x, y):
		var index = Vector2i(x, y);
		slots[index] = part;

func add_part_from_scene(x: int, y:int, _partScene:String, activeSlot = null):
	if all_refs_valid():
		if is_slot_free(x,y):
			var partScene = load(_partScene);
			var part = partScene.instantiate();
			print("Adding ", part.name)
			add_child(part);
			add_part(part, Vector2i(x,y));
			if activeSlot != null && activeSlot is int:
				combatHandler.activeParts[activeSlot] = part;

func select_part(part:Part, foo:bool):
	if foo:
		if part != selectedPart:
			if is_instance_valid(selectedPart):
				selectedPart.select(false);
			selectedPart = part;
			print("selected new part: ", part);
	else:
		selectedPart = null;
		if is_instance_valid(part):
			if part.selected:
				part.select(false);
		print("Unselected part: ", part);

#########################

func _process(delta):
	assign_references();

func assign_references():
	if ! is_instance_valid(combatHandler):
		var par = get_parent();
		combatHandler = par.get_node("CombatHandler");
	
	if ! is_instance_valid(battleBotBody):
		var par = get_parent();
		battleBotBody = par.get_node("Body");
		
	if ! is_instance_valid(thisBot):
		var par = get_parent();
		if par is Combatant:
			thisBot = par;

func all_refs_valid():
	if is_instance_valid(combatHandler) and is_instance_valid(battleBotBody) and is_instance_valid(thisBot):
		return true;
	assign_references();
	return false;

func _physics_process(delta):
	if battleBotBody != null:
		pass
