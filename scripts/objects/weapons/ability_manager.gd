extends Resource

class_name AbilityManager

@export var abilityName : String = "Active Ability";
@export var abilityDescriptionConstructor : Array[RichTextConstructor] = [];
@export_multiline var abilityDescription : String = "No Description Found.";
@export var energyCost : float = 0.0;
@export var cooldownTimeBase : float = 0.0;
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
		print("ABILITY ",abilityName," HAS VALID HOST...");
		if assignedPieceOrPart is PartActive:
			return assignedPieceOrPart._activate();
		if assignedPieceOrPart is Piece:
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

func get_energy_cost_base()->float:
	return energyCost;
func get_energy_cost():
	if assignedPieceOrPart is Piece:
		return assignedPieceOrPart.get_active_energy_cost(self);
	return get_energy_cost_base();

func get_energy_cost_string():
	var s = ""
	s += TextFunc.format_stat(get_energy_cost(), 2);
	if isPassive:
		s += "/s"
	return s

func tick_cooldown(delta):
	cooldownTimer = max(0, cooldownTimer - delta);
func queue_cooldown(multiplier):
	set_deferred("cooldownTimer", cooldownTimeBase * multiplier)
func set_cooldown(multiplier):
	if cooldownTimeBase > 0:
		set("cooldownTimer", cooldownTimeBase * multiplier)
func get_cooldown()->float:
	if cooldownTimer < 0:
		cooldownTimer = 0;
	return cooldownTimer;
func on_cooldown()->bool:
	return cooldownTimer > 0;
