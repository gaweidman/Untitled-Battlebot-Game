extends Button

class_name BuildModeControlsButton

var explanationHidden := false;

func _process(delta):
	visible =  GameState.get_in_state_of_building();
	
	explanationHidden = button_pressed;
	
	$Controls.visible = ! explanationHidden;
	text = "SHOW CONTROLS" if explanationHidden else "HIDE CONTROLS";
