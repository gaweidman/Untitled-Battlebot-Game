extends Node

# How quickly the player speeds up
var PLAYER_ACCELERATION = 5000;

# how fast enemies can go
var MAX_ENEMY_SPEED = 13

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_player():
	var ply = get_node_or_null("/root/GameBoard/Player")
	
	if ply == null:
		return null;
    
	return ply;

func get_input_handler():
	var ply = get_player();
	
	for child in ply.get_children():
		if child is InputHandler:
			return child;
	return null;
	#var input = 

func get_hud():
	return get_node("/root/GameBoard/HUD");
