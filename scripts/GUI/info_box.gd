extends Control

class_name InfoBox

@export var iconBase : TextureRect;
@export var lbl_partName : Label;
@export var rlbl_desc : RichTextLabel;
#@export var rlbl_desc : RichTextLabel;
var partRef : Part;
var pieceRef : Piece;
signal sellPart(part:Part);

var icon_blank := preload("res://graphics/images/HUD/infobox/typeIcons/info_blank.png");
var icon_utility := preload("res://graphics/images/HUD/infobox/typeIcons/info_utility.png");
var icon_melee := preload("res://graphics/images/HUD/infobox/typeIcons/info_melee.png");
var icon_ranged := preload("res://graphics/images/HUD/infobox/typeIcons/info_ranged.png");
var icon_passive := preload("res://graphics/images/HUD/infobox/typeIcons/info_passive.png");
var icon_scrap := preload("res://graphics/images/HUD/infobox/typeIcons/info_scrap.png");
var icon_warning := preload("res://graphics/images/HUD/infobox/typeIcons/info_warning.png");
var icon_error := preload("res://graphics/images/HUD/infobox/typeIcons/info_error.png");
var icon_piece := preload("res://graphics/images/HUD/infobox/typeIcons/info_piece.png");
var icon_piece_unequipped := preload("res://graphics/images/HUD/infobox/typeIcons/info_piece_unequipped.png");
var icon_part := preload("res://graphics/images/HUD/infobox/typeIcons/info_part.png");
var icon_part_unequipped := preload("res://graphics/images/HUD/infobox/typeIcons/info_part_unequipped.png");

func _ready():
	clear_info();

func populate_info(thing):
	clear_info(thing);
	var good = false;
	if is_instance_valid(thing):
		if thing is Part:
			populate_info_part(thing);
			good = true;
		if thing is Piece:
			populate_info_piece(thing);
			good = true;
	calculate_required_height();
	return good;

func get_required_height() -> int:
	return int(requiredHeight);

var requiredHeight := 272.0;
func calculate_required_height():
	var h = size.y;
	for child in get_children():
		var y = child.position.y;
		h = maxi(h, y + child.size.y);
	requiredHeight = h;
	return requiredHeight;

func populate_info_part(part:Part):
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
		iconBase.texture = load("res://graphics/images/HUD/infobox/info_utility.png");
		
	elif part._get_part_type() == Part.partTypes.MELEE:
		$EnergyIcon/Label.text = TextFunc.format_stat(part.get_energy_cost(true));
		$EnergyIcon.show();
		$CooldownIcon/Label.text = TextFunc.format_stat(part.get_fire_rate(true));
		$CooldownIcon.show();
		
		iconBase.texture = load("res://graphics/images/HUD/infobox/info_melee.png");
		$DamageIcon/Label.text = TextFunc.format_stat(part.get_damage(true));
		$DamageIcon.show();
		
	elif part._get_part_type() == Part.partTypes.RANGED:
		$EnergyIcon/Label.text = TextFunc.format_stat(part.get_energy_cost(true));
		$EnergyIcon.show();
		$CooldownIcon/Label.text = TextFunc.format_stat(part.get_fire_rate(true));
		$CooldownIcon.show();
		
		iconBase.texture = load("res://graphics/images/HUD/infobox/info_ranged.png");
		$DamageIcon/Label.text = TextFunc.format_stat(part.get_damage(true));
		$DamageIcon.show();
		$MagazineIcon/Label.text = TextFunc.format_stat(part.get_magazine_size(true), 0);
		$MagazineIcon.show();
		
	elif part._get_part_type() == Part.partTypes.PASSIVE:
		iconBase.texture = load("res://graphics/images/HUD/infobox/info_passive.png");

func populate_info_piece(piece:Piece):
	pieceRef = piece;
	lbl_partName.text = piece.pieceName;
	rlbl_desc.text = piece.pieceDescription;
	if piece.is_equipped():
		iconBase.texture = icon_piece;
	else:
		iconBase.texture = icon_piece_unequipped;
	pass;

func clear_info(thingToCheck = null):
	if thingToCheck != get_ref():
		partRef = null;
		lbl_partName.text = "Nothing Selected";
		iconBase.texture = icon_blank;
		#$DamageIcon.hide();
		#$CooldownIcon.hide();
		#$EnergyIcon.hide();
		#$MagazineIcon.hide();
		#$SellButton/Label.hide();
		#$SellButton.disabled = true;
		#$MoveButton.button_pressed = false;
		#$MoveButton.disabled = true;
		#rlbl_desc.text = "[color=e0dede]No [color=ffffff]Description [color=e0dede]Found.";
		rlbl_desc.text = "[color=e0dede]Closing...";
		var col = TextFunc.get_color("lightred")
		print_rich("[color="+str(col.to_html())+"]test")
		areYouSure = false;

func get_ref():
	if is_instance_valid(partRef): return partRef;
	if is_instance_valid(pieceRef): return pieceRef;
	return null;

@export var sellButton : Button;
var areYouSure := false;
func _on_sell_button_pressed():
	if areYouSure:
		sellPart.emit(partRef);
		clear_info();
	else:
		areYouSure = true;
		$SellButton/Label.text = "SURE? "+ TextFunc.format_stat(partRef._get_sell_price(), 0);
	pass # Replace with function body.

func populate_abilities(thing):
	if thing is Piece:
		var abilities = thing.activeAbilities;

## Gets connected to when an AbilityInfobox gets made during the PopulateAbilities function.
func _on_ability_assignment_button_pressed(ability:AbilityManager):
	pass;
