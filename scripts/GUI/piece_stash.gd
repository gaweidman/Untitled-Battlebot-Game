extends Control

class_name PieceStash

enum modes {
	NONE,
	PIECES,
	PARTS,
	ALL,
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
	if mode == modes.PIECES or mode == modes.ALL:
		var stash = robotToReference.get_stash_pieces();
		for item in stash:
			spawn_button(item);
	if mode == modes.PARTS or mode == modes.ALL:
		var stash = robotToReference.get_stash_parts();
		for item in stash:
			spawn_button(item);
	pass;

func spawn_button(thing : Variant):
	if thing is Piece:
		spawn_piece_button(thing);
	if thing is Part:
		spawn_part_button(thing);

func spawn_piece_button(tiedPiece : Piece):
	var newButton = stashButtonScene.instantiate();
	newButton.load_piece_data(tiedPiece, self);
	buttonsHolder.add_child(newButton);

func spawn_part_button(tiedPart : Part):
	var newButton = stashButtonScene.instantiate();
	newButton.load_part_data(tiedPart, self);
	buttonsHolder.add_child(newButton);

func piece_button_pressed(tiedPiece : Piece):
	pieceButtonClicked.emit(tiedPiece);

func part_button_pressed(tiedPart : Part):
	partButtonClicked.emit(tiedPart);

signal pieceButtonClicked(tiedPiece : Piece);
signal partButtonClicked(tiedPart : Part);
