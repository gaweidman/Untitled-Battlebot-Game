extends Control

class_name Shop

var inventory : InventoryPlayer;
var player : Player;

var shopDoor : TextureRect;
var shopDoorVelocity := 0.0;
var shopDoorPrevPosY := 0.0;
var doorOpen := false;
var doorActuallyClosed := true;
var doorStomps := 9;
var thumping := true;
var shopOpen := false;

var awaiting_reroll := false;

func _ready():
	inventory = GameState.get_inventory();
	player = GameState.get_player();
	shopDoor = $ShopDoor;
	reset_shop();

func deselect():
	for stall in get_children():
		if stall is ShopStall:
			stall.deselect();

func reset_shop():
	clear_shop_spawn_list();
	add_part_to_spawn_list("res://scenes/prefabs/objects/parts/playerParts/part_big_battery.tscn", 1);
	add_part_to_spawn_list("res://scenes/prefabs/objects/parts/playerParts/part_cannon.tscn", 2);
	add_part_to_spawn_list("res://scenes/prefabs/objects/parts/playerParts/part_coolant.tscn", 2);
	add_part_to_spawn_list("res://scenes/prefabs/objects/parts/playerParts/part_impact_generator.tscn", 1);
	add_part_to_spawn_list("res://scenes/prefabs/objects/parts/playerParts/part_impact_magnet.tscn", 1);
	add_part_to_spawn_list("res://scenes/prefabs/objects/parts/playerParts/part_jank_battery.tscn", 3);
	add_part_to_spawn_list("res://scenes/prefabs/objects/parts/playerParts/part_repair.tscn", 1);
	add_part_to_spawn_list("res://scenes/prefabs/objects/parts/playerParts/part_sawblade.tscn", 2);
	add_part_to_spawn_list("res://scenes/prefabs/objects/parts/playerParts/part_RoundBell.tscn", 2);
	add_part_to_spawn_list("res://scenes/prefabs/objects/parts/playerParts/part_scrap_plating.tscn", 1);
	add_part_to_spawn_list("res://scenes/prefabs/objects/parts/enemyParts/part_ranger_gun.tscn", 3);
	rerollPriceIncrementPermanent = 0;
	rerollPriceIncrement = 0;
	healPriceIncrementPermanent = 0;
	healPriceIncrement = 0;
	close_up_shop();

func open_up_shop():
	clopen_door(true);
	shopOpen = true;
	clopen_stalls(true);

func clopen_stalls(open:bool):
	if open:
		for stall in get_children():
			if stall is ShopStall:
				stall.open_stall();
	else:
		for stall in get_children():
			if stall is ShopStall:
				stall.close_stall();

func close_up_shop():
	clopen_door();
	shopOpen = false;
	clopen_stalls(false);

func clopen_door(open:=false):
	if open:
		doorOpen = true;
		doorActuallyClosed = false;
		doorStomps = 0;
		SND.play_sound_nondirectional("Shop.Door.Open", 1.0, 2.0)
	else:
		doorOpen = false;
		shopDoorVelocity = 0;

func _physics_process(delta):
	if is_node_ready():
		update_health_button();
		update_reroll_button();
		
		##Fancy door shutting
		var makeThump = false;
		if doorOpen && !is_equal_approx(shopDoor.position.y, -237):
			shopDoorVelocity = move_toward(shopDoorVelocity, -10, delta*100);
		else:
			shopDoorVelocity += 9.87 * delta;
			if (shopDoor.position.y + shopDoorVelocity) > 0:
				shopDoor.position.y = 0;
				shopDoorVelocity *= -0.3;
				makeThump = true;
				if not doorActuallyClosed:
					door_closed();
				else:
					if doorStomps < 1:
						doorStomps += 1;
						door_closed_sound(0.95);
					else:
						if doorStomps < 2:
							doorStomps += 1;
							door_closed_sound(0.8);
						else:
							if doorStomps < 3:
								doorStomps += 1;
								inventory.inventory_panel_toggle(false);
		
		shopDoor.position.y = clamp(shopDoor.position.y + shopDoorVelocity, -237, 0);
		
		
		if awaiting_reroll:
			if all_stalls_closed():
				awaiting_reroll = false;
				reroll_shop();
				if shopOpen:
					clopen_stalls(true);

func door_closed():
	reroll_shop();
	rerollPriceIncrementPermanent += 0.5;
	rerollPriceIncrement = rerollPriceIncrementPermanent;
	healPriceIncrementPermanent += 1.0;
	healPriceIncrement = healPriceIncrementPermanent;
	doorActuallyClosed = true;
	door_closed_sound(0.9);

func door_closed_sound(volume := 1.0):
	if !inventory.inventoryUp:
		volume *= 0.8
	var pitchMod = randf_range(0.7, 1.3)
	SND.play_sound_nondirectional("Shop.Door.Thump", volume, pitchMod);

var healAmountBase := 1.0;
var healAmountModifier := 1.0;
var healPriceBase := 4.0;
var healPriceModifier := 1.0;
var healPricePressIncrement := 2.0;
var healPriceIncrement := 0.0;
var healPriceIncrementPermanent := 0.0;

func update_health_button():
	$HealButton/TextHolder/HEAL.text = "HEAL\n"+str(get_heal_amount()) + " HP"
	$HealButton/TextHolder/Price.text = str(get_heal_price());
	if inventory.is_affordable(get_heal_price()) && ! player.at_max_health():
		GameState.set_text_color($HealButton/TextHolder/Price, "scrap");
	else:
		GameState.set_text_color($HealButton/TextHolder/Price, "unaffordable");
func get_heal_amount():
	return healAmountBase * healAmountModifier;
func get_heal_price():
	return floori((healPriceBase + healPriceIncrement) * healPriceModifier);

func _on_heal_button_pressed():
	if inventory.is_affordable(get_heal_price()):
		if ! player.at_max_health():
			inventory.remove_scrap(get_heal_price());
			healPriceIncrement += healPricePressIncrement;
			player.heal(get_heal_amount());
			rerollPriceIncrementPermanent += 0.5;
	pass # Replace with function body.


var rerollPriceBase := 5.0;
var rerollPriceModifier := 1.0;
var rerollPricePressIncrement := 1.0;
var rerollPriceIncrement := 0.0;
var rerollPriceIncrementPermanent := 0.0;

func update_reroll_button():
	$RerollButton/TextHolder/Price.text = str(get_reroll_price());
	if inventory.is_affordable(get_reroll_price()):
		GameState.set_text_color($RerollButton/TextHolder/Price, "scrap");
	else:
		GameState.set_text_color($RerollButton/TextHolder/Price, "unaffordable");
func get_reroll_price():
	return floori((rerollPriceBase + rerollPriceIncrement) * rerollPriceModifier);

func _on_reroll_button_pressed():
	if (inventory.is_affordable(get_reroll_price())) and not awaiting_reroll:
		inventory.remove_scrap(get_reroll_price());
		rerollPriceIncrement += rerollPricePressIncrement;
		clopen_stalls(false);
		awaiting_reroll = true;
		rerollPriceIncrementPermanent += 0.25;
	pass # Replace with function body.

func all_stalls_closed() -> bool:
	for stall in get_children():
		if stall is ShopStall:
			if ! stall.doors_actually_closed():
				return false;
	return true;

##The pool of parts currently available
var partPool := {};

func clear_shop_spawn_list():
	partPool.clear();

func add_part_to_spawn_list(_scene : String, weight : int):
	var scene = load(_scene);
	if scene in partPool.keys():
		partPool[scene] += weight;
		if partPool[scene] && partPool[scene] <= 0:
			partPool.erase(scene);
	else:
		partPool[scene] = weight;

func return_random_part() -> PackedScene:
	var pool = []
	var spawnListCopy = partPool.duplicate(true);
	for scene in spawnListCopy.keys():
		var weight = spawnListCopy[scene];
		
		while weight > 0:
			pool.append(scene);
			weight -= 1;
	
	var sceneReturn = pool.pick_random();
	return sceneReturn;

func reroll_shop():
	inventory.clear_shop();
	var counter = 0;
	while (inventory.next_empty_shop_stall() != null) and counter < 4:
		var part: = return_random_part();
		var sceneString = part.resource_path;
		inventory.add_part_to_shop(sceneString);
		counter += 1;
