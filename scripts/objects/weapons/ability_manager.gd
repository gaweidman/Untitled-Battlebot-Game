extends Resource

class_name AbilityManager

var abilityName : String = "Active Ability";
var abilityDescription : String = "No Description Found.";
var statsUsed : Array[String] = [];
var functionWhenUsed : Callable = func(): pass;

var assignedRobot : Robot;
var assignedPieceOrPart;
var assignedActionSlot;

func assign_robot(robot : Robot):
	assignedRobot = robot;

func unassign_robot():
	assignedRobot = null;

func get_assigned_piece_or_part():
	return assignedPieceOrPart;

func get_assigned_action_slot():
	return assignedActionSlot;

func register(partOrPiece : Node, actionSlot : int, _abilityName : String = "Active Ability", _abilityDescription : String = "No Description Found.", _functionWhenUsed : Callable = func(): pass, _statsUsed : Array[String] = []):
	if partOrPiece is PartActive or partOrPiece is Piece:
		assignedPieceOrPart = partOrPiece;
		assignedActionSlot = actionSlot;
		
		abilityName = _abilityName;
		abilityDescription = _abilityDescription;
		functionWhenUsed = _functionWhenUsed;
		statsUsed = _statsUsed;

func call_ability() -> bool:
	if is_instance_valid(assignedPieceOrPart):
		if assignedPieceOrPart is PartActive:
			return assignedPieceOrPart._activate();
		if assignedPieceOrPart is Piece:
			return assignedPieceOrPart.use_active(assignedActionSlot);
	return false;
