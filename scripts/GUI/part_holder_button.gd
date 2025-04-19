extends TextureButton

class_name PartHolderButton

@export var coordX : int;
@export var coordY : int;
var inventory : InventoryPlayer;
var parent : PartsHolder_Engine;

func _ready():
	parent = get_parent();
	pass # Replace wi

func _on_pressed():
	parent.buttonPressed.emit(coordX,coordY);
	pass # Replace with function body.

func set_textures(selectable:bool):
	if selectable:
		texture_normal = load("res://graphics/images/HUD/inv_unselectedPlugIn.png");
		texture_pressed = load("res://graphics/images/HUD/inv_selectedPlugIn.png");
		texture_hover = load("res://graphics/images/HUD/inv_selectedPlugIn.png");
		texture_disabled = load("res://graphics/images/HUD/inv_unselectablePlugIn.png");
	else:
		texture_normal = null;
		texture_pressed = null;
		texture_hover = null;
		texture_disabled = null;

func disable(_disabled:bool):
	disabled = _disabled;
	if disabled: button_pressed = false;
	update_gfx();

func update_gfx():
	if ! disabled:
		inventory = GameState.get_inventory();
		if inventory.is_slot_free(coordX, coordY, inventory.selectedPart):
			z_index = 100;
			set_textures(true);
			if inventory.is_there_space_for_part(inventory.selectedPart, Vector2i(coordX,coordY)):
				mouse_filter = Control.MOUSE_FILTER_STOP;
			else:
				mouse_filter = Control.MOUSE_FILTER_IGNORE;
				disabled = true;
		else:
			disabled = true;
	else:
		set_textures(false);
		mouse_filter = Control.MOUSE_FILTER_IGNORE;
		z_index = 0;
