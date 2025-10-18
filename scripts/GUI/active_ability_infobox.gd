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


func update_outline():
	pass;

var isPassive : bool;

@export_subgroup("Node refs")
@export var lbl_name : Label;
@export var rlbl_desc : RichTextLabel;
@export var outlineBox : NinePatchRect;
@export var statHolder : HFlowContainer;
@export var assignButton : Button;
@export var separatorName : TextureRect;
@export var separatorStats : TextureRect;

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
	pass;

var v_margin = 4;
var h_margin = 4;
var spaceBetweenNameAndSeparator1 = 2;
var spaceBetweenNameAndDescription = 8;
var spaceBetweenDescriptionAndStats = 8;
var separator2DistBeforeStats = 6;
var spaceAfter = 12;
func resize_box():
	var v = 0;
	lbl_name.position.y = v_margin;
	v += lbl_name.position.y;
	v += lbl_name.size.y;
	separatorName.position.y = v + spaceBetweenNameAndSeparator1;
	separatorName.custom_minimum_size = Vector2(size.x - h_margin * 2, 3);
	v += spaceBetweenNameAndDescription;
	rlbl_desc.position.y = v;
	var height = rlbl_desc.get_content_height();
	v += height;
	v += spaceBetweenDescriptionAndStats;
	#statHolder.position.y = v;
	separatorStats.position.y = v - separator2DistBeforeStats;
	separatorStats.custom_minimum_size = Vector2(size.x - h_margin * 2, 3);
	v += statHolder.size.y;
	v += v_margin;
	outlineBox.custom_minimum_size.y = v;
	##v -= outlineBox.global_position.y;
	#v += max(statHolder.size.y, assignButton.size.y, 50.0);
	#v += lbl_name.size.y;
	#v += rlbl_desc.get_line_count() * 16;
	#v += statHolder.size.y;
	#outlineBox.custom_minimum_size.y = v;
	#outlineBox.size.y = v;
	#v += 8;
	#custom_minimum_size.y = v;
	#size.y = v;

var queueShow = false;
func queue_show():
	set_deferred("queueShow", true);
signal doneWithSetup;
func _process(delta):
	if queueShow:
		showtime();
		queueShow = false;
		doneWithSetup.emit();

func showtime():
	resize_box();
	update_outline();
	call_deferred("show");
