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

##True makes it visible and fancy, False makes it invisible
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
#
#func update_gfx():
	#if ! disabled:
		#inventory = GameState.get_inventory();
		#if inventory.is_slot_free(coordX, coordY, inventory.selectedPart):
			#z_index = 100;
			#set_textures(true);
			#if inventory.is_there_space_for_part(inventory.selectedPart, Vector2i(coordX,coordY)):
				#mouse_filter = Control.MOUSE_FILTER_STOP;
			#else:
				#mouse_filter = Control.MOUSE_FILTER_IGNORE;
				#disabled = true;
		#else:
			#disabled = true;
	#else:
		#set_textures(false);
		#mouse_filter = Control.MOUSE_FILTER_IGNORE;
		#z_index = 0;


func update_gfx():
	var hideme := false;
	if ! disabled:
		inventory = GameState.get_inventory(); #gets the inventory
		var space = inventory.is_there_space_for_part(inventory.selectedPart, Vector2i(coordX,coordY));
		var free = inventory.is_slot_free(coordX, coordY, inventory.selectedPart);
		
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
		disabled = true;
		set_textures(false); #Sets the sprite invisible
		mouse_filter = Control.MOUSE_FILTER_IGNORE; #makes the mouse not wanna click it
		z_index = 0; #makes it not draw over other stuff
