extends Control

class_name Inventory

var inputHandler : InputHandler;
var battleBotBody : RigidBody3D;
var combatHandler : CombatHandler;

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

func is_slot_free(x: int, y: int, filterPart:Part) -> bool:
	
	var index = Vector2i(x, y);
	
	if index in slots.keys():
		var slotAt = get_slot_at(x, y)
		if slotAt == null:
			return true;
		else:
			if is_instance_valid(filterPart):
				if slotAt == filterPart:
					return true;
	return false;

func get_modified_part_dimensions(part: Part, modifier: Vector2i):
	var dimensions = part.dimensions;
	var coords = [];
	for index in dimensions:
		var newCoord = index + modifier;
		coords.append(newCoord);
	
	return coords

func check_coordinate_table_is_free(coords:Array, filterPart:Part):
	for index in coords:
		if is_slot_free(index.x, index.y,filterPart):
			pass
		else:
			return false
	return true

func is_there_space_for_part(part:Part, invPosition : Vector2i) -> bool:
	if is_instance_valid(part):
		var partCoords = get_modified_part_dimensions(part, invPosition)
		if check_coordinate_table_is_free(partCoords, part):
			return true;
	return false;

func add_part(part: Part, invPosition : Vector2i):
	var coordsToCheck = get_modified_part_dimensions(part, invPosition);
	
	if check_coordinate_table_is_free(coordsToCheck, part):
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

func move_part(part:Part, invPosition : Vector2i):
	if is_there_space_for_part(part, invPosition):
		remove_part(part);
		add_part(part, invPosition);
		deselect_part();
	pass

func set_slot_at(x: int, y: int, part: Part):
	if is_slot_free(x, y, part):
		var index = Vector2i(x, y);
		slots[index] = part;

func add_part_from_scene(x: int, y:int, _partScene:String, activeSlot = null):
	if all_refs_valid():
		if is_slot_free(x,y, null):
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

func deselect_part():
	if is_instance_valid(selectedPart):
		select_part(selectedPart, false);
	else:
		selectedPart = null;

#########################

func _ready():
	test_add_stuff()

func _process(delta):
	if ! is_instance_valid(inputHandler):
		inputHandler = GameState.get_input_handler();
	
	if ! is_instance_valid(combatHandler):
		combatHandler = GameState.get_combat_handler();
		combatHandler.inventory = self;
	
	if ! is_instance_valid(battleBotBody):
		test_add_stuff()

func _physics_process(delta):
	if battleBotBody != null:
		pass

func test_add_stuff():
	#print(ply)
	if assign_player():
		var partScene = load("res://scenes/prefabs/objects/parts/part_active_projectile.tscn");
		var part = partScene.instantiate();
		add_child(part);
		add_part(part, Vector2i(0,0));
		combatHandler.activeParts[0] = part;
		
		
		var partScene2 = load("res://scenes/prefabs/objects/parts/part_active_melee.tscn");
		var part2 = partScene2.instantiate();
		add_child(part2);
		add_part(part2, Vector2i(2,0));
		combatHandler.activeParts[1] = part2;
	pass

func assign_player(makeNull := false):
	
	if makeNull:
		battleBotBody = null;
	else:
		var ply = GameState.get_player();
		if ply:
			if ply.body != null:
				battleBotBody = ply.body
				return true;
	return false;
