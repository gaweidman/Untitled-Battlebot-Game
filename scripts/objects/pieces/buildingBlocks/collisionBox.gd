extends CollisionShape3D

class_name PieceCollisionBox

var originalHost : Piece;
var originalOffset : Vector3;
var copied : = false;
@export var identifier : StringName;
@export var isPlacementBox := true; ##This collider is for placement validation.
@export var isHurtbox:= true; ##This collider is for detecting incoming attacks and impacts.
@export var isHitbox:= false;  ##This collider is for dishing out attacks.
var isOriginal = true;

var copies : Array[PieceCollisionBox] = [];
var shapecasts : Array[ShapeCast3D] = [];

func make_copy() -> PieceCollisionBox:
	var newBox : PieceCollisionBox = duplicate();
	newBox.isOriginal = false;
	copied = true;
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
