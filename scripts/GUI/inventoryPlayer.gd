extends Inventory

class_name InventoryPlayer

var inputHandler : InputHandler;

func _ready():
	test_add_stuff();

func _process(delta):
	super(delta);
	
	test_add_stuff();

func assign_references():
	super();
	
	if ! is_instance_valid(inputHandler):
		inputHandler = GameState.get_input_handler();

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

func all_refs_valid():
	if is_instance_valid(inputHandler) and is_instance_valid(combatHandler) and is_instance_valid(battleBotBody) and is_instance_valid(thisBot):
		return true;
	assign_references();
	return false;

func test_add_stuff():
	#print(ply)
	if assign_player():
		add_part_from_scene(0, 0, "res://scenes/prefabs/objects/parts/part_active_projectile.tscn", 0);
		add_part_from_scene(2, 0, "res://scenes/prefabs/objects/parts/playerParts/part_sawblade.tscn", 1);
	pass
