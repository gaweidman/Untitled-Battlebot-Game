extends Control

class_name MakerModeManager

enum mode {
	NONE,
	PIECE,
	ROBOT,
	PART,
	LEVEL,
}

func _ready():
	change_mode(0);

@export var SelectionButtons : Control;
@export var PieceHelper : Control;
@export var RobotHelper : Control;

@export var lbl_modeName : Label;

@onready var modeNodes : Dictionary[mode, Control]= {
	mode.NONE : SelectionButtons,
	mode.PIECE : PieceHelper,
	mode.ROBOT : RobotHelper,
	mode.PART : null,
	mode.LEVEL : null,
}
@onready var modeNames : Dictionary[mode, String] = {
	mode.NONE : "Select A Mode",
	mode.PIECE : "Now Making: Pieces",
	mode.ROBOT : "Now Making: Robots",
	mode.PART : "Now Making: Parts",
	mode.LEVEL : "Now Making: Levels",
}

func change_mode(newMode : mode):
	for modeNode in modeNodes.values():
		if is_instance_valid(modeNode):
			if modeNode.visible:
				
				modeNode.hide();
				if modeNode is MakerMode:
					modeNode.exit();
	
	if is_instance_valid(modeNodes[newMode]):
		var modeNode = modeNodes[newMode]
		modeNode.show();
		if modeNode is MakerMode:
			modeNode.enter();
		lbl_modeName.text = modeNames[newMode];
	else:
		var modeNode = modeNodes[mode.NONE]
		modeNode.show();
		lbl_modeName.text = modeNames[mode.NONE];

func _on_exit_pressed():
	get_tree().quit();
	pass # Replace with function body.


func _on_mouse_entered():
	enable_camera();
	pass # Replace with function body.


func _on_mouse_exited():
	disable_camera();
	pass # Replace with function body.

@export var makerCamera : MakerCamera;
var cameraControlIsOn = true;
func is_camera_control_on():
	cameraControlIsOn = makerCamera.enabled;
	return cameraControlIsOn;
func enable_camera():
	makerCamera.enable();
func disable_camera():
	makerCamera.disable();


func _on_back_to_game_pressed():
	GameState.reset_to_main_menu();
	pass # Replace with function body.





@onready var newPieceRef = preload("res://scenes/prefabs/objects/pieces/buildingBlocks/piece.tscn")
@onready var newRobotRef = preload("res://scenes/prefabs/objects/robots/buildingBlocks/robot_base.tscn")

var filepathPrefixPieces = "res://scenes/prefabs/objects/pieces/"
var filepathPrefixRobots = "res://scenes/prefabs/objects/robots/"
