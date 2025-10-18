extends Control

class_name AbilityInfobox

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

func populate_with_ability(ability:AbilityManager):
	if !is_instance_valid(ability): queue_free(); return;
	isPassive = ability.isPassive;
	var bot = ability.assignedRobot;
	var thing = ability.get_assigned_piece_or_part();
	var statsUsed = ability.statsUsed;
	
	if !isPassive:
		## Any of the reassignment stuff should go here.
		pass;
	
	if thing is Part:
		for stat in statsUsed:
			pass;
	if thing is Piece:
		pass;
	pass;
