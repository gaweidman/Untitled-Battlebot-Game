extends Control

class_name ButtonHolder;

var part : Part;
@export var buttonPrefab : PackedScene;
var selected;

signal on_select(foo:bool)

func _process(delta):
	selected = false;
	#return; ##Delete this return for final, this just makes the parts invisible for now
	for button in get_children():
		if button.button_pressed:
			selected = true;
		if button.mouseOver:
			selected = true;
	
	for button in get_children():
		button.selectGFXon = selected;

func set_pressed(foo:bool):
	for button in get_children():
		button.select(foo);
	
	on_select.emit(foo);

func disable():
	for button in get_children():
		button.disabled = true;
