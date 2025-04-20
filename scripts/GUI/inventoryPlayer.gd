extends Inventory

class_name InventoryPlayer

var inputHandler : InputHandler;


##Pretty stuff
var inventoryUp := false;
var gameBoard : GameBoard;
var gameState : GameBoard.gameState;
@export var HUD_inventory : Control;
@export var HUD_inventoryPanel : Control;
@export var HUD_engine : PartsHolder_Engine;
@export var HUD_shop : Shop;
var scrap := 9999.0;
var startingKitAssigned := true;
var buyMode := false;

func _ready():
	HUD_inventory = %InventoryControls;
	HUD_inventoryPanel = $InventoryControls/InventoryPanel;
	HUD_engine = $InventoryControls/PartsHolder_Engine;
	HUD_shop = $InventoryControls/BackingTexture/Shop;
	HUD_inventory.position.y = 1000.0;
	inventory_panel_toggle(false);

func _process(delta):
	super(delta);
	
	test_add_stuff();
	
	if Input.is_action_just_pressed("InventoryToggle"):
		inventory_panel_toggle(!inventoryUp);
	
	if GameState.get_in_state_of_play():
		if inventoryUp:
			HUD_inventory.position.y = lerp(HUD_inventory.position.y, 0.0, delta * 20);
		else:
			HUD_inventory.position.y = lerp(HUD_inventory.position.y, 295.0, delta * 20);
	else:
		inventoryUp = false;
		HUD_inventory.position.y = lerp(HUD_inventory.position.y, 1000.0, delta * 20);

func _physics_process(delta):
	super(delta)
	if GameState.get_in_state_of_play():
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

func starting_kit():
	deselect_part();
	clear_inventory();
	add_part_from_scene(1, 0, "res://scenes/prefabs/objects/parts/playerParts/part_sawblade.tscn", 1);
	#add_part_from_scene(1, 1, "res://scenes/prefabs/objects/parts/playerParts/part_repair.tscn", 2);
	add_part_from_scene(0, 0, "res://scenes/prefabs/objects/parts/playerParts/part_cannon.tscn", 0);
	startingKitAssigned = true;
	$InventoryControls/BackingTexture/Shop.reroll_shop();
	scrap = 0;

func test_add_stuff():
	#print(ply)
	if (assign_player()) and (not startingKitAssigned):
		starting_kit();
		startingKitAssigned = true;
	pass
	
	##Shop Stalls
	slots["StallA"] = null;
	slots["StallB"] = null;
	slots["StallC"] = null;

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
	
	update_scrap();

func format_stat_num(_inNum) -> String:
	var inNum = (floor(_inNum*100))/100
	
	var outString = ""
	if inNum >= 10:
		outString = str(inNum);
	outString = " " + str(inNum);
	
	if outString.length() < 5:
		outString += "0";
	return outString;

func sell_part(part:Part):
	remove_part(part, true, true);

func add_scrap(amt):
	scrap = max(0, scrap + roundi(amt));
	update_scrap();

func remove_scrap(amt):
	scrap = max(0, scrap - roundi(amt));
	update_scrap();

func update_scrap():
	$"InventoryControls/BackingTexture/ScrapCounter".text = str(get_scrap_total());

func update_round():
	$"InventoryControls/BackingTexture/Lbl_Round".text = str(GameState.get_round_number());

func get_scrap_total():
	return roundi(scrap);

func _on_inventory_panel_inventory_toggle(foo):
	inventory_panel_toggle(foo);
	pass # Replace with function body.

func inventory_panel_toggle(foo):
	inventoryUp = foo;
	HUD_inventoryPanel.change_sprites(foo);
	if not foo:
		select_part(selectedPart, false);
		HUD_engine.disable(true);

func select_part(part:Part, foo:bool):
	super(part, foo);
	if foo:
		%InfoBox.populate_info(part);
		if (part is PartActive) && part.ownedByPlayer:
			%ActiveReassignmentButtons.disable(false);
		else:
			%ActiveReassignmentButtons.disable(true);
	else:
		%InfoBox.clear_info();
		%ActiveReassignmentButtons.disable(true);

func _on_info_box_sell_part(part):
	sell_part(part);
	pass # Replace with function body.

var movingPart:=false;
func _on_parts_holder_engine_button_pressed(x, y):
	print("button pressed at ",x, ", ",y)
	if movingPart:
		move_part(selectedPart, Vector2i(x,y));
	pass # Replace with function body.

func _on_move_button_toggled(toggled_on):
	move_mode_enable(toggled_on);
	pass # Replace with function body.

func move_mode_enable(toggled_on:bool):
	if $InventoryControls/BackingTexture/InfoBox/MoveButton.button_pressed != toggled_on:
		$InventoryControls/BackingTexture/InfoBox/MoveButton.button_pressed = toggled_on;
	
	movingPart = toggled_on;
	HUD_engine.disable(not toggled_on);
	if is_instance_valid(selectedPart):
		selectedPart.move_mode(toggled_on);
	
	if not toggled_on:
		buyMode = false;

###Shop stuff below

func buy_mode_enable(toggled_on:bool):
	if is_instance_valid(selectedPart):
		if selectedPart.invHolderNode is ShopStall:
			buyMode = toggled_on;
			move_mode_enable(toggled_on);

func deselect_part():
	super();
	var shop = $InventoryControls/BackingTexture/Shop
	shop.deselect();

func add_part_to_shop(_partScene:String):
	var stall = next_empty_shop_stall();
	if is_instance_valid(stall):
		if is_instance_valid(stall.partRef):
			print("No part is to be placed here!!! (", stall.name,")")
			slots[str(stall.name)] = stall.partRef;
			return
		var partScene = load(_partScene);
		var part:Part = partScene.instantiate();
		print(stall.partRef)
		part.inventoryNode = self;
		part.inPlayerInventory = true;
		part.invHolderNode = stall;
		if part is PartActive:
			part.set_equipped(false);
		stall.partRef = part;
		slots[str(stall.name)] = part;
		print(stall.partRef)
		#part.
		print("Adding ", part.name, " to shop stall ", stall.name)
		add_child(part);
	pass

func next_empty_shop_stall():
	if !is_instance_valid(slots["StallA"]):
		var StallA = $InventoryControls/BackingTexture/Shop/StallA;
		if ! StallA.is_frozen():
			return StallA;
	
	if !is_instance_valid(slots["StallB"]):
		var StallB = $InventoryControls/BackingTexture/Shop/StallB;
		if ! StallB.is_frozen():
			return StallB;
	
	if !is_instance_valid(slots["StallC"]):
		var StallC = $InventoryControls/BackingTexture/Shop/StallC;
		if ! StallC.is_frozen():
			return StallC;
	return null;

func is_affordable(inAmt : float):
	return inAmt <= get_scrap_total();

func add_part(part: Part, invPosition : Vector2i):
	super(part, invPosition);
	return;
	pass

func add_part_post(part:Part):
	super(part);
	part.inPlayerInventory = true;
	part.ownedByPlayer = true;
	part.invHolderNode = HUD_engine;

func remove_part_post(part:Part, beingSold := false, beingBought := false):
	super(part);
	if part.invHolderNode is ShopStall:
		slots[part.invHolderNode.name] = null;
	if beingSold:
		add_scrap(part._get_sell_price());
		part.on_sold();
	if beingBought:
		remove_scrap(part._get_buy_price());
		part.on_bought();
	if part.invHolderNode is ShopStall:
		part.invHolderNode.partRef = null;
		part.invHolderNode.close_stall();

func clear_shop_stall(stall:ShopStall, ignoreFrozen := false):
	if is_instance_valid(stall):
		if is_instance_valid(stall.partRef):
			if ignoreFrozen:
				stall.freeze(false);
				remove_part(stall.partRef, true);
			else:
				if (stall.curState != ShopStall.doorState.FROZEN):
					#print(stall.name + " is NOT frozen")
					remove_part(stall.partRef, true);

func clear_shop(ignoreFrozen := false, reroll := false):
	var StallA = $InventoryControls/BackingTexture/Shop/StallA;
	clear_shop_stall(StallA, ignoreFrozen);
	var StallB = $InventoryControls/BackingTexture/Shop/StallB;
	clear_shop_stall(StallB, ignoreFrozen);
	var StallC = $InventoryControls/BackingTexture/Shop/StallC;
	clear_shop_stall(StallC, ignoreFrozen);
	
	if reroll:
		$InventoryControls/BackingTexture/Shop.reroll_shop();

################

func new_round():
	update_round();
	HUD_shop.close_up_shop();
	for part in listOfPieces:
		if is_instance_valid(part):
			if part is Part:
				part.new_round();
	inventory_panel_toggle(false);

func end_round():
	update_round();
	for part in listOfPieces:
		if is_instance_valid(part):
			if part is Part:
				part.end_round();

func take_damage(damage:float):
	for part in listOfPieces:
		if is_instance_valid(part):
			if part is Part:
				part.take_damage(damage);
