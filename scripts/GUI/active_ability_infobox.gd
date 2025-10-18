extends Control

class_name AbilityInfobox

@export_subgroup("Outlines")
@export var outlineDisabled := preload("res://graphics/images/HUD/buttonGFX/digitalOutline_disabled.png");
@export var outlineNotEquipped := preload("res://graphics/images/HUD/buttonGFX/digitalOutline_normal.png");
@export var outlineHover := preload("res://graphics/images/HUD/buttonGFX/digitalOutline_hover.png");
@export var outlineSelected := preload("res://graphics/images/HUD/buttonGFX/digitalOutline_selected.png");
@export var outlineEquipped := preload("res://graphics/images/HUD/buttonGFX/digitalOutline_equipped.png");
@export var outlineEquippedAndSelected := preload("res://graphics/images/HUD/buttonGFX/digitalOutline_equippedAndSelected.png");
@export var outlineEquippedAndDisabled := preload("res://graphics/images/HUD/buttonGFX/digitalOutline_equippedAndDisabled.png");

@export var outlineBox : NinePatchRect;

func update_outline():
	pass;

var isPassive : bool;

@export_subgroup("Node refs")
@export var lbl_name : Label;
@export var rlbl_desc : RichTextLabel;

func populate_with_ability(ability:AbilityManager):
	if !is_instance_valid(ability): queue_free(); return;
	isPassive = ability.isPassive;
	var bot = ability.assignedRobot;
	var thing = ability.get_assigned_piece_or_part();
	var statsUsed = ability.statsUsed;
	
	if !isPassive:
		## Any of the reassignment stuff should go here.
		pass;
	
	lbl_name.text = ability.abilityName;
	rlbl_desc.text = ability.abilityDescription;
	
	if thing is Part:
		for stat in statsUsed:
			pass;
	if thing is Piece:
		pass;
	
	resize_box();
	pass;

func resize_box():
	var v = 0;
	for child in Utils.get_all_children(outlineBox):
		v = max(child.global_position.y + child.size.y, v);
	v -= outlineBox.global_position.y;
	outlineBox.custom_minimum_size.y = v;
