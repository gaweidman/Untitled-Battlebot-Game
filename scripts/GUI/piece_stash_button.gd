extends Button

class_name StashButton;

var pieceReferenced : Piece;
var partReferenced : Part;
var stashHUD : PieceStash;

var iconPart := preload("res://graphics/images/HUD/statIcons/partIconStriped.png");
var iconPiece := preload("res://graphics/images/HUD/statIcons/pieceIconStriped.png");

func load_piece_data(inPiece : Piece, hud : PieceStash):
	name = inPiece.pieceName;
	text = inPiece.get_stash_button_name();
	pieceReferenced = inPiece;
	stashHUD = hud;
	icon = iconPiece;


func load_part_data(inPart : Part, hud : PieceStash):
	name = inPart.partName;
	text = inPart.partName;
	partReferenced = inPart;
	stashHUD = hud;
	icon = iconPart;


func _on_pressed():
	if is_instance_valid(stashHUD):
		if is_instance_valid(pieceReferenced):
			print("buton pres ", pieceReferenced)
			stashHUD.piece_button_pressed(pieceReferenced);
		if is_instance_valid(partReferenced):
			print("part buton pres ", partReferenced)
			stashHUD.part_button_pressed(partReferenced);
	pass 
