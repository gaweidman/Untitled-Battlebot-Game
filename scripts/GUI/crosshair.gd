@icon ("res://graphics/images/class_icons/cursor.png")
extends TextureRect
class_name Crosshair

@export var crosshairClick := preload("res://graphics/images/class_icons/cursor2.png");
@export var crosshairNormal := preload("res://graphics/images/class_icons/cursor.png");

var bigCrosshairFrames = 0.0;
func _process(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		visible = false;
	elif Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
		var vp = get_viewport();
		var window = get_window();
		var mousePos = vp.get_mouse_position();
		mousePos = window.get_mouse_position();
		set_position(mousePos + Vector2(-8,-8));
		bigCrosshairFrames = max(-0.3, bigCrosshairFrames - 10 * delta);
		if GameState.is_fire_action_being_pressed() and bigCrosshairFrames == -0.3:
			bigCrosshairFrames = 1;
		
		if bigCrosshairFrames > 0:
			texture = crosshairClick;
		else:
			texture = crosshairNormal;
		
		visible = true;
