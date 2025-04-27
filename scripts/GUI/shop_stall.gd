extends Control

class_name ShopStall

var leftDoor : TextureRect;
var rightDoor : TextureRect;
var freezerDoor : TextureRect;
var freezerBlinky : TextureRect;

var partRef : Part;
var inventory : InventoryPlayer;

var curState := ShopStall.doorState.NONE;
var shopIsOpen := true;

var doorsActuallyClosed := false;

enum doorState {
	NONE,
	OPEN,
	CLOSED,
	FROZEN,
}

func changeState(newState:ShopStall.doorState):
	if curState != newState:
		##Before state change
		if curState == ShopStall.doorState.OPEN:
			#freezerBlinky.texture = load("res://graphics/images/HUD/shop/freezerblinky_off.png");
			doorsActuallyClosed = false;
			pass;
		if curState == ShopStall.doorState.CLOSED:
			doorsActuallyClosed = false;
			#freezerBlinky.texture = load("res://graphics/images/HUD/shop/freezerblinky_off.png");
			pass;
		if curState == ShopStall.doorState.FROZEN:
			$FreezeButton.button_pressed = false;
			doorsActuallyClosed = false;
			#freezerBlinky.texture = load("res://graphics/images/HUD/shop/freezerblinky_on.png");
		
		curState = newState;
		##After state change
		if curState == ShopStall.doorState.OPEN:
			if is_instance_valid(partRef):
				partRef.disable(false);
			freezerBlinky.texture = load("res://graphics/images/HUD/shop/freezerblinky_off.png");
		if curState == ShopStall.doorState.CLOSED:
			if is_instance_valid(partRef):
				partRef.disable(true);
			deselect();
			freezerBlinky.texture = load("res://graphics/images/HUD/shop/freezerblinky_off.png");
		if curState == ShopStall.doorState.FROZEN:
			if is_instance_valid(partRef):
				partRef.disable(false);
			freezerBlinky.texture = load("res://graphics/images/HUD/shop/freezerblinky_on.png");

func _ready():
	leftDoor = $DoorHolder/DoorLeft;
	rightDoor = $DoorHolder/DoorRight;
	freezerDoor = $DoorHolder/DoorFreezer;
	freezerBlinky = $FreezerBlinky;
	inventory = GameState.get_inventory();
	changeState(ShopStall.doorState.CLOSED);

func _physics_process(delta):
	updatePrice();
	
	if curState == ShopStall.doorState.CLOSED:
		freezerDoor.position.y = move_toward(freezerDoor.position.y, -144.0, delta * 200);
		if is_equal_approx(leftDoor.position.x/100, 0.0):
			leftDoor.position.x = 0;
			pass
		else:
			leftDoor.position.x = lerp(leftDoor.position.x, 0.0, delta * 10);
		if is_equal_approx(rightDoor.position.x/100, 0.0):
			rightDoor.position.x = 0;
			pass
		else:
			rightDoor.position.x = lerp(rightDoor.position.x, 0.0, delta * 10);
		
	elif curState == ShopStall.doorState.OPEN:
		leftDoor.position.x = lerp(leftDoor.position.x, -144.0, delta * 3);
		rightDoor.position.x = lerp(rightDoor.position.x, 144.0, delta * 3);
		freezerDoor.position.y = move_toward(freezerDoor.position.y, -144.0, delta * 200);
	elif curState == ShopStall.doorState.FROZEN:
		leftDoor.position.x = lerp(leftDoor.position.x, -120.0, delta * 3);
		rightDoor.position.x = lerp(rightDoor.position.x, 120.0, delta * 3);
		freezerDoor.position.y = move_toward(freezerDoor.position.y, 0.0, delta * 200);
	else:
		changeState(ShopStall.doorState.CLOSED);

func _on_freeze_button_toggled(toggled_on):
	freeze(toggled_on);
	pass # Replace with function body.

func freeze(toggled_on:=true):
	if (curState == ShopStall.doorState.OPEN) or (curState == ShopStall.doorState.FROZEN):
		if toggled_on:
			changeState(ShopStall.doorState.FROZEN);
			if GameState.get_in_state_of_play():
				SND.play_sound_nondirectional("Part.Select", 0.85, 0.5);
		else:
			changeState(ShopStall.doorState.OPEN);
			if GameState.get_in_state_of_play():
				SND.play_sound_nondirectional("Part.Select", 0.85, 0.5);
		deselect(true);
	elif curState == ShopStall.doorState.CLOSED:
		$FreezeButton.button_pressed = false;

func is_frozen() -> bool:
	return (curState == ShopStall.doorState.FROZEN);

func updatePrice():
	if is_instance_valid(partRef):
		if curState == doorState.CLOSED:
			GameState.set_text_color($BuyButton/TextHolder/Price, "scrap");
			$BuyButton/TextHolder/Price.text = "???";
		else:
			var price = partRef._get_buy_price();
			$BuyButton/TextHolder/Price.text = str(price);
			if is_affordable():
				if curState == doorState.FROZEN:
					GameState.set_text_color($BuyButton/TextHolder/Price, "ranged");
				else:
					GameState.set_text_color($BuyButton/TextHolder/Price, "scrap");
			else:
				GameState.set_text_color($BuyButton/TextHolder/Price, "unaffordable");
	else:
		GameState.set_text_color($BuyButton/TextHolder/Price, "unaffordable");
		$BuyButton/TextHolder/Price.text = "-/-";

func is_affordable() -> bool:
	var price = partRef._get_buy_price();
	var inventoryScrap = inventory.get_scrap_total()
	return price <= inventoryScrap;

func _on_buy_button_toggled(toggled_on):
	if (curState == ShopStall.doorState.OPEN):
		inventory.deselect_part();
		if is_instance_valid(partRef):
			partRef.select(toggled_on);
			if is_affordable():
				inventory.buy_mode_enable(toggled_on);
			else:
				$BuyButton.button_pressed = false;
		else:
			$BuyButton.button_pressed = false;
	else:
		$BuyButton.button_pressed = false;
	pass # Replace with function body.

func deselect(deselectPart:=false):
	$BuyButton.button_pressed = false;
	inventory.buy_mode_enable(false);
	if deselectPart && is_instance_valid(partRef):
		partRef.select(false);

func open_stall():
	if !(curState == ShopStall.doorState.FROZEN):
		changeState(ShopStall.doorState.OPEN);
		if GameState.get_in_state_of_play() && inventory.inventoryUp:
			var pitchMod = randf_range(2.5,3.5)
			SND.play_sound_nondirectional("Shop.Door.Open", 0.85, pitchMod)
	$BuyButton.disabled = false;
	$FreezeButton.disabled = false;

func close_stall():
	deselect()
	if !(curState == ShopStall.doorState.FROZEN):
		changeState(ShopStall.doorState.CLOSED);
		if GameState.get_in_state_of_play() && inventory.inventoryUp:
			var pitchMod = randf_range(2.5,3.5)
			SND.play_sound_nondirectional("Shop.Door.Open", 0.85, pitchMod)
	$BuyButton.disabled = true;
	$FreezeButton.disabled = true;

func doors_actually_closed() -> bool:
	if (curState == ShopStall.doorState.FROZEN):
		return true;
	elif (curState == ShopStall.doorState.CLOSED):
		if is_zero_approx(leftDoor.position.x) && is_zero_approx(rightDoor.position.x):
			return true
	return false;
