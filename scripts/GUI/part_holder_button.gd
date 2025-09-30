extends TextureButton

class_name PartHolderButton

@export var coordX : int;
@export var coordY : int;
var inventory : InventoryPlayer;
var parent : PartsHolder_Engine;
var available := true;

func _ready():
	parent = get_parent();
	pass # Replace wi

func _on_pressed():
	parent.buttonPressed.emit(coordX,coordY);
	pass # Replace with function body.

func set_availability(foo):
	available = foo;
	disable(!foo)
	update_gfx();

@export var GFX_selected : Texture2D = preload("res://graphics/images/HUD/engine/inv_selectedPlugIn.png");
@export var GFX_unselected : Texture2D = preload("res://graphics/images/HUD/engine/inv_unselectedPlugIn.png");
@export var GFX_unselectable : Texture2D = preload("res://graphics/images/HUD/engine/inv_unselectablePlugIn.png");

##True makes it visible and fancy, False makes it invisible
func set_textures(selectable:bool): 
	if selectable and available:
		texture_normal = GFX_unselected;
		texture_pressed = GFX_selected;
		texture_hover = GFX_selected;
		texture_disabled = GFX_unselectable;
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
	var hideme := false;
	if (! disabled) and available:
		inventory = GameState.get_inventory(); #gets the inventory
		var space = true;
		var free = true;
		if is_instance_valid(inventory): ##TODO: Set this up to work with Pieces instead.
			space = inventory.is_there_space_for_part(inventory.selectedPart, Vector2i(coordX,coordY));
			free = inventory.is_slot_free(coordX, coordY, inventory.selectedPart);
		
		##Always visible if there's space. If there's no space, it 
		if space:
			z_index = 100;
			set_textures(true);
			mouse_filter = Control.MOUSE_FILTER_STOP;
		else:
			if free:
				z_index = 100;
				set_textures(true);
				mouse_filter = Control.MOUSE_FILTER_IGNORE;
				disabled = true;
			else:
				hideme = true;
	else:
		hideme = true;
	
	if hideme:
		hide()
		disabled = true;
		set_textures(false); #Sets the sprite invisible
		mouse_filter = Control.MOUSE_FILTER_IGNORE; #makes the mouse not wanna click it
		z_index = 0; #makes it not draw over other stuff

func _process(delta):
	if is_instance_valid(parent):
		if parent.check_in_state([PartsHolder_Engine.doorStates.OPEN]):
			if ! visible:
				show();
		else:
			if visible:
				hide();
				disabled = true;
	else:
		hide();
		disabled = true;
