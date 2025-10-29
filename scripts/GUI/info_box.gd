@icon ("res://graphics/images/class_icons/inspector.png")
extends Control

class_name InfoBox

@export var iconBase : TextureRect;
@export var lbl_partName : Label;
@export var rlbl_desc : RichTextLabel;
#@export var rlbl_desc : RichTextLabel;
var partRef : Part;
var pieceRef : Piece;
var data_ready := false;
signal sellPart(part:Part);
signal sellPiece(piece:Piece);

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
	return good;

func get_required_height() -> int:
	return int(max(calculatedHeight, requiredHeight));

var requiredHeight := 272.0;
func calculate_required_height():
	update_ability_height();
	requiredHeight = calculatedHeight;
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
	
	populate_abilities(piece);
	pass;

func clear_info(thingToCheck = null):
	if thingToCheck != get_ref():
		data_ready = false;
		calculatedHeight = 0;
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
		
		clear_abilities();

var ref : Node;
func get_ref():
	if is_instance_valid(partRef): 
		ref = partRef;
		return partRef;
	if is_instance_valid(pieceRef): 
		ref = pieceRef;
		return pieceRef;
	ref = null;
	return null;

@export var btn_sellButton : Control;
@export var lbl_sellButton : Control;
@export var btn_moveButton : Control;
var areYouSure := false;
func _on_sell_button_pressed():
	if get_ref() is Part:
		if areYouSure:
			sellPart.emit(partRef);
			clear_info();
		else:
			areYouSure = true;
			var txt = "SURE? "
			lbl_sellButton.text = txt + TextFunc.format_stat(partRef._get_sell_price(), 0);
	elif get_ref() is Piece:
		if areYouSure:
			sellPiece.emit(pieceRef);
			clear_info();
		else:
			areYouSure = true;
			var txt = "SURE? "
			lbl_sellButton.text = txt + TextFunc.format_stat(pieceRef.get_sell_price(), 0);
	pass # Replace with function body.

##### ABILITIES BOX
@export var abilityInfoboxScene := preload("res://scenes/prefabs/objects/gui/active_ability_infobox.tscn");
@export var abilityScrollContainer : ScrollContainer;
@export var abilityHolder : VBoxContainer;
func populate_abilities(thing):
	clear_abilities();
	var effectiveSize := 0;
	if thing is Piece:
		var abilities = thing.get_all_abilities(true);
		for ability in abilities:
			if is_instance_valid(ability) and ability is AbilityManager:
				var newBox = abilityInfoboxScene.instantiate();
				if newBox is AbilityInfobox:
					newBox.populate_with_ability(ability);
					abilityHolder.add_child(newBox);
					effectiveSize += 1;
	abilityScrollContainer.visible = effectiveSize > 0;
	if abilityScrollContainer.visible:
		set_queue_ability_post_update();
		for child in abilityHolder.get_children():
			child.queue_show();

var queueAbilityPostUpdateCounter = -1;

func set_queue_ability_post_update():
	queueAbilityPostUpdateCounter = 4;
@export var abilityBoxMaxSize := 300;
var spaceBeforeDescription = 32;
var spaceAfterDescription = 2;
var spaceAfterAbilityContainer = 4;
var spaceAfterButton = 4;

var calculatedHeight = 0;
func update_ability_height():
	var v = 0;
	for child in abilityHolder.get_children():
		v += child.size.y;
		print(v)
	abilityScrollContainer.custom_minimum_size.y = min(abilityBoxMaxSize, v + 10)
	abilityScrollContainer.size.y = min(abilityBoxMaxSize, v)
	
	var descHeight = rlbl_desc.get_content_height();
	var abilityPosY = descHeight + spaceAfterDescription + spaceBeforeDescription;
	abilityScrollContainer.position.y = abilityPosY;
	var abilityH = abilityScrollContainer.custom_minimum_size.y;
	if not abilityScrollContainer.visible:
		abilityH = 0;
	var buttonPosY = abilityH + abilityPosY + spaceAfterAbilityContainer
	
	btn_sellButton.position.y = buttonPosY;
	btn_moveButton.position.y = buttonPosY;
	calculatedHeight = btn_sellButton.size.y + btn_sellButton.position.y + spaceAfterButton;
	pass;

func _physics_process(delta):
	if queueAbilityPostUpdateCounter == 1:
		data_ready = true;
		pass;
	if queueAbilityPostUpdateCounter == 2:
		calculate_required_height();
		pass;
	if queueAbilityPostUpdateCounter == 3:
		#queueAbilityPostUpdate2 = false;
		#queueAbilityPostUpdate3 = true;
		pass;
	if queueAbilityPostUpdateCounter == 4:
		#queueAbilityPostUpdate1 = false;
		pass;
	
	if queueAbilityPostUpdateCounter >= 0:
		queueAbilityPostUpdateCounter -= 1;
	pass;

func clear_abilities():
	##Clear out the abilities.
	for ability in abilityHolder.get_children():
		ability.queue_free();
