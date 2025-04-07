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
		for index in coordsToCheck:
			set_slot_at(index.x, index.y, part);
		listOfPieces.append(part);
		part.invPosition = invPosition;
		part.inventoryNode = self;
		if part is PartActive:
			part.positionNode = battleBotBody;
			part.meshNode.reparent(battleBotBody);
	else:
		pass 
	pass

func remove_part(part: Part):
	var coordsToRemove = get_modified_part_dimensions(part, part.invPosition);
	part.invPosition = Vector2i(0,0);
	if part is PartActive:
		part.positionNode = null;
		part.meshNode.reparent(part);
	
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

func set_slot_at(x: int, y: int, part: Part):
	if is_slot_free(x, y):
		var index = Vector2i(x, y);

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
