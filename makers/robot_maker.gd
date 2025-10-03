extends MakerMode

class_name MakerMode_Robots

@export_category("Node Refs")
@export var manager : MakerModeManager;
@export_subgroup("Camera")

@export_subgroup("Tree")
@export var tree_robot : Tree;
@export var tree_pieces : Tree;

@export_subgroup("Engine")
@export var engine : PartsHolder_Engine;

func _ready():
	get_pieces();
	get_robots();

func _on_robot_tree_item_activated():
	var mousePos = get_viewport().get_mouse_position() - tree_robot.position
	var itemAtPos : TreeItem = tree_robot.get_item_at_position(mousePos);
	print(itemAtPos.get_text(0))
	print(itemAtPos.get_metadata(0))
	var data = itemAtPos.get_metadata(0)
	if data is Dictionary:
		print(data)
		#set_inspected_piece(data);
		spawn_inpspected_robot(data);
	pass # Replace with function body.


func _on_pieces_tree_item_activated():
	var mousePos = get_viewport().get_mouse_position() - tree_pieces.position
	var itemAtPos : TreeItem = tree_pieces.get_item_at_position(mousePos);
	print(itemAtPos.get_text(0))
	print(itemAtPos.get_metadata(0))
	var data = itemAtPos.get_metadata(0)
	if data is Dictionary:
		print(data)
		#set_inspected_piece(data);
	pass # Replace with function body.

##Adds a Piece node to the tree. Needs the text, the node's PackedScene, and the original filepath.
func add_to_tree(tree : Tree, text, node, filepath):
	var child = tree.create_item()
	child.set_metadata(0, {"node" : node, "filepath" : filepath});
	child.set_text(0, str(text));

##Resets the list of viewed Pieces.
func get_pieces():
	tree_pieces.clear();
	var child = tree_pieces.create_item();
	child.set_text(0, "Pieces");
	child.set_metadata(0, generate_new_piece());
	
	var prefix = manager.filepathPrefixPieces
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
					add_to_tree(tree_pieces, file_name, loadedFile, fullName);
			file_name = dir.get_next()
			
	else:
		print("An error occurred when trying to access the path.")

func generate_new_piece():
	var newData = {
		"node" : manager.newPieceRef,
		"filepath" : "res://scenes/prefabs/objects/pieces/piece_test.tscn",
	}
	return newData;


##Resets the list of viewed Robots.
func get_robots():
	tree_robot.clear();
	var child = tree_robot.create_item();
	child.set_text(0, "Robots");
	child.set_metadata(0, generate_new_robot());
	
	var prefix = manager.filepathPrefixRobots
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
					add_to_tree(tree_robot, file_name, loadedFile, fullName);
			file_name = dir.get_next()
			
	else:
		print("An error occurred when trying to access the path.")

func generate_new_robot():
	var newData = {
		"node" : manager.newRobotRef,
		"filepath" : "res://scenes/prefabs/objects/robots/robot_test.tscn",
	}
	return newData;

var botSceneFilePath : String;
var botSceneBeingInspected : PackedScene;
var botBeingInspected : Robot;

@export_subgroup("World")
@export var botSpawnPoint : Node3D;

## Given a [Dictionary]. Format is { "node" : [PackedScene], "filepath" : original filepath }
func spawn_inpspected_robot(data):
	#open_save_popup(false);
	
	var botRef = data.node;
	var botFilePath = data.filepath;
	if ! botRef is PackedScene: return;
	
	var newBot = botRef.instantiate();
	if newBot is Robot:
		##Clear out the old.
		clear_inspected_robot();
		
		##Set the new scene and bot.
		botSceneBeingInspected = botRef;
		botBeingInspected = newBot;
		botSceneFilePath = botFilePath;
		
		##Show the thing.
		botBeingInspected.show();
		
		###Change the filepath text.
		#lbl_filepathName.text = pieceFilePath;
		#
		###Change the piece name text.
		#txt_pieceName.text = newPiece.pieceName;
		#txt_pieceDescription.text = newPiece.pieceDescription;
		
		if newBot is Robot_Player:
			newBot.engineViewer = engine;
		
		botSpawnPoint.add_child(botBeingInspected);
	return botBeingInspected;


### Given a [Dictionary]. Format is { "node" : [PackedScene], "filepath" : original filepath }
#func set_inspected_piece(data):
	#
	#open_save_popup(false);
	#
	#var pieceRef = data.node;
	#var pieceFilePath = data.filepath;
	#if ! pieceRef is PackedScene: return;
	#
	#var newPiece = pieceRef.instantiate();
	#if newPiece is Piece:
		###Clear out the old.
		#clear_inspected_piece();
		#
		###Set the new scene and piece.
		#pieceSceneBeingInspected = pieceRef;
		#pieceBeingInspected = newPiece;
		#pieceSceneFilePath = pieceFilePath;
		#
		###Show the thing.
		#pieceBeingInspected.show();
		#
		###Change the filepath text.
		#lbl_filepathName.text = pieceFilePath;
		#
		###Change the piece name text.
		#txt_pieceName.text = newPiece.pieceName;
		#txt_pieceDescription.text = newPiece.pieceDescription;
		#
		#pieceHolder.add_child(pieceBeingInspected);
		#pieceHolder.add_occupant(pieceBeingInspected);
		#pieceBeingInspected.force_visibility = true;
		#generate_coordinates_from_piece(pieceBeingInspected);
	#return pieceBeingInspected;


func clear_inspected_robot():
	if is_instance_valid(botBeingInspected):
		botBeingInspected.queue_free();
	botSceneBeingInspected = null;
	#lbl_filepathName.text = "[No Piece selected]";
	pass;


#func clear_inspected_piece():
	###Clear everything out.
	#pieceHolder.remove_occupant(true);
	#clear_coordinates();
	#if is_instance_valid(pieceBeingInspected):
		#pieceBeingInspected.queue_free();
	#pieceSceneBeingInspected = null;
	#lbl_filepathName.text = "[No Piece selected]";
