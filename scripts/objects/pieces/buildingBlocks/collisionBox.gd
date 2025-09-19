extends CollisionShape3D

class_name PieceCollisionBox

var originalHost : Piece;
@export var identifier : StringName;
@export var isPlacementBox := true; ##This collider is for placement validation.
@export var isHurtbox:= true; ##This collider is for detecting incoming attacks and impacts.
@export var isHitbox:= false;  ##This collider is for dishing out attacks.
