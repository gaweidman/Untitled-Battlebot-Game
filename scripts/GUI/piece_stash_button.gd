extends Button

class_name StashButton;

var pieceReferenced : Piece;
var stashHUD : PieceStash;

func load_piece_data(inPiece : Piece, hud : PieceStash):
	name = inPiece.pieceName;
	text = inPiece.get_stash_button_name();
	pieceReferenced = inPiece;
	stashHUD = hud;

func _on_pressed():
	if is_instance_valid(stashHUD) and is_instance_valid(pieceReferenced):
		print("buton pres ", pieceReferenced)
		stashHUD.piece_button_pressed(pieceReferenced);
	pass 
