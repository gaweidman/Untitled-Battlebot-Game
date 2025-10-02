extends CollisionShape3D

class_name PieceCollisionBox

var colliderID : int = -1;
var originalHost : Piece;
var originalBox : PieceCollisionBox = self;
var originalOffset : Vector3;
var originalRotation : Vector3;
var copied : = false;
var copiedByBody : = false; ##Set by the Robot when it's copied for the body.
@export var identifier : StringName;
@export var isPlacementBox := true; ##This collider is for placement validation.
@export var isHurtbox:= true; ##This collider is for detecting incoming attacks and impacts.
@export var isHitbox:= false;  ##This collider is for dishing out attacks.
var isOriginal = true;

var copies : Array[PieceCollisionBox] = [];
var shapecasts : Array[ShapeCast3D] = [];

func _ready():
	get_collider_id();

func make_copy() -> PieceCollisionBox:
	var newBox : PieceCollisionBox = duplicate();
	print(originalHost)
	newBox.isOriginal = false;
	newBox.colliderID = get_collider_id();
	print(newBox.colliderID)
	print(isHitbox, isHurtbox, isPlacementBox)
	copied = true;
	newBox.originalBox = self;
	copies.append(newBox);
	return newBox;

func make_shapecast():
	var shapecast = ShapeCast3D.new();
	shapecasts.append(shapecast);
	return shapecast;

func erase_all_copies():
	for copy in copies:
		if is_instance_valid(copy):
			copy.queue_free();
	copies.clear();

func erase_all_shapecasts():
	for copy in shapecasts:
		if is_instance_valid(copy):
			copy.queue_free();
	shapecasts.clear();

func reset():
	erase_all_shapecasts();
	erase_all_copies();
	copied = false;
	copiedByBody = false;

func fix_positions_of_copies():
	for copy in copies:
		copy.global_position = global_position;
		copy.global_rotation = global_rotation;
		if isHitbox:
			print(copy.get_parent());
	for cast in shapecasts:
		cast.global_position = global_position;
		cast.global_rotation = global_rotation;

func get_collider_id():
	if colliderID == null or colliderID == -1:
		colliderID = GameState.get_unique_collider_id();
	return colliderID;
