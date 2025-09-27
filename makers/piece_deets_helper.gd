extends Control

#func remake_directory():
	#
## A billion export variables.

@export_category("Engine customizers")
@export var A1 : CheckBox;
@export var A2 : CheckBox;
@export var A3 : CheckBox;
@export var A4 : CheckBox;
@export var A5 : CheckBox;

@export var B1 : CheckBox;
@export var B2 : CheckBox;
@export var B3 : CheckBox;
@export var B4 : CheckBox;
@export var B5 : CheckBox;

@export var C1 : CheckBox;
@export var C2 : CheckBox;
@export var C3 : CheckBox;
@export var C4 : CheckBox;
@export var C5 : CheckBox;

@export var D1 : CheckBox;
@export var D2 : CheckBox;
@export var D3 : CheckBox;
@export var D4 : CheckBox;
@export var D5 : CheckBox;

@export var E1 : CheckBox;
@export var E2 : CheckBox;
@export var E3 : CheckBox;
@export var E4 : CheckBox;
@export var E5 : CheckBox;

@export_category("Node refs")
@export var engine : PartsHolder_Engine;
@export var pieceHolder : Socket;

var pieceSceneBeingInspected : PackedScene;
var pieceBeingInspected : Piece;

func set_inspected_piece(inScene : PackedScene):
	var newPiece = inScene.instantiate();
	if newPiece is Piece:
		clear_inspected_piece();
		
		##Set the new scene and piece.
		pieceSceneBeingInspected = inScene;
		pieceBeingInspected = newPiece;
		
		pieceHolder.add_child(pieceBeingInspected);
		pieceHolder.add_occupant(pieceBeingInspected);
		pieceBeingInspected.force_visibility = true;
		generate_coordinates_from_piece(pieceBeingInspected);
	return pieceBeingInspected;

func reset_inspected_piece():
	set_inspected_piece(pieceSceneBeingInspected);

func clear_inspected_piece():
	##Clear everything out.
	pieceHolder.remove_occupant(true);
	clear_coordinates();
	if is_instance_valid(pieceBeingInspected):
		pieceBeingInspected.queue_free();

func get_pieces():
	$Tree.clear();
	
	var prefix = "res://scenes/prefabs/objects/pieces/"
	var dir = DirAccess.open(prefix)
	var dirBase = DirAccess.open("res://")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
				
				var fullName = prefix + file_name
				print(fullName)
				if FileAccess.file_exists(fullName):
					var loadedFile = load(fullName);
					add_to_tree(file_name, loadedFile)
			file_name = dir.get_next()
			
	else:
		print("An error occurred when trying to access the path.")


func _ready():
	get_pieces()
	##var tree = Tree.new()
	#var tree = $Tree
	#var root = tree.create_item()
	#tree.hide_root = true
	#var child1 = tree.create_item(root)
	#var child2 = tree.create_item(root)
	#var subchild1 = tree.create_item(child1)
	#subchild1.set_text(0, "Subchild1")

func add_to_tree(text, node):
	var child = $Tree.create_item()
	child.set_metadata(0, node)
	child.set_text(0, str(text));


func _on_tree_button_clicked(item, column, id, mouse_button_index):
	print(item, column, id, mouse_button_index)
	pass # Replace with function body.


func _on_tree_item_activated():
	var mousePos = get_viewport().get_mouse_position()
	var itemAtPos : TreeItem = $Tree.get_item_at_position(mousePos);
	print(itemAtPos.get_text(0))
	print(itemAtPos.get_metadata(0))
	var pieceRef = itemAtPos.get_metadata(0)
	set_inspected_piece(pieceRef);
	pass # Replace with function body.


@onready var coordinateMapper = {
	## Row 0
	A1 : Vector2i(0,0),
	A2 : Vector2i(1,0),
	A3 : Vector2i(2,0),
	A4 : Vector2i(3,0),
	A5 : Vector2i(4,0),
	## Row 1
	B1 : Vector2i(0,1),
	B2 : Vector2i(1,1),
	B3 : Vector2i(2,1),
	B4 : Vector2i(3,1),
	B5 : Vector2i(4,1),
	## Row 2
	C1 : Vector2i(0,2),
	C2 : Vector2i(1,2),
	C3 : Vector2i(2,2), 
	C4 : Vector2i(3,2),
	C5 : Vector2i(4,2),
	## Row 3
	D1 : Vector2i(0,3),
	D2 : Vector2i(1,3),
	D3 : Vector2i(2,3),
	D4 : Vector2i(3,3),
	D5 : Vector2i(4,3),
	## Row 4
	E1 : Vector2i(0,4),
	E2 : Vector2i(1,4),
	E3 : Vector2i(2,4),
	E4 : Vector2i(3,4),
	E5 : Vector2i(4,4),
}

func clear_coordinates():
	var array : Array[Vector2i] = []
	engine.set_pattern(array);

func generate_coordinates_from_piece(inPiece : Piece):

	var tilesArray : Array[Vector2i] = [];
	print(inPiece.engineSlots);
	var piece_engine = inPiece.engineSlots;
	#if piece_engine[]
	for slot in coordinateMapper.keys():
		if slot is CheckBox:
			var coord = coordinateMapper[slot];
			slot.button_pressed = coord in piece_engine.keys();
			tilesArray.append(coord);
	#pieceRef.
	##pieceRef.
	
	##Engine setup.
	engine.set_pattern(tilesArray);
	pass;

var frameCounter = 15;
func _process(delta):
	if frameCounter > 0:
		frameCounter -= 1;
	else:
		frameCounter = 15;
		var checks = check_and_get_checks();
		#print(checks)
		engine.set_pattern(checks);

func check_and_get_checks()->Array[Vector2i]:
	var checkedButtonArray : Array[Vector2i] = [];
	for slot in coordinateMapper.keys():
		#print(slot)
		if slot is CheckBox:
			var coord = coordinateMapper[slot];
			if slot.button_pressed:
				checkedButtonArray.append(coord);
	return checkedButtonArray;



func _on_reset_tree_pressed():
	get_pieces();
	pass # Replace with function body.


func _on_clear_preview_pressed():
	clear_inspected_piece();
	pass # Replace with function body.

##"Save" function.
func _on_save_changes_pressed():
	pass # Replace with function body.


##"Save As" function.
func _on_save_changes_as_pressed():
	pass # Replace with function body.


func _on_exit_pressed():
	get_tree().quit();
	pass # Replace with function body.
