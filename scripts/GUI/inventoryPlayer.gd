extends Inventory

class_name InventoryPlayer

var inputHandler : InputHandler;


##Pretty stuff
var inventoryUp := false;
var gameBoard : GameBoard;
var gameState : GameBoard.gameState;
@export var HUD_inventory : Control;

func _ready():
	test_add_stuff();
	HUD_inventory = %InventoryControls;
	HUD_inventory.position.y = 1000.0;

func _process(delta):
	super(delta);
	
	test_add_stuff();
	
	if Input.is_action_just_pressed("InventoryToggle"):
		inventoryUp = !inventoryUp;
	
	if gameState == GameBoard.gameState.PLAY:
		if inventoryUp:
			HUD_inventory.position.y = lerp(HUD_inventory.position.y, 0.0, delta * 20);
		else:
			HUD_inventory.position.y = lerp(HUD_inventory.position.y, 295.0, delta * 20);
	else:
		inventoryUp = false;
		HUD_inventory.position.y = lerp(HUD_inventory.position.y, 1000.0, delta * 20);

func _physics_process(delta):
	super(delta)
	if gameState == GameBoard.gameState.PLAY:
		update_stats()

func assign_references():
	super();
	
	if ! is_instance_valid(inputHandler):
		inputHandler = GameState.get_input_handler();
	if ! is_instance_valid(gameBoard):
		gameBoard = GameState.get_game_board();
	gameState = GameState.get_game_board_state();

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

func update_stats():
	var stringHealth = "";
	var maxHealth = combatHandler.maxHealth;
	var health = combatHandler.health;
	%Lbl_Health.text = format_stat_num(health) + "/" + format_stat_num(maxHealth);
	%HealthBar.set_health(health, maxHealth);
	
	var stringEnergy = "";
	var maxEnergy = combatHandler.maxEnergy;
	var energy = combatHandler.energy;
	%Lbl_Energy.text = format_stat_num(energy) + "/" + format_stat_num(maxEnergy);
	%EnergyBar.set_health(energy, maxEnergy);

func format_stat_num(_inNum) -> String:
	var inNum = (floor(_inNum*100))/100
	
	var outString = ""
	if inNum >= 10:
		outString = str(inNum);
	outString = " " + str(inNum);
	
	if outString.length() < 5:
		outString += "0";
	return outString;
