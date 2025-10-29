@icon ("res://graphics/images/class_icons/socket.png")
extends Node3D

class_name Socket
##This object hosts [Piece]s.

@export var invisibleInGame := false;
@export var occupant : Piece;
@export var hostPiece : Piece;
@export var hostRobot : Robot;
var preview : Piece;
var previewPlaceable := false;
@onready var selectorRay = $SelectorRay;
@export var collisionSphere : CollisionShape3D;
@export var collisionScale := 0.45;
@export var selectorRayExceptions : Array[CollisionObject3D]= [];

@export var dontUsePieceForRobotHost := false;

##Needs functions to ping its host.
##If occupant is null, it is assumed to be empty and able to be plugged in.

func _ready():
	if invisibleInGame:
		$FemaleConnector.hide();
	if is_instance_valid(hostPiece):
		hostPiece.register_socket(self);
	else:
		#queue_free();
		pass;
	collisionSphere.shape = collisionSphere.shape.duplicate();
	collisionSphere.shape.radius = collisionScale;

####################### SETUP LOAD

func load_startup_data(data, robot : Robot):
	remove_occupant(true);
	var rot = data["rotation"];
	if rot is float:
		set_socket_rotation(rad_to_deg(rot));
	elif rot is Vector3:
		rotation = rot;
	var occupantData = data["occupant"];
	if occupantData != null and not occupantData is String:
		print("OCCUPANT DATA: ", occupantData)
		var occupantPath = occupantData.keys()[0]
		#print("OCCUPANT PATH: ", occupantPath)
		var occupantDataForwarded = occupantData[occupantPath];
		#print("OCCUPANT DATA TO FORWARD: ", occupantDataForwarded)
		var result = add_occupant_from_scene_path(occupantPath);
		if result != null:
			print(result);
			result.load_startup_data(occupantDataForwarded, robot);


########################

func add_occupant_from_scene_path(scenePath : String):
	if FileAccess.file_exists(scenePath):
		var newPieceScene = load(scenePath);
		var newPiece = newPieceScene.instantiate();
		if is_instance_valid(newPiece):
			if newPiece is Piece:
				add_child(newPiece);
				add_occupant(newPiece, true)
				newPiece.filepathForThisEntity = scenePath;
				return newPiece;
	return null;

func remove_occupant(delete := false):
	if delete and is_instance_valid(occupant): occupant.queue_free();
	if is_instance_valid(occupant): remove_child(occupant);
	occupant = null;
	pass

##Sets the given piece as a child of this [Socket], and sets its [member Robot.hostPiece] and [member Robot.hostRobot] as this [Socket]'s hosts.
func add_occupant(newPiece : Piece, manual := false):
	if is_instance_valid(newPiece):
		occupant = newPiece;
		#print("SETTING AS OCCUPANT!")
		if is_instance_valid(occupant.get_parent()):
			occupant.reparent(self, false);
		else:
			add_child(occupant);
		
		occupant.hostPiece = hostPiece;
		occupant.hostSocket = self;
		
		if ! manual:
			occupant.hostRobot = get_robot();
		else:
			occupant.hostRobot = get_host_robot_unsafe();
			occupant.assign_socket_post(self);
		$Selector.hide();

func get_energy_transmitted():
	if hostPiece != null:
		return hostPiece.get_outgoing_energy();
	else:
		if hostRobot != null:
			return hostRobot.get_available_energy();
	return 0.0;

var available := false;
func is_available():
	#return GameState.get_in_state_of_building() && occupant == null && is_valid() && get_preview_placeable();
	if dontUsePieceForRobotHost:
		available = occupant == null and is_valid() and get_preview_placeable();
	else:
		available = occupant == null and is_valid() and get_preview_placeable() and (get_host_piece() != null) and (get_host_piece().is_assigned());
	#print(available)
	return available;

var valid := false;
func is_valid():
	#print(is_instance_valid(get_robot()), get_host_piece() != null, get_host_piece().is_assigned());
	if dontUsePieceForRobotHost:
		valid = is_instance_valid(get_robot());
	else:
		valid = is_instance_valid(get_robot()) and get_host_piece() != null and get_host_piece().is_assigned();
	#print(valid)
	return valid;

func set_host_piece(piece : Piece):
	hostPiece = piece;
func get_host_piece() -> Piece:
	return hostPiece;

func set_host_robot(robot: Robot):
	hostRobot = robot;

func get_robot(forcePieceToGiveHostRobot := false) -> Robot:
	if (!dontUsePieceForRobotHost) and (get_host_piece() == null): return null;
	#print("Has a piece...", get_host_piece().pieceName)
	var bot
	if dontUsePieceForRobotHost:
		bot = hostRobot;
	else:
		bot = get_host_piece().get_host_robot(forcePieceToGiveHostRobot);
	#print(bot)
	if bot != null and is_instance_valid(bot): hostRobot = bot;
	return bot;

## This ghets the host robot, but directly from the variable. Unsafe to use outside of scenarios where the host has been preset.
func get_host_robot_unsafe() -> Robot:
	#print("HOst robot b4 safe function: ", hostRobot)
	get_robot(true);
	#print("HOst robot: ", hostRobot)
	if hostRobot == null:
		if $"../../.." is Robot:
			hostRobot = $"../../..";
	return hostRobot;

var currentRotationDeg := 0.0;

func rotate_90(rotations:float=1):
	#print("Attempting "+str(rotations)+ " rotation.")
	currentRotationDeg += rotations * 90.0;
	rotate_object_local(Vector3.UP, (rotations * deg_to_rad(90.0)))

func set_socket_rotation(newRotDeg := currentRotationDeg):
	reset_rotation();
	currentRotationDeg = newRotDeg;
	rotation.y = deg_to_rad(newRotDeg);

func reset_rotation():
	currentRotationDeg = 0.0;
	rotation.y = 0.0;

var hovering = false;
var selected = false;
var selectionCheckLoop = 3;

func _process(delta):
	selectionCheckLoop -= 1;
	if selectionCheckLoop <= 0:
		valid = is_valid();
		selectionCheckLoop = 3;
		if hoverResetFrameCounter <= 0:
			#print_rich("MAN")
			if hovering:
				print_rich("MAN")	
			hover(false);
		#
		#var vp = get_viewport()
		#var cam = vp.get_camera_3d()
		#if is_instance_valid(cam):
			#var mousePos = vp.get_mouse_position()
			#var mousePos3D = cam.unproject_position(global_position)
			##print(mousePos, mousePos3D)
			#
			#selectorRay.target_position = cam.global_position - selectorRay.global_position;
			#selectorRay.global_rotation = Vector3(0,0,0)
			#
			#hover(is_valid() and (not selectorRay.is_colliding()) and mousePos.x - mousePos3D.x < 10 and mousePos.y - mousePos3D.y < 10 and mousePos.x - mousePos3D.x > -10 and mousePos.y - mousePos3D.y > -10);
	
	##Check for selection while hovering.
	if hovering:
		hoverResetFrameCounter -= 1;
		show_preview_of_pipette();
		
		if Input.is_action_just_pressed("Select"):
			#print("SLECE")
			if dontUsePieceForRobotHost:
				select(true);
			else:
				hostPiece.assign_selected_socket(self);
	else:
		clear_preview();
	
	##Check for assignemtn and then for deselection.
	if selected:
		set_preview_as_occupant();
		
		if Input.is_action_just_pressed("Unselect"):
			if dontUsePieceForRobotHost:
				select(false);
			else:
				hostPiece.deselect_all_sockets();
	
	##Change collision based on validity.
	$CollisionShape3D.disabled = not valid;
	
	##Rotate the preview if there is one and the button is pressed to do so.
	if has_preview():
		if Input.is_action_just_pressed("RotatePiece_CW"):
			rotate_90(1)
		if Input.is_action_just_pressed("RotatePiece_CCW"):
			rotate_90(-1)
	

func _physics_process(delta):
	calc_preview_placeable();

var hoverResetFrameCounter := 0;

func hover(foo):
	if foo == hovering: return;
	
	if foo:
		if is_available() or has_preview():
			hovering = true;
			hoverResetFrameCounter = 5;
			return;
	if not selected:
		hovering = false;
		return;

func select(foo:=true):
	if foo == selected: return;
	#print("SLECE")
	if foo:
		if is_available():
			selected = true;
			show_preview_of_pipette();
	else:
		selected = false;

func show_preview_of_pipette():
	##Set up a new preview.
	if is_available() && preview == null:
		var bot = get_robot();
		bot.prepare_pipette();
		#print(bot.pipettePiecePath)
		var pipetteInstance = bot.pipettePieceInstance;
		if is_instance_valid(pipetteInstance):
			selectorRay.add_exception(pipetteInstance.hitboxCollisionHolder);
			if ! is_instance_valid(pipetteInstance.get_parent()):
				add_child(pipetteInstance);
			else:
				pipetteInstance.reparent(self);
			preview = pipetteInstance;
			preview.position = Vector3(0,0,0);
			preview.rotation = Vector3(0,0,0);
			preview.hostSocket = self;
			preview.hurtboxCollisionHolder.set_collision_mask_value(8, true);
			preview.isPreview = true;
	return preview;

func calc_preview_placeable():
	previewPlaceable = false;
	#print("wtf")
	##CHeck if the preview is able to actually be placed in the spot you want.
	if is_instance_valid(preview):
		var hit = preview.ping_placement_validation();
		previewPlaceable = not hit;
	else:
		previewPlaceable = true; 

func get_preview_placeable():
	return previewPlaceable;

func get_preview_or_null():
	if is_instance_valid(preview) and preview is Piece:
		return preview;
	return null;

func has_preview():
	return get_preview_or_null() != null;

func clear_preview():
	if preview != null:
		#if preview != occupant:
			#preview.get_parent().remove_child(preview);
		preview.remove_and_add_to_robot_stash(get_robot());
		preview = null;

func set_preview_as_occupant():
	if is_available and is_instance_valid(preview) and get_preview_placeable():
		var bot = get_robot();
		bot.unreference_pipette();
		preview.assign_socket(self);
		preview = null;
		select(false);

func set_occupant_as_preview(): ##TODO: This.
	pass

func get_occupant() -> Piece:
	if is_instance_valid(occupant):
		return occupant;
	return null;

func get_occupant_or_child() -> Piece:
	if get_occupant() != null: return get_occupant();
	for child in get_children():
		if child is Piece:
			return child;
	return null;

func hover_from_camera(cam) -> Piece:
	selectionCheckLoop = 4;
	##Add exceptions.
	for thing in selectorRayExceptions:
		selectorRay.add_exception(thing);
	
	selectorRay.target_position = (cam.global_position - selectorRay.global_position);
	selectorRay.global_rotation = Vector3(0,0,0);
	hover(is_valid() and (not selectorRay.is_colliding()));
	if is_instance_valid(preview):
		return preview;
	return null;

## How much weight this Socket is supporting, NOT including its host.
var weightLoad = -1.0;
func get_weight_load(forceRegenerate := false):
	if weightLoad < 0 or forceRegenerate:
		return get_weight_starting_from_occupant();
	return weightLoad;

## Recalculates weightLoad.
func get_weight_starting_from_occupant():
	var occ = get_occupant();
	if occ != null:
		weightLoad = occ.get_regenerated_weight_load();
		#print(weightLoad);
		return weightLoad;
	weightLoad = 0.0;
	return weightLoad;
