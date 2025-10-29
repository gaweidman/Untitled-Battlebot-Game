extends Button

class_name StashButton;

var pieceReferenced : Piece;
var partReferenced : Part;
var stashHUD : PieceStash;

var iconPart := preload("res://graphics/images/HUD/statIcons/partIconStriped.png");
var iconPiece := preload("res://graphics/images/HUD/statIcons/pieceIconStriped.png");

@export var img_equippedBG : TextureRect;
@export var img_selectedBG : TextureRect;
@export var img_unequippedSelectedBG : TextureRect;

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
			#select(true);
		if is_instance_valid(partReferenced):
			print("part buton pres ", partReferenced)
			stashHUD.part_button_pressed(partReferenced, self);
			#select(true);
	update_bg();
	pass 

var robot : Robot;
func get_robot() -> Robot:
	robot = stashHUD.get_current_robot();
	return robot;

var selected := false;
func get_selected() -> bool:
	selected = false;
	if is_instance_valid(pieceReferenced) and pieceReferenced.get_selected(): 
		selected = true;
	if get_robot() != null:
		if is_instance_valid(pieceReferenced) and robot.get_current_pipette() == pieceReferenced:
			selected = true;
	return selected;

var ref;
## gets this button's reference, sets the value to [member ref], then returns it, or [null] if neither. Prioritizes [member partReferenced] over [member pieceReferenced].
func get_reference():
	if get_robot() == null:
		ref = null;
		return null;
	if is_instance_valid(partReferenced):
		ref = partReferenced;
		return partReferenced;
	if is_instance_valid(pieceReferenced):
		ref = pieceReferenced;
		return pieceReferenced;
	ref = null;
	return null;

func select(foo := not get_selected()):
	selected = foo;
	if !foo:
		if get_reference() != null:
			if ref is Piece:
				ref.deselect();
				ref.select(false);
				if get_robot() != null:
					robot.deselect_piece(ref);
	
	update_bg();

func get_equipped():
	return is_instance_valid(pieceReferenced) and pieceReferenced.is_equipped();

enum modes {
	NotSelectedNotEquipped,
	SelectedNotEquipped,
	NotSelectedEquipped,
	SelectedEquipped,
}

func update_bg():
	var mode : modes;
	if get_selected():
		if get_equipped():
			mode = modes.SelectedEquipped;
		else:
			mode = modes.SelectedNotEquipped;
	else:
		if get_equipped():
			mode = modes.NotSelectedEquipped;
		else:
			mode = modes.NotSelectedNotEquipped;
	img_selectedBG.visible = mode == modes.SelectedEquipped;
	img_unequippedSelectedBG.visible = mode == modes.SelectedNotEquipped;
	img_equippedBG.visible = mode == modes.NotSelectedEquipped;

func _process(delta):
	if !is_instance_valid(robot) or !is_instance_valid(get_reference()):
		queue_free();
	update_bg();
