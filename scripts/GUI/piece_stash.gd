extends Control

class_name PieceStash

enum modes {
	NONE,
	PIECES,
	PARTS,
}
var currentMode := modes.NONE;
var currentRobot : Robot;
@export var buttonsHolder : HFlowContainer;

@export var stashButtonScene : PackedScene;

func get_current_mode(): return currentMode;

func regenerate_list(robotToReference : Robot, mode : modes = get_current_mode()):
	currentMode = mode;
	for child in buttonsHolder.get_children():
		if child is StashButton:
			child.queue_free();
	if mode == modes.PIECES:
		var stash = robotToReference.stashPieces;
		for item in stash:
			spawn_piece_button(item);
	pass;

func spawn_piece_button(tiedPiece : Piece):
	var newButton = stashButtonScene.instantiate();
	newButton.load_piece_data(tiedPiece, self);
	buttonsHolder.add_child(newButton);

func piece_button_pressed(tiedPiece : Piece):
	pieceButtonClicked.emit(tiedPiece);

signal pieceButtonClicked(tiedPiece : Piece);
