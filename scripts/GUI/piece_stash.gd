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
@export var scrollContainer : ScrollContainer;

func _ready():
	scrollContainer.get_v_scroll_bar().custom_minimum_size.x = 6;
	scrollContainer.get_v_scroll_bar().update_minimum_size();
	btn_Equipped.icon = null; ##TODO: Make icons for this.
	is_robot_being_referenced();
	rotate_equipped_status(); ##Rotates off of NONE.
	rotate_sort(); ##Rotates off of NONE.

func get_current_mode(): return currentMode;

func get_current_robot(): 
	if is_instance_valid(currentRobot):
		disable_sorters(false);
	else:
		disable_sorters(true);
		currentRobot = null;
	return currentRobot;

func regenerate_list(robotToReference : Robot = get_current_robot(), mode : modes = get_current_mode()):
	currentMode = mode;
	for child in buttonsHolder.get_children():
		if child is StashButton:
			child.queue_free();
	if is_robot_being_referenced():
		if mode == modes.PIECES or mode == modes.ALL:
			var stash = robotToReference.get_stash_pieces(get_current_equipped_status());
			for item in stash:
				spawn_button(item);
		if mode == modes.PARTS or mode == modes.ALL:
			var stash = robotToReference.get_stash_parts(get_current_equipped_status());
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

func piece_button_pressed(tiedPiece : Piece, button: StashButton):
	pieceButtonClicked.emit(tiedPiece, button);

func part_button_pressed(tiedPart : Part, button: StashButton):
	partButtonClicked.emit(tiedPart, button);

func _on_sort_by_parts_pressed():
	if is_robot_being_referenced():
		rotate_sort();
	pass # Replace with function body.

func is_robot_being_referenced():
	disable_sorters(not is_instance_valid(get_current_robot()));
	return is_instance_valid(get_current_robot());

@export var btn_sortPieces : Button;

func disable_sorters(_disabled : bool):
	btn_sortPieces.disabled = _disabled;
	btn_Equipped.disabled = _disabled;

enum equippedStatus {
	NONE,
	EQUIPPED,
	NOT_EQUIPPED,
	ALL,
}
var curEquippedStatus := equippedStatus.NONE
func get_current_equipped_status():
	return curEquippedStatus;

@export var btn_Equipped : Button;

func rotate_equipped_status():
	match get_current_equipped_status():
		equippedStatus.NONE:
			curEquippedStatus = equippedStatus.ALL;
			btn_Equipped.icon = null;
			btn_Equipped.text = "Any";
		equippedStatus.ALL:
			curEquippedStatus = equippedStatus.EQUIPPED;
			btn_Equipped.icon = null;
			btn_Equipped.text = "Equipped";
		equippedStatus.EQUIPPED:
			curEquippedStatus = equippedStatus.NOT_EQUIPPED;
			btn_Equipped.icon = null;
			btn_Equipped.text = "Not Equipped";
		equippedStatus.NOT_EQUIPPED:
			curEquippedStatus = equippedStatus.ALL;
			btn_Equipped.icon = null;
			btn_Equipped.text = "Any";
	regenerate_list();

@onready var icon_Piece := preload("res://graphics/images/HUD/statIcons/pieceIconStriped.png");
@onready var icon_Part := preload("res://graphics/images/HUD/statIcons/partIconStriped.png");
@onready var icon_PieceAndPart := preload("res://graphics/images/HUD/statIcons/piecePartIconStriped.png");

func rotate_sort():
	match get_current_mode():
		modes.NONE:
			currentMode = modes.ALL;
			btn_sortPieces.icon = icon_PieceAndPart;
			btn_sortPieces.text = "All";
		modes.ALL:
			currentMode = modes.PIECES;
			btn_sortPieces.icon = icon_Piece;
			btn_sortPieces.text = "Pieces";
		modes.PIECES:
			currentMode = modes.PARTS;
			btn_sortPieces.icon = icon_Part;
			btn_sortPieces.text = "Parts";
		modes.PARTS:
			currentMode = modes.ALL;
			btn_sortPieces.icon = icon_PieceAndPart;
			btn_sortPieces.text = "All";
	regenerate_list();

##Shows only equipped buttons.
func _on_sort_by_equipped_pressed():
	if is_robot_being_referenced():
		rotate_equipped_status();
	pass # Replace with function body.


signal pieceButtonClicked(tiedPiece : Piece, button : StashButton);
signal partButtonClicked(tiedPart : Part, button : StashButton);

func _on_part_button_clicked(tiedPart:Part, button : StashButton):
	if is_instance_valid(currentRobot):
		currentRobot.prepare_pipette(tiedPart);
	pass # Replace with function body.

func _on_piece_button_clicked(tiedPiece:Piece, button : StashButton):
	if is_instance_valid(currentRobot):
		if ! tiedPiece.has_robot_host():
			currentRobot.prepare_pipette(tiedPiece);
		else:
			tiedPiece.select();
	pass # Replace with function body.

func deselect_all_buttons():
	for button in buttonsHolder.get_children():
		button.select(false);
