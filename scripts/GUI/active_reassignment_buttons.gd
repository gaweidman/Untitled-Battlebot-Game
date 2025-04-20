extends Control

class_name ActiveReassignmentButtonHolder

signal reassignment_button_pressed(slot:int);

func disable(_disabled:bool):
	for button in get_children():
		button.disabled = _disabled;

func _on_slot_0_pressed():
	reassignment_button_pressed.emit(0);
	pass # Replace with function body.

func _on_slot_1_pressed():
	reassignment_button_pressed.emit(1);
	pass # Replace with function body.

func _on_slot_2_pressed():
	reassignment_button_pressed.emit(2);
	pass # Replace with function body.
