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
	if part.ownedByPlayer:
		$MoveButton.disabled = false;
		$SellButton/Label.text = "SELL: "+ str(part._get_sell_price());
		$SellButton/Label.show();
		$SellButton.disabled = false;
	$Description.text = part.partDescription;
	if part is PartActive:
		$EnergyIcon/Label.text = str(part.get_energy_cost(true));
		$EnergyIcon.show();
		$CooldownIcon/Label.text = str(part.get_fire_rate(true));
		$CooldownIcon.show();
		if part is PartActiveProjectile:
			iconBase.texture = load("res://graphics/images/HUD/info_ranged.png");
			$DamageIcon/Label.text = str(part.get_damage(true));
			$DamageIcon.show();
			$MagazineIcon/Label.text = str(part.get_magazine_size(true));
			$MagazineIcon.show();
		elif part is PartActiveMelee:
			iconBase.texture = load("res://graphics/images/HUD/info_melee.png");
			$DamageIcon/Label.text = str(part.get_damage(true));
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
	$MagazineIcon.hide();
	$SellButton/Label.hide();
	$SellButton.disabled = true;
	$MoveButton.button_pressed = false;
	$MoveButton.disabled = true;
	$Description.text = "[color=e0dede]No [color=ffffff]description [color=e0dede]given.";
	areYouSure = false;

var areYouSure := false;
func _on_sell_button_pressed():
	if areYouSure:
		sellPart.emit(partRef);
		clear_info();
	else:
		areYouSure = true;
		$SellButton/Label.text = "SURE? "+ str(partRef._get_sell_price());
	pass # Replace with function body.
