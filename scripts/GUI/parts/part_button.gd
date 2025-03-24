extends Button

class_name PartButton

var part : Part;
var buttonHolder : Control;
var selectGFXon = false;
var mouseOver = false;

func _process(delta):
	self_modulate = (Color(0, 0, 0, 0))
	$TextureRect.visible = selectGFXon;

func _on_mouse_entered():
	mouseOver = true;
	pass # Replace with function body.


func _on_mouse_exited():
	mouseOver = false;
	pass # Replace with function body.


func _on_pressed():
	print("yellow")
	pass # Replace with function body.
