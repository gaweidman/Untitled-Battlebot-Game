extends Node

# How quickly the player comes to a stop
var PLAYER_DECELERATION = 70;

# How quickly the player speeds up
var PLAYER_ACCELERATION = 120;

# the acceleration of gravity
var GRAVITY = 9.81

# how fast enemies can go
var MAX_ENEMY_SPEED = 13

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_player():
	return get_node("/root/GameBoard/Player");
