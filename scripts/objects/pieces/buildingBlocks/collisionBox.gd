extends CollisionShape3D

class_name PieceCollisionBox

var colliderID : int = -1;
var originalHost : Piece;
var originalBox : PieceCollisionBox = self;
var originalOffset : Vector3;
var originalRotation : Vector3;
var copied : = false;
var copiedShapecast : = false;
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
	if (not isOriginal) and (is_instance_valid(originalBox)): return originalBox.make_copy();
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
	if copiedShapecast == true: return shapecasts[0]
	var shapeCastNew = ShapeCast3D.new();
	shapecasts.append(shapeCastNew);
	copied = true;
	
	add_child(shapeCastNew)
	
	var posNew = position;
	posNew = Vector3(0,0,0);
	shapeCastNew.set("position", posNew);
	shapeCastNew.set("scale", scale * 0.95);
	shapeCastNew.set("rotation", rotation);
	shapeCastNew.set("shape", shape);
	shapeCastNew.set("target_position", Vector3(0,0,0));	
	shapeCastNew.collide_with_areas = true;
	shapeCastNew.enabled = true;
	shapeCastNew.debug_shape_custom_color = Color("af7f006b");
	shapeCastNew.set_collision_mask_value(4, true);
	shapeCastNew.set_collision_mask_value(5, true);
	
	copiedShapecast = true;
	
	return shapeCastNew;

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
	copiedShapecast = false;

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
