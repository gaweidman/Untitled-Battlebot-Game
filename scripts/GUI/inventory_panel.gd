extends TextureButton

signal inventoryToggle(foo:bool);

func _on_toggled(toggled_on):
	inventoryToggle.emit(toggled_on);
	change_sprites(toggled_on);
	pass # Replace with function body.

func change_sprites(foo):
	set_pressed_no_signal(foo);
	if foo:
		texture_normal = load("res://graphics/images/HUD/inventoryTab_downUnselected.png");
		texture_pressed = load("res://graphics/images/HUD/inventoryTab_downSelected.png");
		texture_hover = load("res://graphics/images/HUD/inventoryTab_downSelected.png");
	else:
		texture_normal = load("res://graphics/images/HUD/inventoryTab_upUnselected.png");
		texture_pressed = load("res://graphics/images/HUD/inventoryTab_upSelected.png");
		texture_hover = load("res://graphics/images/HUD/inventoryTab_upSelected.png");
