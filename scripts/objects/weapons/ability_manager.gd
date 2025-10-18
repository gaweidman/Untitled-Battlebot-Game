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
