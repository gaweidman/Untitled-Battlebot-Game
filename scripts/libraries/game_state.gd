extends Node

# How quickly the player speeds up
var PLAYER_ACCELERATION = 6000;

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

func game_over():
	var board = get_game_board();
	
	if is_instance_valid(board):
		board.game_over();

func get_player() -> Player:
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

func is_player_alive():
	var CH = get_combat_handler();
	
	if is_instance_valid(CH):
		return CH.is_alive();
	return false;

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

func get_combat_handler() -> CombatHandlerPlayer:
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

func get_camera() -> Camera:
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

var partAge := 0;

func get_unique_part_age() -> int:
	var ret = partAge;
	partAge += 1;
	return ret;

static var settings := {
	StringName("inventoryDisableShooting") : true,
	StringName("sawbladeDrone") : true,
	StringName("devMode") : false,
	StringName("startingScrap") : 0,
	StringName("godMode") : false,
}

func set_setting(settingName : StringName, settinginput : Variant):
	push_warning("Attempt to set setting ", settingName, " to a value of ", (settinginput));
	var setting = get_setting(settingName);
	if setting != null:
		if typeof(setting) == typeof(settinginput):
			print (settings.has(StringName(settingName)))
			settings[settingName] = settinginput;
			pass
		else:
			push_warning("Attempt to set setting ", settingName, " to a value of the invalid type ", type_string(settinginput), ". Should be ", type_string(setting));
	
	print(get_setting(settingName));

func get_setting(settingName : StringName):
	if settings.has(settingName):
		var setting = settings[settingName];
		return setting;
	push_warning("Attempted to access invalid setting ", settingName, " ");
	return null;
