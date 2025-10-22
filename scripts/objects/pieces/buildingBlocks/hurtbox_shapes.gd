@icon ("res://graphics/images/class_icons/shield.png")
extends Area3D

##Exists to get
class_name HurtboxHolder

func _init():
	collision_layer = 8;
	collision_mask = 0;
	pass;

func get_piece():
	var parent = get_parent();
	if parent is Piece:
		return parent;
	return null;

func select_piece():
	var piece = get_piece();
	if piece != null:
		piece.select_via_robot();
