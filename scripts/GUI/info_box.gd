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
		$SellButton/Label.text = "SELL: "+ TextFunc.format_stat(part._get_sell_price(), 0);
		$SellButton/Label.show();
		$SellButton.disabled = false;
	$Description.text = part.partDescription;
	
	if part._get_part_type() == Part.partTypes.UTILITY:
		$EnergyIcon/Label.text = TextFunc.format_stat(part.get_energy_cost(true));
		$EnergyIcon.show();
		$CooldownIcon/Label.text = TextFunc.format_stat(part.get_fire_rate(true));
		$CooldownIcon.show();
		iconBase.texture = load("res://graphics/images/HUD/info_utility.png");
		
	elif part._get_part_type() == Part.partTypes.MELEE:
		$EnergyIcon/Label.text = TextFunc.format_stat(part.get_energy_cost(true));
		$EnergyIcon.show();
		$CooldownIcon/Label.text = TextFunc.format_stat(part.get_fire_rate(true));
		$CooldownIcon.show();
		
		iconBase.texture = load("res://graphics/images/HUD/info_melee.png");
		$DamageIcon/Label.text = TextFunc.format_stat(part.get_damage(true));
		$DamageIcon.show();
		
	elif part._get_part_type() == Part.partTypes.RANGED:
		$EnergyIcon/Label.text = TextFunc.format_stat(part.get_energy_cost(true));
		$EnergyIcon.show();
		$CooldownIcon/Label.text = TextFunc.format_stat(part.get_fire_rate(true));
		$CooldownIcon.show();
		
		iconBase.texture = load("res://graphics/images/HUD/info_ranged.png");
		$DamageIcon/Label.text = TextFunc.format_stat(part.get_damage(true));
		$DamageIcon.show();
		$MagazineIcon/Label.text = TextFunc.format_stat(part.get_magazine_size(true), 0);
		$MagazineIcon.show();
		
	elif part._get_part_type() == Part.partTypes.PASSIVE:
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
		$SellButton/Label.text = "SURE? "+ TextFunc.format_stat(partRef._get_sell_price(), 0);
	pass # Replace with function body.
