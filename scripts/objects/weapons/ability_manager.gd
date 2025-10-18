extends Resource

class_name AbilityManager

@export var abilityName : String = "Active Ability";
@export_multiline var abilityDescription : String = "No Description Found.";
@export var abilityDescriptionConstructor : Array[RichTextConstructor] = [];
@export var statsUsed : Array[String] = []; 
@export var icon : Texture2D;
var initialized := false;
var disabled := false;
@export var functionNameWhenUsed : StringName;
var functionWhenUsed : Callable;

var assignedRobot : Robot;
var assignedPieceOrPart;
var assignedActionSlot;

var isPassive := false;

func assign_robot(robot : Robot):
	assignedRobot = robot;

func unassign_robot():
	assignedRobot = null;

func get_assigned_piece_or_part():
	return assignedPieceOrPart;

func get_assigned_action_slot():
	return assignedActionSlot;

func register(partOrPiece : Node, actionSlot : int, _abilityName : String = "Active Ability", _abilityDescription : String = "No Description Found.", _functionWhenUsed : Callable = func(): pass, _statsUsed : Array[String] = [], _passive := false):
	if partOrPiece is PartActive or partOrPiece is Piece:
		assignedPieceOrPart = partOrPiece;
		assignedActionSlot = actionSlot;
		
		abilityName = _abilityName;
		abilityDescription = _abilityDescription;
		functionWhenUsed = _functionWhenUsed;
		statsUsed = _statsUsed;
		isPassive = _passive;

func assign_references(partOrPiece : Node):
	if partOrPiece is Piece:
		assignedPieceOrPart = partOrPiece;
		assignedActionSlot = assignedPieceOrPart.get_next_available_ability_slot();

func construct_description():
	if ! abilityDescriptionConstructor.is_empty():
		abilityDescription = TextFunc.parse_text_constructor_array(abilityDescriptionConstructor);

func call_ability() -> bool:
	if is_instance_valid(assignedPieceOrPart):
		if assignedPieceOrPart is PartActive:
			return assignedPieceOrPart._activate();
		if assignedPieceOrPart is Piece:
			return assignedPieceOrPart.use_active(assignedActionSlot);
	return false;

func is_disabled() -> bool:
	return disabled;

func disable(foo:=not is_disabled()):
	disabled = foo;

#signal fireAbility
func fire_ability_from_host_by_name():
	#fireAbility.emit();
	print("AAAAAAAAAAAAAAAAAA: ")
	if assignedPieceOrPart.has_method(functionNameWhenUsed):
		print("INIT ABILITY: ", get(functionNameWhenUsed))
		#ability.functionWhenUsed = Callable(ability, "fire_ability_signal");
		#get(functionNameWhenUsed).call();
	else:
		prints("method", functionNameWhenUsed, "not found in", assignedPieceOrPart)

func use_ability():
	if ! functionWhenUsed is Callable:
		fire_ability_from_host_by_name();
	else:
		var call = functionWhenUsed;
		call.call();
	pass;
