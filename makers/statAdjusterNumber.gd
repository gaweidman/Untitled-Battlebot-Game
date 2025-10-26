@icon("res://graphics/images/class_icons/statEditNumber.png")
extends SpinBox

class_name StatAdjusterNumber
## Interfaces with [StatAdjusterDataPanel]. The variable name being changed is placed within [member suffix].

var manager : StatAdjusterDataPanel;

func _ready():
	name = suffix;

func _on_value_changed(value):
	manager.adjust_stat_number(self);
	pass # Replace with function body.
