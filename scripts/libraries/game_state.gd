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

func get_game_board() -> GameBoard:
	var board = get_node_or_null("/root/GameBoard")
	
	if board == null:
		return null;
	
	return board;

func get_game_board_state():
	var board = get_game_board();
	
	if board == null:
		return null;
	
	return board.curState;

func get_round_number():
	var board = get_game_board();
	
	return board.round;

func get_round_completion():
	var board = get_game_board();
	
	return board.check_round_completion();

func get_wave_enemies_left():
	var board = get_game_board();
	
	return board.get_enemies_left_for_wave();

func get_in_state_of_play() ->bool:
	var board = get_game_board();
	
	return board.in_state_of_play();

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

func get_player_position():
	var bdy = get_player_body();
	
	return bdy.global_position;

func get_player_pos_offset(inGlobalPosition: Vector3):
	var pos = get_player_position();
	return pos - inGlobalPosition;

func get_player_body_mesh():
	var bdy = get_player_body();
	
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

func get_death_timer() -> DeathTimer:
	var ply = get_player();
	
	return ply.get_node_or_null("Inventory/InventoryControls/BackingTexture/Lbl_Timer");

func add_death_time(time:float):
	var tmr = get_death_timer();
	
	tmr.add_time(time);

func pause_death_timer(paused:=true):
	var tmr = get_death_timer();
	
	tmr.pause(paused);

func start_death_timer(_startTime := 120.0, _reset := false):
	var tmr = get_death_timer();
	
	tmr.start(_startTime, _reset)

# Colors for text.
const textColors = {
	"white" : Color("ffffff"),
	"grey" : Color("e0dede"),
	"utility" : Color("aae05b"),
	"ranged" : Color("789be9"),
	"melee" : Color("ff6e49"),
	"scrap" : Color("f2ec6b"),
	"red" : Color("cf2121"),
	"unaffordable" : Color("ff0000"),
	"inaffordable" : Color("ff0000"),
}

static func set_text_color(node, color):
	if is_instance_valid(node):
		if color is Color:
			node.set_deferred("theme_override_colors/font_color", color);
		else:
			if color is String:
				var newCol := Color(textColors["white"]);
				if color in textColors:
					newCol = Color(textColors[color]);
				else:
					newCol = Color(color);
				node.set_deferred("theme_override_colors/font_color", newCol);
