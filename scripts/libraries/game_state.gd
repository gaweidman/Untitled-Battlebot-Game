extends Node

# How quickly the player speeds up
var PLAYER_ACCELERATION = 6000;

# how fast enemies can go
var MAX_ENEMY_SPEED = 13

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings();
	load_data();
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func quit_game():
	save_settings();
	get_tree().quit();

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
func get_in_state_of_building() ->bool:
	var board = get_game_board();
	if is_instance_valid(board):
		return board.in_state_of_building();
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

func get_player() -> Robot_Player:
	var ply = get_node_or_null("/root/GameBoard/Robot_Player")
	
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
	var board = get_game_board();
	
	if board != null:
		return board.get_node_or_null("HUDCanvas/HUD Viewport/SubViewport/HUD");

func get_game_hud() -> GameHUD:
	var hud = get_hud();
	
	if hud != null:
		#print("aa")
		return hud.get_node_or_null("GameHud");
	return null;

func get_bar_hp() -> healthBar:
	var ghud = get_game_hud();
	
	if ghud != null:
		return ghud.get_node_or_null("LeftSide/HealthBar");
	return null;

func get_bar_energy() -> healthBar:
	var ghud = get_game_hud();
	
	if ghud != null:
		return ghud.get_node_or_null("RightSide/EnergyBar");
	return null;

func get_engine_viewer() -> PartsHolder_Engine:
	var ghud = get_game_hud();
	
	if ghud != null:
		return ghud.get_node_or_null("LeftSide/PartsHolder_Engine");
	return null;


func get_inventory() -> InventoryPlayer:
	var ply = get_player();
	
	if is_instance_valid(ply):
		return ply.get_node_or_null("Inventory");
	return null;

func get_death_timer() -> DeathTimer:
	var board = get_game_board();
	
	if board != null:
		return board.get_death_timer();
	return null;

func add_death_time(time:float):
	var tmr = get_death_timer();
	
	if tmr != null:
		tmr.add_time(time);

func pause_death_timer(paused:=true):
	var tmr = get_death_timer();
	
	if tmr != null:
		tmr.pause(paused);

func start_death_timer(_startTime := 120.0, _reset := false):
	var tmr = get_death_timer();
	
	if tmr != null:
		tmr.start(_startTime, _reset)

func get_death_time() -> float:
	var tmr = get_death_timer();
	
	if tmr != null:
		tmr.get_time();
	return -999.0;

func get_camera() -> Camera:
	var brd = get_game_board();
	
	return brd.get_main_camera();

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

var statID := 0;

func get_unique_stat_id() -> int:
	var ret = statID;
	statID += 1;
	return ret;

############ SETTINGS AND SAVE DATA

static var settings := {
	StringName("volumeLevelMusic") : 1.0,
	StringName("volumeLevelUI") : 0.8,
	StringName("volumeLevelWorld") : 0.9,
	StringName("volumeLevelMaster") : 1.0,
	
	StringName("inventoryDisableShooting") : true,
	StringName("sawbladeDrone") : true,
	
	StringName("devMode") : false,
	StringName("startingScrap") : 0,
	StringName("godMode") : false,
	StringName("killAllKey") : false,
	
	StringName("renderShadows") : true,
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
	save_settings();

func get_setting(settingName : StringName):
	if settings.has(settingName):
		var setting = settings[settingName];
		return setting;
	push_warning("Attempted to access invalid setting ", settingName, " ");
	return null;

func save_settings():
	var file = FileAccess.open("user://settings.dat", FileAccess.WRITE)
	file.store_var(settings)
	file.flush()
	prints("[b]Saving settings.")

func load_settings():
	if not FileAccess.file_exists("user://settings.dat"):
		save_settings()
	
	var file = FileAccess.open("user://settings.dat", FileAccess.READ )
	var content : Dictionary = file.get_var()
	
	if content != null:
		for key in content.keys():
			if key in settings:
				settings[key] = content[key]
				print("setting key found: ", key, " ", content[key])
			pass
	file.close()
	
	prints("[b]Loading settings: ", settings)
	return settings

static var saveData = {
	StringName("Highest Round") : 0,
	StringName("Most Enemies Killed") : 0,
	StringName("Most Scrap Earned") : 0,
	}

func reset_data():
	saveData = {
	StringName("Highest Round") : 0,
	StringName("Most Enemies Killed") : 0,
	StringName("Most Scrap Earned") : 0,
	};
	save_data();

func save_data():
	var file = FileAccess.open("user://savedata.dat", FileAccess.WRITE)
	file.store_var(saveData)
	file.flush()

func save_high_scores(roundNum, enemiesKilled, scrapGained):
	var highScoreRound = false
	if saveData[StringName("Highest Round")] < roundNum:
		saveData[StringName("Highest Round")] = roundNum
		highScoreRound = true
	
	var highScoreKills = false
	if saveData[StringName("Most Enemies Killed")] < enemiesKilled:
		saveData[StringName("Most Enemies Killed")] = enemiesKilled
		highScoreKills = true
	
	var highScoreScrap = false
	if saveData[StringName("Most Scrap Earned")] < scrapGained:
		saveData[StringName("Most Scrap Earned")] = scrapGained
		highScoreScrap = true
	
	save_data();
	
	return { 
		"highScoreRound":highScoreRound, 
		"highScoreKills":highScoreKills, 
		"highScoreScrap":highScoreScrap
		};

func load_data():
	if not FileAccess.file_exists("user://savedata.dat"):
		reset_data()
	
	var file = FileAccess.open("user://savedata.dat", FileAccess.READ )
	var content : Dictionary = file.get_var()
	
	if content != null:
		for key in content.keys():
			if key in saveData:
				saveData[key] = content[key]
				print("data key found: ", key, " ", content[key])
			pass
	
	file.close()
	
	prints("[b]Loading data: ", saveData)
	
	return saveData

############ STATE CONTROL
var paused := false;

func pause(foo : bool = not paused):
	print("GameState.pause() attempt. New: ", str(foo), " Old: ", str(paused))
	if paused == foo: return;
	print("GameState.pause() attempt was successful.")
	paused = foo;
	var board = get_game_board();
	print(board)
	if board != null: board.pause(paused);

func is_paused():
	return paused;







func editor_mode_start():
	get_tree().change_scene_to_file("res://makers/piece_helper.tscn");
