@icon("res://graphics/images/class_icons/statEditText.png")
extends TextEdit

class_name StatAdjusterText
## Interfaces with [StatAdjusterDataPanel]. The variable name being changed is placed within [member placeholder_text].

var manager : StatAdjusterDataPanel;

func _ready():
	name = placeholder_text;

func _on_value_changed(value):
	manager.adjust_stat_text(self);
	pass # Replace with function body.
