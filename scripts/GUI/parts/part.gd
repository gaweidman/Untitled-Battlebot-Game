extends Control

class_name Part

@export var dimensions : Array[Vector2i];
var invPosition : Vector2i;
@export var invSprite : CompressedTexture2D;
var scrapCost : int;
@export var inventoryNode : Inventory;
var partBounds : Vector2i;
var inPlayerInventory := false;
var thisBot : Combatant;

#func _init():

func _ready():
	dimensions = [Vector2i(0,0), Vector2i(0,1), Vector2i(1,0), Vector2i(1,1)]
	
	var PB = _get_part_bounds();
	
	$TextureRect.set_deferred("texture", invSprite);

	_populate_buttons();

func _get_sell_price(_discount := 0.0):
	var discount = 1.0 + _discount
	
	var sellPrice = discount * scrapCost
	
	return roundi(sellPrice)

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
		
		button.set_deferred("position", index * 32);
		button.set_deferred("size", Vector2i(32, 32));
		#print(button.disabled)

func _process(delta):
	if not inPlayerInventory:
		$TextureRect.hide();
