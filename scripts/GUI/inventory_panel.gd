extends TextureButton

signal inventoryToggle(foo:bool);

const close_unsel = preload("res://graphics/images/HUD/inventoryTab/close_unselected.png");
const close_sel = preload("res://graphics/images/HUD/inventoryTab/close_selected.png");
const close_disabled = preload("res://graphics/images/HUD/inventoryTab/close_disabled.png");
const open_unsel = preload("res://graphics/images/HUD/inventoryTab/open_unselected.png");
const open_sel = preload("res://graphics/images/HUD/inventoryTab/open_selected.png");
const open_disabled = preload("res://graphics/images/HUD/inventoryTab/open_disabled.png");

var mousingOver := false;
var open := false;

func _on_mouse_entered():
	mousingOver = true;
	pass # Replace with function body.

func _on_mouse_exited():
	mousingOver = false;
	pass # Replace with function body.

func change_sprites(foo):
	set_pressed_no_signal(foo);
	if foo:
		texture_normal = close_unsel;
		texture_hover = close_unsel;
		texture_pressed = close_sel;
		texture_disabled = close_disabled;
	else:
		texture_normal = open_unsel;
		texture_hover = open_unsel;
		texture_pressed = open_sel;
		texture_disabled = open_disabled;

func _on_button_up():
	if mousingOver:
		switch(!open);
	pass # Replace with function body.

func switch(switch : bool):
	if open != switch:
		open = switch;
		inventoryToggle.emit(open);
		change_sprites(open);

func disable(foo:bool):
	disabled = foo;
	change_sprites(open);
