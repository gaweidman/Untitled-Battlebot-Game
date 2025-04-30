##The base class for parts the player and enemies use.
extends Control
class_name Part

var invPosition := Vector2i(-9,-9);
var partBounds : Vector2i;
var inPlayerInventory := false;
var ownedByPlayer := false;
var invHolderNode : Control;
var thisBot : Combatant;
@export var textureBase : Control;
@export var textureIcon : TextureRect;
@export var tilemaps : PartTileset;

var selected := false;

@export_category("Gameplay")
@export var scrapCostBase : int;
var scrapSellModifier := 1.0;
var scrapSellModifierBase := (2.0/3.0);
@export var inventoryNode : Inventory;
@export var dimensions : Array[Vector2i];
@export var myPartType := partTypes.UNASSIGNED;
@export var myPartRarity := partRarities.COMMON;

@export_category("Vanity")
@export var partName := "Part";
@export_multiline var partDescription := "No description given.";
@export var partIcon : CompressedTexture2D;
@export var partIconOffset := Vector2i(0,0);
@export var invSprite : CompressedTexture2D;
@export var screwSprite : CompressedTexture2D;

enum partTypes {
	UNASSIGNED,
	PASSIVE,
	UTILITY,
	MELEE,
	RANGED,
	TRAP,
}

enum partRarities {
	COMMON,
	UNCOMMON,
	RARE,
}

func _ready():
	#dimensions = [Vector2i(0,0), Vector2i(0,1), Vector2i(1,0), Vector2i(1,1)]
	if dimensions == null:
		dimensions = [Vector2i(0,0)]
	
	##Set part type
	if myPartType == partTypes.UNASSIGNED:
		if self is PartActive:
			if self is PartActiveProjectile:
				myPartType = partTypes.RANGED;
			elif self is PartActiveMelee:
				myPartType = partTypes.MELEE;
			else:
				myPartType = partTypes.UTILITY;
		else:
			myPartType = partTypes.PASSIVE;

##Run when the part gets added to the player's inventory via InventoryPlayer.add_part_post().
func inventory_vanity_setup():
	print("somethin' fishy....")
	textureIcon.set_deferred("texture", partIcon);
	textureIcon.set_deferred("position", (partIconOffset*48) + Vector2i(8,8));
	_populate_buttons();
	tilemaps.call_deferred("set_pattern", dimensions, myPartType, myPartRarity)
	#tilemaps.set_pattern();
	textureBase.show();

##Adds the buttons that let you click the part and move it around and stuff. Should theoretically only ever run if placed into the inventory of the player.
func _populate_buttons():
	for index in dimensions:
		var button = %Buttons.buttonPrefab.instantiate();
		%Buttons.add_child(button);
		
		button.part = self;
		button.buttonHolder = %Buttons;
		
		button.set_deferred("position", index * 48);
		#button.set_deferred("size", Vector2i(48, 48));
		#print(button.disabled)

func _get_part_type() -> partTypes:
	return myPartType;

func _get_sell_price():
	var discount = 1.0 * scrapSellModifier * scrapSellModifierBase;
	
	var sellPrice = discount * scrapCostBase
	
	return roundi(max(1, sellPrice))

func _get_buy_price(_discount := 0.0, markup:=0.0, fixedDiscount := 0, fixedMarkup := 0):
	var discount = 1.0 + _discount + markup;
	
	var sellPrice = discount * scrapCostBase
	
	return roundi(max(1, sellPrice + fixedDiscount + fixedMarkup))

func _get_part_bounds() -> Vector2i:
	var highestX = 1;
	var lowestX = 0;
	var highestY = 1;
	var lowestY = 0;
	
	for index in dimensions:
		var x = index.x + 1;
		highestX = max(x, highestX)
		lowestX = min(x, lowestX)
		var y = index.y + 1;
		highestY = max(y, highestY)
		lowestY = min(y, lowestY)
	
	var width = highestX - lowestX;
	var height = highestY - lowestY;
	
	partBounds = Vector2i(width, height);
	
	return partBounds;


func _process(delta):
	if (inventoryNode is InventoryPlayer):
		textureBase.show();
		if inPlayerInventory:
			if ownedByPlayer:
				textureBase.global_position = invHolderNode.global_position + Vector2(invPosition * 48);
			else:
				textureBase.global_position = invHolderNode.global_position;
	else:
		textureBase.hide();
		%Buttons.disable();

func _on_buttons_on_select(foo:bool):
	selected = foo;
	inventoryNode.select_part(self, foo);
	pass # Replace with function body.

func select(foo:bool):
	_on_buttons_on_select(foo);
	%Buttons.set_pressed(foo);
	move_mode(false);

func move_mode(enable:bool):
	%Buttons.move_mode_enable(enable);

func destroy():
	select(false);
	queue_free();

func disable(_disabled:=true):
	%Buttons.disable(_disabled);

#######

##Fired at the start of a round.
func new_round():
	pass

##Fired at the end of a round.
func end_round():
	pass

##Fired when the player takes damage.
func take_damage(damage:float):
	pass

##Fired when this part is sold.
func on_sold():
	pass;

##Fired when this part is bought.
func on_bought():
	pass;
