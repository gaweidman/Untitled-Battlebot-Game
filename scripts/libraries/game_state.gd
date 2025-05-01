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
	if is_instance_valid(board):
		return board.in_state_of_play();
	else:
		return false;

func set_game_board_state(state : GameBoard.gameState):
	var board = get_game_board();
	
	if board != null:
		board.change_state(state);

func get_player():
	var ply = get_node_or_null("/root/GameBoard/Player")
	
	if ply == null:
		return null;
	
	return ply;

func get_player_body() -> RigidBody3D:
	var ply = get_player()
	
	if is_instance_valid(ply):
		return ply.get_node_or_null("Body");
	return null;

func get_player_position():
	var bdy = get_player_body();
	
	if is_instance_valid(bdy):
		return bdy.global_position;
	return Vector3(0,0,0);

func get_player_pos_offset(inGlobalPosition: Vector3):
	var pos = get_player_position();
	return pos - inGlobalPosition;

func get_len_to_player(inGlobalPosition: Vector3):
	var offset = get_player_pos_offset(inGlobalPosition);
	
	var lenToPlayer = offset.length();
	
	return lenToPlayer;

func is_player_in_range(inGlobalPosition:Vector3, range:float):
	var lenToPLayer = get_len_to_player(inGlobalPosition);
	
	return lenToPLayer <= range;

func get_player_body_mesh():
	var bdy = get_player_body();
	
	if is_instance_valid(bdy):
		return bdy.get_node_or_null("BotBody");
	return null;

func get_input_handler():
	var ply = get_player();
	
	if is_instance_valid(ply):
		return ply.get_node_or_null("InputHandler");
	return null;

func get_combat_handler():
	var ply = get_player();
	
	if is_instance_valid(ply):
		return ply.get_node_or_null("CombatHandler");
	return null;

func get_hud():
	return get_node("/root/GameBoard/HUD");

func get_inventory() -> InventoryPlayer:
	var ply = get_player();
	
	if is_instance_valid(ply):
		return ply.get_node_or_null("Inventory");
	return null;

func get_death_timer() -> DeathTimer:
	var ply = get_player();
	
	if is_instance_valid(ply):
		return ply.get_node_or_null("Inventory/InventoryControls/BackingTexture/Lbl_Timer");
	return null;

func add_death_time(time:float):
	var tmr = get_death_timer();
	
	tmr.add_time(time);

func pause_death_timer(paused:=true):
	var tmr = get_death_timer();
	
	tmr.pause(paused);

func start_death_timer(_startTime := 120.0, _reset := false):
	var tmr = get_death_timer();
	
	tmr.start(_startTime, _reset)

func get_camera() -> Camera3D:
	var brd = get_game_board();
	
	return brd.get_node_or_null("Camera3D")

func cam_unproject_position(world_point:Vector3) -> Vector2:
	var cam = get_camera();
	
	return cam.unproject_position(world_point);

func get_music() -> MusicHandler:
	var board = get_game_board();
	
	if board != null:
		return board.get_node_or_null("BGM2");
	return null;

func get_physical_sound_manager() -> SND:
	var board = get_game_board();
	
	if board != null:
		return board.get_node_or_null("SoundManager");
	return null;

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
			if node.get("theme_override_colors/font_color") != color:
				node.set_deferred("theme_override_colors/font_color", color);
		else:
			if color is String:
				var newCol := Color(textColors["white"]);
				if color in textColors:
					newCol = Color(textColors[color]);
				else:
					newCol = Color(color);
				if node.get("theme_override_colors/font_color") != newCol:
					node.set_deferred("theme_override_colors/font_color", newCol);
