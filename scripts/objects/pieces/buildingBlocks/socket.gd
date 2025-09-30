extends Node3D

##This object hosts Pieces.
class_name Socket

@export var invisibleInGame := false;
var occupant : Piece;
@export var hostPiece : Piece;
@export var hostRobot : Robot;
var preview : Piece;
var previewPlaceable := false;
@onready var selectorRay = $SelectorRay;

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

func remove_occupant(delete := false):
	if delete and is_instance_valid(occupant): occupant.queue_free();
	occupant = null;
	pass

func add_occupant(newPiece : Piece):
	if is_instance_valid(newPiece):
		occupant = newPiece;
		occupant.reparent(self, false)
		occupant.hostPiece = hostPiece;
		occupant.hostRobot = get_robot();
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
	
	available = occupant == null and is_valid() and get_preview_placeable() and (get_host_piece() != null) and (get_host_piece().is_assigned());
	return available;

var valid := false;
func is_valid():
	#print(is_instance_valid(get_robot()), get_host_piece() != null, get_host_piece().is_assigned());
	valid = is_instance_valid(get_robot()) and get_host_piece() != null and get_host_piece().is_assigned()
	return valid;

func set_host_piece(piece : Piece):
	hostPiece = piece;
func get_host_piece() -> Piece:
	return hostPiece;

func get_robot() -> Robot:
	if get_host_piece() == null: return null;
	var bot = get_host_piece().get_host_robot()
	if bot != null: hostRobot = bot;
	return bot;

func rotate_90(rotations:float=1):
	#print("Attempting "+str(rotations)+ " rotation.")
	rotate_object_local(Vector3.UP, (rotations * deg_to_rad(90.0)))

func reset_rotation():
	rotation.y = 0;

var hovering = false;
var selected = false;
var selectionCheckLoop = 3;

func _process(delta):
	selectionCheckLoop -= 1;
	if selectionCheckLoop <= 0:
		valid = is_valid();
		selectionCheckLoop = 3;
		if hoverResetFrameCounter <= 0:
			#print("timer reset")
			hover(false);
		#
		#var vp = get_viewport()
		#var cam = vp.get_camera_3d()
		#if is_instance_valid(cam):
			#var mousePos = vp.get_mouse_position()
			#var mousePos3D = cam.unproject_position(global_position)
			##print(mousePos, mousePos3D)
			#
			#$SelectorRay.target_position = cam.global_position - $SelectorRay.global_position;
			#$SelectorRay.global_rotation = Vector3(0,0,0)
			#
			#hover(is_valid() and (not $SelectorRay.is_colliding()) and mousePos.x - mousePos3D.x < 10 and mousePos.y - mousePos3D.y < 10 and mousePos.x - mousePos3D.x > -10 and mousePos.y - mousePos3D.y > -10);
	
	##Check for selection while hovering.
	if hovering:
		hoverResetFrameCounter -= 1;
		show_preview_of_pipette();
		
		if Input.is_action_just_pressed("Select"):
			#print("SLECE")
			hostPiece.assign_selected_socket(self);
	else:
		clear_preview();
	
	##Check for assignemtn and then for deselection.
	if selected:
		set_preview_as_occupant();
		
		if Input.is_action_just_pressed("Unselect"):
			hostPiece.deselect_all_sockets();
		
		##Change size based on selected state.
		$Selector.mesh.size = Vector2(0.75, 0.75);
	else:
		##Change size based on selected state.
		$Selector.mesh.size = Vector2(0.5, 0.5);
	
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
		if is_available():
			hovering = true;
			#$Selector.show();
			hoverResetFrameCounter = 5;
			return;
	if not selected:
		hovering = false;
		#$Selector.hide();
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
		bot.prepare_pipette(bot.pipettePiecePath);
		#print(bot.pipettePiecePath)
		var pipetteInstance = bot.pipettePieceInstance;
		if is_instance_valid(pipetteInstance):
			$SelectorRay.add_exception(pipetteInstance.hitboxCollisionHolder);
			if pipetteInstance.get_parent() == null:
				add_child(pipetteInstance);
			else:
				pipetteInstance.reparent(self);
			preview = pipetteInstance;
			preview.hostSocket = self;
			preview.hurtboxCollisionHolder.set_collision_mask_value(8, true);
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
		if preview != occupant:
			preview.queue_free();
		preview = null;

func set_preview_as_occupant():
	if is_available and is_instance_valid(preview) and get_preview_placeable():
		var bot = get_robot();
		bot.detach_pipette();
		preview.assign_socket(self);
		preview = null;
		select(false);

func set_occupant_as_preview(): ##TODO: This.
	pass

func hover_from_camera(cam) -> Piece:
	selectionCheckLoop = 4;
	$SelectorRay.target_position = cam.global_position - $SelectorRay.global_position;
	$SelectorRay.global_rotation = Vector3(0,0,0);
	hover(is_valid() and (not $SelectorRay.is_colliding()));
	if is_instance_valid(preview):
		return preview;
	return null;
