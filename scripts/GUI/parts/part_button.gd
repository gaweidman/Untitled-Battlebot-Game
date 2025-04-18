extends TextureButton

class_name PartButton

var part : Part;
var buttonHolder : Control;
var selectGFXon = false;
var mouseOver = false;

func _process(delta):
	#self_modulate = (Color(0, 0, 0, 0))
	#visible = selectGFXon;
	
	pass

func _on_mouse_entered():
	mouseOver = true;
	pass # Replace with function body.


func _on_mouse_exited():
	mouseOver = false;
	pass # Replace with function body.


func _on_pressed():
	#buttonHolder.set_pressed(true);
	pass # Replace with function body.

func select(foo:bool):
	set_pressed_no_signal(foo);


func _on_toggled(toggled_on):
	buttonHolder.set_pressed(toggled_on);
	pass # Replace with function body.
