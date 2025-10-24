@icon ("res://graphics/images/class_icons/energy_white.png")
extends Resource

class_name AbilityManager

@export var abilityName : String = "Active Ability";
@export var abilityDescriptionConstructor : Array[RichTextConstructor] = [];
@export_multiline var abilityDescription : String = "No Description Found.";
@export var energyCost : float = 0.0;
@export var cooldownTimeBase : float = 0.0;
##If you want to have the cooldown use a stat from within the host piece for its timer, put it here. Otherwise, leave it blank.
@export var cooldownStatName : String; 
@export var runType : runTypes = runTypes.Default; ## How this gets called. [br]Default makes the ability perform manually or on a loop, for Active and Passive abilities respectively.[br]Manual is the default for all Active abilities; You must fire it manually with the press of a button.[br]LoopingCooldown is the default for all Passive abilities; it runs automatically based on its [member cooldownTimeBase], attempting to restart when it hits 0.[br]OnContactDamage makes this passive go onto cooldown when the Piece it's on deals contact damage. Use this for passives that control how often a passive hitbox interaction is allowed to stay up.
@export var functionNameWhenUsed : StringName;
@export var statsUsed : Array[String] = []; ## Any stats from the host piece you want to be displayed in this ability's inspector box.
@export var icon : Texture2D;
@export_subgroup("Internal bits")
@export var initialized := false;
@export var disabled := false;
@export var functionWhenUsed : Callable;

var cooldownTimer := 0.0;
enum runTypes {
	Default,
	LoopingCooldown,
	OnContactDamage,
	Manual,
}

var assignedRobot : Robot;
var assignedPieceOrPart;

var isPassive := false;

func assign_robot(robot : Robot):
	assignedRobot = robot;

func unassign_robot():
	assignedRobot = null;

func get_assigned_piece_or_part():
	return assignedPieceOrPart;

func register(partOrPiece : Node, _abilityName : String = "Active Ability", _abilityDescription : String = "No Description Found.", _functionWhenUsed : Callable = func(): pass, _statsUsed : Array[String] = [], _passive := false):
	if partOrPiece is PartActive or partOrPiece is Piece:
		assignedPieceOrPart = partOrPiece;
		
		abilityName = _abilityName;
		abilityDescription = _abilityDescription;
		functionWhenUsed = _functionWhenUsed;
		statsUsed = _statsUsed;
		isPassive = _passive;

func assign_references(partOrPiece : Node):
	if partOrPiece is Piece:
		assignedPieceOrPart = partOrPiece;

func construct_description():
	if ! abilityDescriptionConstructor.is_empty():
		abilityDescription = TextFunc.parse_text_constructor_array(abilityDescriptionConstructor);

func call_ability() -> bool:
	if is_instance_valid(assignedPieceOrPart):
		#print("ABILITY ",abilityName," HAS VALID HOST...");
		if assignedPieceOrPart is PartActive:
			return assignedPieceOrPart._activate();
		if assignedPieceOrPart is Piece:
			if is_on_assigned_piece():
				return assignedPieceOrPart.use_active(self);
	return false;

func is_disabled() -> bool:
	return disabled;

func disable(foo:=not is_disabled()):
	disabled = foo;


var currentAbilityInfobox : AbilityInfobox;
var selected := false;
func get_selected()->bool:
	return selected;
func select(foo:= not get_selected()):
	selected = foo;
	
	if is_instance_valid(currentAbilityInfobox):
		currentAbilityInfobox.select(foo);
	else:
		print("Ability infobox? Yello?")
	
	if foo:
		pass;
	else:
		pass;

func deselect():
	select(false);

func get_energy_cost_base(override = null)->float:
	if override is float: 
		if override < 999.0:
			return override;
	return energyCost;
func get_energy_cost():
	if is_instance_valid(get_assigned_piece_or_part()) and get_assigned_piece_or_part() is Piece:
		return assignedPieceOrPart.get_active_energy_cost(self);
	return get_energy_cost_base();

func get_energy_cost_string():
	var s = ""
	s += TextFunc.format_stat(get_energy_cost(), 2);
	if isPassive:
		s += "/s"
	return s

var freezeFrames := 0;
func add_freeze_frames(amt := 1):
	freezeFrames += amt;
var freezeTime := 0.0;
func add_freeze_time(amt := 1.0):
	freezeTime += amt;
func tick_cooldown(delta):
	if freezeFrames > 0:
		freezeFrames -= 1;
	else:
		if freezeTime > 0:
			freezeTime -= delta;
		else:
			if freezeTime < 0: ## Add negative freezeTime to delta as compensation for rollover.
				delta -= freezeTime;
				freezeTime = 0;
			cooldownTimer = max(0, cooldownTimer - delta);
func get_cooldown_start_time(multiplier):
	if cooldownStatName != null:
		if is_instance_valid(get_assigned_piece_or_part()):
			if assignedPieceOrPart is Piece:
				if assignedPieceOrPart.has_stat(cooldownStatName):
					cooldownTimeBase = assignedPieceOrPart.get_stat(cooldownStatName);
	return cooldownTimeBase * multiplier;
func queue_cooldown(multiplier):
	set_deferred("cooldownTimer", get_cooldown_start_time(multiplier))
func set_cooldown(multiplier):
	if cooldownTimeBase > 0:
		set("cooldownTimer", get_cooldown_start_time(multiplier))
func get_cooldown()->float:
	if is_disabled():
		return get_cooldown_start_time(1.0);
	if cooldownTimer < 0:
		cooldownTimer = 0;
	return cooldownTimer;
func on_cooldown()->bool:
	return cooldownTimer > 0 or freezeTime > 0 or freezeFrames > 0;

func get_ability_slot_data():
	if not is_equipped():
		return false;
	var data = {};
	if is_instance_valid(get_assigned_piece_or_part()) and get_assigned_piece_or_part() is Piece:
		data = assignedPieceOrPart.get_ability_slot_data(self);
	
	if not ("incomingPower" in data.keys()):
		data["incomingPower"] = 0.0;
	if not ("usable" in data.keys()):
		data["usable"] = false;
	data["requiredEnergy"] = get_energy_cost();
	
	data["cooldownTime"] = get_cooldown();
	data["cooldownStartTime"] = get_cooldown_start_time(1.0);
	data["onCooldown"] = on_cooldown();
	return data;


func is_equipped() -> bool:
	return true;
	pass;

func is_on_piece() -> bool:
	return is_instance_valid(get_assigned_piece_or_part()) and get_assigned_piece_or_part() is Piece;

func is_on_assigned_piece() -> bool:
	return is_on_piece() and is_instance_valid(get_assigned_piece_or_part()) and get_assigned_piece_or_part().assignedToSocket;
