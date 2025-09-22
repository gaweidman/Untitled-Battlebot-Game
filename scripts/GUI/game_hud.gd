extends Control

class_name GameHUD

@export var panelLeft : TextureRect;
@export var panelRight : TextureRect;

var panelsVisible := false;

func _ready():
	#panelLeft.position.x = -576;
	#panelLeft.show();
	#panelRight.position.x = 960.0 + 576;
	#panelRight.show();
	pass;


func _process(delta):
	
	##Move the two panels into view if we're playing the game.
	panelsVisible = GameState.get_in_state_of_play() or GameState.get_in_state_of_building();
	#if panelsVisible:
		#panelLeft.position.x = lerp(panelLeft.position.x, 0.0, delta * 10);
		#panelRight.position.x = lerp(panelRight.position.x, 960.0, delta * 10);
	#else:
		#panelLeft.position.x = lerp(panelLeft.position.x, -576.0, delta * 10);
		#panelRight.position.x = lerp(panelRight.position.x, 960.0 + 576, delta * 10);

func slow_update():
	pass;
