extends Button

class_name StashButton;

var pieceReferenced : Piece;
var partReferenced : Part;
var stashHUD : PieceStash;

var iconPart := preload("res://graphics/images/HUD/statIcons/partIconStriped.png");
var iconPiece := preload("res://graphics/images/HUD/statIcons/pieceIconStriped.png");

@export var img_equippedBG : TextureRect;
@export var img_selectedBG : TextureRect;

func load_piece_data(inPiece : Piece, hud : PieceStash):
	name = inPiece.pieceName;
	text = inPiece.get_stash_button_name();
	pieceReferenced = inPiece;
	stashHUD = hud;
	icon = iconPiece;
	update_bg();


func load_part_data(inPart : Part, hud : PieceStash):
	name = inPart.partName;
	text = inPart.partName;
	partReferenced = inPart;
	stashHUD = hud;
	icon = iconPart;
	update_bg();


func _on_pressed():
	if is_instance_valid(stashHUD):
		if is_instance_valid(pieceReferenced):
			print("buton pres ", pieceReferenced)
			stashHUD.piece_button_pressed(pieceReferenced, self);
			select(true);
		if is_instance_valid(partReferenced):
			print("part buton pres ", partReferenced)
			stashHUD.part_button_pressed(partReferenced, self);
			select(true);
	update_bg();
	pass 

var selected := false;
func get_selected() -> bool:
	if is_instance_valid(pieceReferenced) and pieceReferenced.get_selected(): selected = true; return true;
	if stashHUD.get_current_robot() != null:
		if is_instance_valid(pieceReferenced) and stashHUD.get_current_robot().get_current_pipette() == pieceReferenced:
			selected = true;
	return selected;

func select(foo := not get_selected()):
	selected = foo;
	update_bg();

func update_bg():
	if get_selected():
		img_selectedBG.show();
		img_equippedBG.hide();
	else:
		img_selectedBG.hide();
		if is_instance_valid(pieceReferenced) and pieceReferenced.is_equipped():
			img_equippedBG.show();
		else:
			img_equippedBG.hide();

func _process(delta):
	update_bg();
