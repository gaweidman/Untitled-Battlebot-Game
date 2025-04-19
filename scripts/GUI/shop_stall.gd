extends Control

class_name ShopStall

var leftDoor : TextureRect;
var rightDoor : TextureRect;
var freezerDoor : TextureRect;
var freezerBlinky : TextureRect;

var partRef : Part;
var inventory : InventoryPlayer;

var curState := ShopStall.doorState.NONE;

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
	#if Input.is_action_just_pressed("FireRanged"):
		#changeState(ShopStall.doorState.CLOSED);
	#if Input.is_action_just_pressed("FireMelee"):
		#changeState(ShopStall.doorState.OPEN);
	#if Input.is_action_just_pressed("FireUtility"):
		#changeState(ShopStall.doorState.FROZEN);
		#changeState(ShopStall.doorState.CLOSED);
	
	updatePrice();
	
	if curState == ShopStall.doorState.CLOSED:
		var doorCheckLeft = false;
		var doorCheckRight = false;
		freezerDoor.position.y = move_toward(freezerDoor.position.y, -144.0, delta * 200);
		if is_equal_approx(leftDoor.position.x, 0.0):
			doorCheckLeft = true;
		else:
			leftDoor.position.x = lerp(leftDoor.position.x, 0.0, delta * 10);
		if is_equal_approx(rightDoor.position.x, 0.0):
			doorCheckRight = true;
		else:
			rightDoor.position.x = lerp(rightDoor.position.x, 0.0, delta * 10);
		
		if doorCheckLeft and doorCheckRight: 
			doorsActuallyClosed = true;
		else:
			doorsActuallyClosed = false;
	elif curState == ShopStall.doorState.OPEN:
		leftDoor.position.x = lerp(leftDoor.position.x, -144.0, delta * 7);
		rightDoor.position.x = lerp(rightDoor.position.x, 144.0, delta * 7);
		freezerDoor.position.y = move_toward(freezerDoor.position.y, -144.0, delta * 200);
	elif curState == ShopStall.doorState.FROZEN:
		leftDoor.position.x = lerp(leftDoor.position.x, -120.0, delta * 7);
		rightDoor.position.x = lerp(rightDoor.position.x, 120.0, delta * 7);
		freezerDoor.position.y = move_toward(freezerDoor.position.y, 0.0, delta * 200);
	else:
		changeState(ShopStall.doorState.CLOSED);


func _on_freeze_button_toggled(toggled_on):
	if (curState == ShopStall.doorState.OPEN) or (curState == ShopStall.doorState.FROZEN):
		if toggled_on:
			changeState(ShopStall.doorState.FROZEN);
		else:
			changeState(ShopStall.doorState.OPEN);
		deselect(true);
	elif curState == ShopStall.doorState.CLOSED:
		$FreezeButton.button_pressed = false;
	pass # Replace with function body.

#part.inventoryNode.move_mode_enable(true);
#f2ec6b

func updatePrice():
	if is_instance_valid(partRef):
		if curState == doorState.CLOSED:
			$BuyButton/Price.text = "???";
		else:
			var price = partRef._get_sell_price();
			$BuyButton/Price.text = str(price);
			if is_affordable():
				$BuyButton/Price.set_deferred("theme_override_colors/font_color", Color("f2ec6b"))
			else:
				$BuyButton/Price.set_deferred("theme_override_colors/font_color", Color("ff0000"))
	else:
		$BuyButton/Price.text = "???";

func is_affordable() -> bool:
	var price = partRef._get_sell_price();
	var inventoryScrap = inventory.get_scrap_total()
	return price <= inventoryScrap;

func _on_buy_button_toggled(toggled_on):
	if (curState == ShopStall.doorState.OPEN):
		partRef.select(toggled_on);
		if is_affordable():
			inventory.buy_mode_enable(toggled_on);
		else:
			$BuyButton.button_pressed = false;
	else:
		$BuyButton.button_pressed = false;
	pass # Replace with function body.

func deselect(deselectPart:=false):
	$BuyButton.button_pressed = false;
	inventory.buy_mode_enable(false);
	if deselectPart:
		partRef.select(false);
