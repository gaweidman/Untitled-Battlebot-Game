extends Control

class_name Part

var invPosition := Vector2i(-9,-9);
var partBounds : Vector2i;
var inPlayerInventory := false;
var ownedByPlayer := false;
var invHolderNode : Control;
var thisBot : Combatant;
var textureBase : NinePatchRect;
var textureScrews : NinePatchRect;
var textureIcon : TextureRect;

var selected := false;

@export_category("Gameplay")
@export var scrapCostBase : int;
var scrapSellModifier := 1.0;
var scrapSellModifierBase := (2.0/3.0);
@export var inventoryNode : Inventory;
@export var dimensions : Array[Vector2i];

@export_category("Vanity")
@export var partName := "Part";
@export_multiline var partDescription := "No description given.";
@export var partIcon : CompressedTexture2D;
@export var invSprite : CompressedTexture2D;
@export var screwSprite : CompressedTexture2D;

@export var myPartType := partTypes.UNASSIGNED;
enum partTypes {
	PASSIVE,
	MELEE,
	RANGED,
	UTILITY,
	UNASSIGNED,
}

func _ready():
	#dimensions = [Vector2i(0,0), Vector2i(0,1), Vector2i(1,0), Vector2i(1,1)]
	if dimensions == null:
		dimensions = [Vector2i(0,0)]
	
	var PB = _get_part_bounds();
	textureBase = $TextureBase;
	
	textureBase.set_deferred("texture", invSprite);
	textureBase.set_deferred("size", PB * 48);
	textureBase.set_deferred("patch_margin_left", 13);
	textureBase.set_deferred("patch_margin_right", 13);
	textureBase.set_deferred("patch_margin_top", 13);
	textureBase.set_deferred("patch_margin_bottom", 13);
	
	textureScrews = $TextureBase/Screws;
	textureScrews.set_deferred("texture", screwSprite);
	textureScrews.set_deferred("size", PB * 48);
	textureScrews.set_deferred("patch_margin_left", 13);
	textureScrews.set_deferred("patch_margin_right", 13);
	textureScrews.set_deferred("patch_margin_top", 13);
	textureScrews.set_deferred("patch_margin_bottom", 13);
	
	textureIcon = $TextureBase/Icon;
	textureIcon.set_deferred("texture", partIcon);
	textureIcon.set_deferred("position", Vector2i(8,8));

	_populate_buttons();
	
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

func _populate_buttons():
	for index in dimensions:
		var button = %Buttons.buttonPrefab.instantiate();
		%Buttons.add_child(button);
		
		button.part = self;
		button.buttonHolder = %Buttons;
		
		button.set_deferred("position", index * 48);
		button.set_deferred("size", Vector2i(48, 48));
		#print(button.disabled)

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
	pass

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
