extends Control

class_name Part

@export var partName := "Part";
@export var partDescription := "No description given.";
@export var dimensions : Array[Vector2i];
var invPosition : Vector2i;
@export var invSprite : CompressedTexture2D;
var scrapCost : int;
@export var inventoryNode : Inventory;
var partBounds : Vector2i;
var inPlayerInventory := false;
var thisBot : Combatant;
var textureBase : NinePatchRect;
var textureScrews : NinePatchRect;

var selected := false;

#func _init():

func _ready():
	dimensions = [Vector2i(0,0), Vector2i(0,1), Vector2i(1,0), Vector2i(1,1)]
	
	var PB = _get_part_bounds();
	textureBase = $TextureBase;
	textureScrews = $TextureBase/Screws;
	textureBase.set_deferred("texture", invSprite);
	textureBase.set_deferred("size", PB * 48);
	textureScrews.set_deferred("size", PB * 48);
	textureBase.set_deferred("patch_margin_left", 13);
	textureBase.set_deferred("patch_margin_right", 13);
	textureBase.set_deferred("patch_margin_top", 13);
	textureBase.set_deferred("patch_margin_bottom", 13);

	_populate_buttons();

func _get_sell_price(_discount := 0.0):
	var discount = 1.0 + _discount
	
	var sellPrice = discount * scrapCost
	
	return roundi(max(1, sellPrice))

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
			textureBase.position = inventoryNode.HUD_engine.global_position + Vector2(invPosition * 48);
	else:
		%Buttons.disable();
	pass


func _on_buttons_on_select(foo):
	selected = foo;
	inventoryNode.select_part(self, foo);
	pass # Replace with function body.

func select(foo):
	_on_buttons_on_select(foo);
	%Buttons.set_pressed(foo);

func destroy():
	select(false);
	queue_free();
