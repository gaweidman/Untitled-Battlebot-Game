extends Area3D

##Exists to get
class_name HurtboxHolder

func get_piece():
	var parent = get_parent();
	if parent is Piece:
		return parent;
	return null;

func select_piece():
	var piece = get_piece();
	if piece != null:
		piece.select();
