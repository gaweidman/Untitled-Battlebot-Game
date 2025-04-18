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

func get_game_board():
	var board = get_node_or_null("/root/GameBoard")
	
	if board == null:
		return null;
	
	return board;

func get_game_board_state():
	var board = get_game_board();
	
	if board == null:
		return null;
	
	return board.curState;

func set_game_board_state(state : GameBoard.gameState):
	var board = get_game_board();
	
	if board != null:
		board.change_state(state);

func get_player():
	var ply = get_node_or_null("/root/GameBoard/Player")
	
	if ply == null:
		return null;
	
	return ply;

func get_player_body():
	var ply = get_player()
	
	return ply.get_node_or_null("Body");

func get_player_body_mesh():
	var bdy = get_player_body()
	
	return bdy.get_node_or_null("BotBody");

func get_input_handler():
	var ply = get_player();
	
	return ply.get_node_or_null("InputHandler");

func get_combat_handler():
	var ply = get_player();
	
	return ply.get_node_or_null("CombatHandler");

func get_hud():
	return get_node("/root/GameBoard/HUD");

func get_inventory() -> InventoryPlayer:
	var ply = get_player();
	
	return ply.get_node_or_null("Inventory");
