extends Control

class_name ButtonHolder;

var part : Part;
@export var buttonPrefab : PackedScene;
var selected;

func _process(delta):
	selected = false;
	return; ##Delete this return for final, this just makes the parts invisible for now
	for button in get_children():
		if button.button_pressed:
			selected = true;
		if button.mouseOver:
			selected = true;
	
	for button in get_children():
		button.selectGFXon = selected;
