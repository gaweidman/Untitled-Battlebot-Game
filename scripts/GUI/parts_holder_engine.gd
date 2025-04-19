extends Control

class_name PartsHolder_Engine

signal buttonPressed(x:int,y:int);

func disable(disabled:bool):
	for child in get_children():
		if child is PartHolderButton:
			child.disable(disabled);
