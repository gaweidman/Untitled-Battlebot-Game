extends Control

class_name InfoBox

@export var iconBase : TextureRect;
@export var lbl_partName : Label;
var partRef : Part;
signal sellPart(part:Part);

func _ready():
	clear_info();

func populate_info(part:Part):
	partRef = part;
	lbl_partName.text = part.partName;
	$SellButton/Label.text = "SELL: "+ str(part._get_sell_price(0.5));
	$SellButton/Label.show();
	$SellButton.disabled = false;
	$MoveButton.disabled = false;
	if part is PartActive:
		$EnergyIcon/Label.text = str(part.energyCost);
		$EnergyIcon.show();
		$CooldownIcon/Label.text = str(part.fireRate);
		$CooldownIcon.show();
		if part is PartActiveProjectile:
			iconBase.texture = load("res://graphics/images/HUD/info_ranged.png");
			$DamageIcon/Label.text = str(part.damage);
			$DamageIcon.show();
		elif part is PartActiveMelee:
			iconBase.texture = load("res://graphics/images/HUD/info_melee.png");
			$DamageIcon/Label.text = str(part.damage);
			$DamageIcon.show();
		else:
			iconBase.texture = load("res://graphics/images/HUD/info_utility.png");
	else:
		iconBase.texture = load("res://graphics/images/HUD/info_passive.png");

func clear_info():
	partRef = null;
	lbl_partName.text = "No Part Selected";
	iconBase.texture = load("res://graphics/images/HUD/info_blank.png");
	$DamageIcon.hide();
	$CooldownIcon.hide();
	$EnergyIcon.hide();
	$SellButton/Label.hide();
	$SellButton.disabled = true;
	$MoveButton.button_pressed = false;
	$MoveButton.disabled = true;
	areYouSure = false;

var areYouSure := false;
func _on_sell_button_pressed():
	if areYouSure:
		sellPart.emit(partRef);
		clear_info();
	else:
		areYouSure = true;
		$SellButton/Label.text = "SURE? "+ str(partRef._get_sell_price(0.5));
	pass # Replace with function body.
