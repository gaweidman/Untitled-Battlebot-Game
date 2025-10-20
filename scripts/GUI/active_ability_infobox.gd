extends Control

class_name AbilityInfobox

@export_subgroup("Outlines")
@export var outlineDisabled := "res://graphics/images/HUD/buttonGFX/digitalOutline_disabled.png";
@export var outlineEquippedAndDisabled := "res://graphics/images/HUD/buttonGFX/digitalOutline_equippedAndDisabled.png";
@export var outlineDisabled_Selected := "res://graphics/images/HUD/buttonGFX/digitalOutline_disabledAndSelected.png";

@export var outlineNotEquipped := "res://graphics/images/HUD/buttonGFX/digitalOutline_normal.png";
@export var outlineHover := "res://graphics/images/HUD/buttonGFX/digitalOutline_hover.png";
@export var outlineHoverAndDisabled := "res://graphics/images/HUD/buttonGFX/digitalOutline_hoverAndDisabled.png";
@export var outlineNotEquipped_Selected := "res://graphics/images/HUD/buttonGFX/digitalOutline_selected.png";
@export var outlineEquipped := "res://graphics/images/HUD/buttonGFX/digitalOutline_equipped.png";
@export var outlineEquipped_Selected := "res://graphics/images/HUD/buttonGFX/digitalOutline_equippedAndSelected.png";

@export_subgroup("Node refs")
@export var lbl_name : Label;
@export var rlbl_desc : RichTextLabel;
@export var outlineBox : NinePatchRect;
@export var statHolder : HFlowContainer;
@export var assignButton : Button;
@export var separatorName : TextureRect;
@export var separatorStats : TextureRect;

func _ready():
	hide();

func update_outline():
	var img = outlineNotEquipped;
	if disabled:
		if equipped:
			if selected:
				img = outlineDisabled_Selected;
			else:
				img = outlineEquippedAndDisabled;
		else:
			if selected:
				img = outlineDisabled_Selected;
			else:
				if hovering or focused:
					img = outlineHoverAndDisabled;
				else:
					img = outlineDisabled;
	else:
		if equipped:
			if selected:
				img = outlineDisabled_Selected;
			else:
				img = outlineEquippedAndDisabled;
		else:
			if selected:
				img = outlineNotEquipped_Selected;
			else:
				if hovering or focused:
					img = outlineHover;
				else:
					img = outlineNotEquipped;
	if FileAccess.file_exists(img):
		outlineBox.texture = load(img);
	else:
		print(img, "does not exist dummy")
	
	if isPassive:
		if disabled:
			assignButton.text = "ENABLE"
		else:
			assignButton.text = "DISABLE"
	else:
		assignButton.text = "ASSIGN"
	pass;

var referencedAbility : AbilityManager;
var isPassive : bool;
var selected := false;
var disabled := false;
var equipped := false;
var bot : Robot;

var referencedThing : Node;
var statsUsed : Array = [];

func update_ability_stats():
	isPassive = referencedAbility.isPassive;
	disabled = referencedAbility.disabled;
	var assignedBot = referencedAbility.assignedRobot;
	referencedThing = referencedAbility.get_assigned_piece_or_part();
	if referencedThing is Piece:
		var _bot = referencedThing.get_host_robot();
		if is_instance_valid(_bot):
			bot = referencedThing.get_host_robot();
	if referencedThing is Part:
		bot = referencedThing.thisBot;
	equipped = assignedBot != null;
	statsUsed = referencedAbility.statsUsed;
	
	update_outline();
@export var statIcon := preload("res://scenes/prefabs/objects/gui/stat_icon.tscn");
func populate_stats():
	for child in statHolder.get_children():
		child.queue_free();
	
	if referencedThing is Piece:
		##Make a dummy stat.
		var energyStat = StatTracker.new();
		energyStat.statIcon = load("res://graphics/images/HUD/statIcons/energyIconStriped.png");
		energyStat.baseStat  = referencedAbility.get_energy_cost();
		energyStat.set_stat(referencedAbility.get_energy_cost());
		if isPassive:
			energyStat.statFriendlyName = "Passive Energy Draw";
		else:
			energyStat.statFriendlyName = "Active Energy Draw";
		add_stat_icon(energyStat)
		
		for statName in statsUsed:
			var stat = referencedThing.get_stat_resource(statName);
			add_stat_icon(stat);

func add_stat_icon(stat:StatTracker):
	var newIcon : InspectorStatIcon = statIcon.instantiate();
	newIcon.load_data_from_statTracker(stat);
	statHolder.add_child(newIcon);

func populate_with_ability(ability:AbilityManager):
	if !is_instance_valid(ability): queue_free(); return;
	referencedAbility = ability;
	referencedAbility.currentAbilityInfobox = self;
	update_ability_stats();
	populate_stats();
	
	var nametxt = "";
	if isPassive:
		nametxt += "Passive: "
	else:
		nametxt += "Active: "
	nametxt += referencedAbility.abilityName
	lbl_name.text = nametxt;
	rlbl_desc.text = referencedAbility.abilityDescription;
	
	if referencedThing is Part:
		for stat in statsUsed:
			pass;
	if referencedThing is Piece:
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
	
	var marginBoxHeight = v + get("theme_override_constants/margin_bottom") + get("theme_override_constants/margin_top");
	size.y = marginBoxHeight;
	custom_minimum_size.y = marginBoxHeight;

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

var hovering := false;
func _on_mouse_entered():
	hovering = true;
	pass # Replace with function body.
func _on_mouse_exited():
	hovering = false;
	pass # Replace with function body.

var focused := false;
func _on_focus_entered():
	focused = true;
	pass # Replace with function body.
func _on_focus_exited():
	focused = false;
	pass # Replace with function body.

func _exit_tree():
	if is_instance_valid(referencedAbility):
		referencedAbility.currentAbilityInfobox = null;

## When the assignment button gets pressed, it should either start up the active assignment pipette if it is active, or toggle disabled if it is passive.
func _on_assign_pressed():
	if is_instance_valid(referencedAbility):
		referencedAbility.currentAbilityInfobox = self;
		if isPassive:
			referencedAbility.disable();
			update_ability_stats();
			pass;
		else:
			if is_instance_valid(bot):
				print("ability yeees")
				if selected:
					bot.clear_ability_pipette();
				else:
					bot.set_ability_pipette(referencedAbility);
				pass;
			else:
				print("ability what")
		update_outline();
	pass # Replace with function body.

func select(foo):
	if foo:
		print("ability selecting")
	else:
		print("ability unselecting")
	selected = foo;
