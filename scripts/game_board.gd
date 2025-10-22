extends Node3D

class_name GameBoard;

@export var playerSpawnPosition : Vector3;
@export var enemySpawnPositions : Node3D;
@export var enemySpawnList := {};
#@onready var playerScene = preload("res://scenes/prefabs/objects/player.tscn");
@onready var playerScene = preload("res://scenes/prefabs/objects/robots/robot_player.tscn");
@export var spawnChecker : ShapeCast3D;
var spawnTimer := 0.0;
var spawnPool := [];
var waveSpawnList := [];
var waveTimer := 0.0;
var wave := 0;
var roundEnemiesInit := 1;
var roundEnemies := 0;
var round := 0;
var enemiesAlive = [];
var player : Robot_Player;

var enemiesKilled := 0;
var scrapGained := 0;
@export_category("HUD nodes")
#@export var HUD_playerStats : Control;
@export var HUD_mainMenu : Control;
@export var HUD_credits : Control;
@export var HUD_options : Control;
@export var HUD_gameOver : Control;
@export var HUD_player : Control;
@export var MUSIC : MusicHandler;
@export var LIGHT : DirectionalLight3D;

func _ready():
	spawn_player_new_game();
	get_tree().current_scene.ready.connect(_on_scenetree_ready);
	#return_random_spawn_location()
func _on_scenetree_ready():
	Hooks.add(self, "OnDeath", "LifetimeKillCounter", 
		func(thisBot, killer):
			if killer is Player:
				enemiesKilled += 1;
				print_rich("[color=red][b]Enemies killed: ",enemiesKilled)
			)
	Hooks.add(self, "OnGainScrap", "LifetimeScrapCounter", 
		func(source, amt):
			if amt > 0:
				scrapGained += amt;
				print_rich("[color=yellow][b]Scrap gained: ",scrapGained)
			)
	change_state(gameState.MAIN_MENU);

func _process(delta):
	process_state(delta, curState);


############################ WAVES SETUP     TODO: Move a lot of the waves setup code to the individual game maps, when those exist.

func set_enemy_spawn_waves(inWave:int):
	var changed = false;
	if inWave == -1:
		clear_enemy_spawn_list();
		changed = true;
	if inWave == 1:
		add_enemy_to_spawn_list(load("res://scenes/prefabs/objects/robots/robot_test_volley.tscn"), 4)
		add_enemy_to_spawn_list(load("res://scenes/prefabs/objects/robots/robot_test.tscn"), 4)
		#add_enemy_to_spawn_list(load("res://scenes/prefabs/objects/npcs/enemy_ranger.tscn"), 2)
		#add_enemy_to_spawn_list(load("res://scenes/prefabs/objects/npcs/enemy_flash.tscn"), 4)
		#add_enemy_to_spawn_list(load("res://scenes/prefabs/objects/npcs/enemy_thruster.tscn"), 8)
		changed = true;
	if inWave == 2:
		#add_enemy_to_spawn_list(load("res://scenes/prefabs/objects/npcs/enemy_ranger.tscn"), 3)
		changed = true;
	if inWave == 4:
		#add_enemy_to_spawn_list(load("res://scenes/prefabs/objects/npcs/enemy_ranger.tscn"), 2)
		changed = true;
	if inWave == 10:
		#add_enemy_to_spawn_list(load("res://scenes/prefabs/objects/npcs/enemy_soldier.tscn"), 1)
		#add_enemy_to_spawn_list(load("res://scenes/prefabs/objects/npcs/enemy_thruster.tscn"), -3)
		changed = true;
	
	if changed:
		define_enemy_spawn_pool();

func define_enemy_spawn_pool():
	var pool = []
	var spawnListCopy = enemySpawnList.duplicate(true);
	for scene in spawnListCopy.keys():
		var weight = spawnListCopy[scene];
		
		while weight > 0:
			pool.append(scene);
			weight -= 1;
	spawnPool = pool;

func clear_enemy_spawn_list():
	enemySpawnList.clear();

func add_enemy_to_spawn_list(scene : PackedScene, weight : int):
	if scene in enemySpawnList.keys():
		enemySpawnList[scene] += weight;
		if enemySpawnList[scene] && enemySpawnList[scene] <= 0:
			enemySpawnList.erase(scene);
	else:
		enemySpawnList[scene] = weight;

func return_random_enemy():
	var pool = spawnPool;
	var sceneReturn = pool.pick_random();
	return sceneReturn;

################### STATE CONTROL

##Controls the state of the game.
enum gameState {
	START,
	MAIN_MENU,
	INIT_PLAY,
	PLAY,
	GAME_OVER,
	CREDITS,
	OPTIONS,
	SHOP,
	INIT_ROUND,
	BUILD_MODE,
}
var curState := gameState.START

const play_states = [
	GameBoard.gameState.INIT_ROUND,
	GameBoard.gameState.PLAY,
	GameBoard.gameState.SHOP,
]
const build_states = [
	GameBoard.gameState.SHOP,
	GameBoard.gameState.BUILD_MODE,
]
const camera_tilt_states = [
	GameBoard.gameState.SHOP,
	GameBoard.gameState.BUILD_MODE,
]
const game_over_states = [
	GameBoard.gameState.PLAY,
	GameBoard.gameState.SHOP,
]
@export var gameCamera : GameCamera;
func get_main_camera():
	return gameCamera;

func change_state(newState : gameState):
	var changeToDefer = func change(newState):
		if curState != newState:
			exit_state(curState);
			Hooks.OnChangeGameState(curState, newState);
			curState = newState;
			enter_state(newState);
	changeToDefer.call_deferred(newState);

func exit_state(oldState:gameState):
	if oldState == gameState.MAIN_MENU:
		HUD_mainMenu.hide();
		pass
	elif oldState == gameState.GAME_OVER:
		#HUD_playerStats.hide();
		HUD_gameOver.hide();
		pass
	elif oldState == gameState.CREDITS:
		HUD_credits.hide();
		pass
	elif oldState == gameState.OPTIONS:
		HUD_options.open_sesame(false);
		pass
	elif oldState == gameState.PLAY:
		pass
	elif oldState == gameState.SHOP:
		respawn_player()
		pass
	elif oldState == gameState.INIT_ROUND:
		pass
	elif oldState == gameState.START:
		
		HUD_mainMenu.hide();
		HUD_credits.hide();
		HUD_gameOver.hide();
		HUD_options.open_sesame(false);
		MUSIC.play();
		update_lighting();
		pass
	else:
		pass

func enter_state(newState:gameState):
	if newState == gameState.MAIN_MENU:
		HUD_options.load_settings();
		MUSIC.change_state(MusicHandler.musState.MENU);
		
		destroy_all_enemies();
		player.body.global_position = Vector3(0,20,30);
		player.freeze(true);
		HUD_mainMenu.show();
		pass
	elif newState == gameState.GAME_OVER:
		MUSIC.change_state(MusicHandler.musState.GAME_OVER);
		
		HUD_gameOver.show();
		pass
	elif newState == gameState.CREDITS:
		MUSIC.change_state(MusicHandler.musState.CREDITS);
		
		HUD_credits.show();
		pass
	elif newState == gameState.OPTIONS:
		MUSIC.change_state(MusicHandler.musState.OPTIONS);
		
		HUD_options.open_sesame(true);
		pass
	elif newState == gameState.INIT_PLAY:
		
		MUSIC.change_state(MusicHandler.musState.SHOP);
		
		GameState.start_death_timer(120.0,true)
		round = 0;
		roundEnemiesInit = 1;
		clear_enemy_spawn_list();
		scrapGained = 0;
		enemiesKilled = 0;
		
		spawn_player_new_game(return_random_unoccupied_spawn_location());
		player.start_new_game();
		#player.inventory.show();
		change_state(gameState.INIT_ROUND);
		
		pass
	elif newState == gameState.PLAY:
		pass
	elif newState == gameState.SHOP:
		MUSIC.change_state(MusicHandler.musState.SHOP);
		
		player.end_round();
		move_player_to_workshop();
		player.enter_shop();
		pass
	elif newState == gameState.INIT_ROUND:
		MUSIC.change_state(MusicHandler.musState.PREGAME);
		
		round += 1;
		set_enemy_spawn_waves(round);
		#player.start_round();
		waveTimer = 3;
		wave = 0;
		roundEnemiesInit += 2;
		roundEnemies = roundEnemiesInit;
		change_state(gameState.PLAY);
		pass
	else:
		pass

func process_state(delta : float, state : gameState):
	if curState == gameState.MAIN_MENU:
		pass
	elif curState == gameState.GAME_OVER:
		pass
	elif curState == gameState.CREDITS:
		pass
	elif curState == gameState.PLAY:
		#waveTimer = 10
		#spawnTimer = 10
		if GameState.get_setting("killAllKey") and Input.is_action_just_pressed("DBG_KillAll"):
			destroy_all_enemies()
		
		if not GameState.is_paused():
			waveTimer -= delta;
			spawnTimer -= delta;
		
		if roundEnemies > 0:
			if waveTimer <= 0:
				waveTimer = 10;
				wave += 1;
				var amtAlive = check_alive_enemies()
				#print("alive: ", amtAlive)
				var amtToSpawn = max(0, min(3+round,10,roundEnemies))
				#var amtToSpawn = max(0, min(1, 1 - amtAlive))
				#print(amtToSpawn, amtAlive)
				spawn_wave(amtToSpawn)
				MUSIC.change_state(MusicHandler.musState.BATTLING);
		
		if spawnTimer <= 0:
			spawn_enemy_from_wave();
			
			if get_enemies_left_for_wave() <= 0:
				change_state(gameState.SHOP);
			else:
				spawnTimer=0.15;
		
		pass
	elif curState == gameState.SHOP:
		pass
	elif curState == gameState.INIT_ROUND:
		pass
	else:
		pass
	pass

func update_lighting():
	LIGHT.shadow_enabled = GameState.get_setting("renderShadows");

##returns true if we're in a state that might be considered a part of the game loop.
func in_state_of_play()->bool:
	return in_one_of_given_states(play_states);

##returns true if we're in a state where build-a-bot mode is activated.
func in_state_of_building()->bool:
	return in_one_of_given_states(build_states);

func in_game_over_state()->bool:
	return in_one_of_given_states(game_over_states) and player.aliveLastFrame;

func in_one_of_given_states(states:Array)->bool:
	var currentState = GameState.get_game_board_state();
	return currentState in states;


#################### ENTITY SPAWNING 

@export var inspectorHUD : Inspector;
@export var stashHUD : PieceStash;
@export var abilityHUD : AbilitySlotManager;

func spawn_player_new_game(_in_position := playerSpawnPosition) -> Node3D:
	if player != null:
		#player.body.position = _in_position;
		player.body.set_deferred("position", _in_position)
	else:
		var newPlayer = playerScene.instantiate();
		add_child(newPlayer);
		newPlayer.global_position = _in_position;
		player = newPlayer;
	
	player.queue_live();
	stashHUD.currentRobot = player;
	player.inspectorHUD = inspectorHUD;
	abilityHUD.currentRobot = player;
	stashHUD.regenerate_list();
	
	return player;

func teleport_player(_in_position := playerSpawnPosition):
	if player != null:
		#player.body.position = _in_position;
		player.body.set_deferred("position", _in_position);

func respawn_player():
	teleport_player(return_random_unoccupied_spawn_location());

##Returns a spawn location that isn't occupied by the player
func return_random_unoccupied_spawn_location():
	var locations = enemySpawnPositions.get_children();
	locations.shuffle()
	for location in locations:
		var spawnChecker = location;
		var goodToReturn = true
		if spawnChecker.is_colliding():
			for result in spawnChecker.collision_result:
				if result.collider is RigidBody3D:
					goodToReturn = false;
		if goodToReturn:
			return location.global_position;
		
		pass
	return null;

func spawn_wave(numOfEnemies := 0):
	#return
	while numOfEnemies > 0 && roundEnemies > 0 && check_alive_enemies() <= 30:
		var enemyScene = return_random_enemy();
		var pos = return_random_unoccupied_spawn_location();
		waveSpawnList.append(enemyScene)
		numOfEnemies -= 1;

var enemySpawnerRef := preload("res://scenes/prefabs/objects/enemy_spawner.tscn");
func spawn_enemy_from_wave():
	if waveSpawnList.size() > 0:
		var pos = return_random_unoccupied_spawn_location();
		if pos != null:
			var enemyScene = waveSpawnList.pop_front();
			var newEnemySpawner : RobotSpawner = enemySpawnerRef.instantiate();
			newEnemySpawner.assign_gameBoard(self);
			add_child(newEnemySpawner);
			newEnemySpawner.assign_enemy_type_from_resource(enemyScene);
			var enemy = newEnemySpawner.start_spawn(pos);
			enemiesAlive.append(enemy);
			roundEnemies -= 1;

func check_alive_enemies():
	for enemy in enemiesAlive:
		var _continue = true
		if enemy == null && _continue:
			enemiesAlive.erase(enemy);
			_continue = false
		if _continue:
			var checkedEnemy = get_node_or_null(enemy.get_path())
			if checkedEnemy.spawned == false:
				_continue = false;
		if _continue:
			var checkedEnemy = get_node_or_null(enemy.get_path())
			if checkedEnemy == null:
				enemiesAlive.erase(enemy);
	return enemiesAlive.size();

##Should give us the amount of enemies left after all spawning is completed
func check_round_completion() -> float:
	#print("Round enemies: ",roundEnemies);
	#print("Alive enemies: ",check_alive_enemies());
	#print("Initial round enemies: ",roundEnemiesInit);
	return float(get_enemies_left_for_wave()) / float(roundEnemiesInit);

func get_enemies_left_for_wave() -> int:
	return roundEnemies + check_alive_enemies();

func destroy_all_enemies():
	check_alive_enemies();
	for enemy in enemiesAlive:
		if enemy:
			enemy.call_deferred("die");

##Run only when GameState.pause() is called.
func pause(foo : bool):
	pause_all_robots_and_projectiles(foo);
	##TODO: Add in other pause functions for things like projectiles and stuff.

##Pauses all robots specifically.
func pause_all_robots_and_projectiles(foo : bool):
	print("Pausing all FreezableEntities: ", str(foo))
	for robot in Utils.get_all_children_of_type(self, FreezableEntity):
		print(robot)
		if robot is FreezableEntity:
			robot.pause(foo, true);

##Fired when the game is over.
func game_over():
	if not in_game_over_state(): return;
	var devCheatsEnabled = GameState.get_setting("devMode")
	if not devCheatsEnabled:
		var saveData = GameState.save_high_scores(GameState.get_round_number(), enemiesKilled, scrapGained)
		var highScoreRound = saveData["highScoreRound"]
		var highScoreKills = saveData["highScoreKills"]
		var highScoreScrap = saveData["highScoreScrap"]
		%GameOverStats.clear();
		%GameOverStats.append_text("[i][b]STATS[/b]");
		%GameOverStats.newline();
		if highScoreRound:
			%GameOverStats.append_text("[color=ff0000]")
		%GameOverStats.append_text("HIGHEST ROUND: " + str(GameState.get_round_number()));
		if highScoreRound:
			%GameOverStats.append_text(" ![/color]")
		%GameOverStats.newline();
		if highScoreKills:
			%GameOverStats.append_text("[color=ff0000]")
		%GameOverStats.append_text("ENEMIES KILLED: " + str(enemiesKilled));
		if highScoreKills:
			%GameOverStats.append_text(" ![/color]")
		%GameOverStats.newline();
		if highScoreScrap:
			%GameOverStats.append_text("[color=ff0000]")
		%GameOverStats.append_text("SCRAP GAINED: " + str(scrapGained));
		if highScoreScrap:
			%GameOverStats.append_text(" ![/color]")
		if highScoreRound or highScoreKills or highScoreScrap:
			%GameOverStats.newline();
			%GameOverStats.append_text("! NEW HIGH SCORE !");
	else:
		%GameOverStats.clear();
		%GameOverStats.append_text("[i][b]STATS[/b]");
		%GameOverStats.newline();
		%GameOverStats.append_text("HIGHEST ROUND: " + str(GameState.get_round_number()));
		%GameOverStats.newline();
		%GameOverStats.append_text("ENEMIES KILLED: " + str(enemiesKilled));
		%GameOverStats.newline();
		%GameOverStats.append_text("SCRAP GAINED: " + str(scrapGained));
		%GameOverStats.newline();
		%GameOverStats.append_text("[color=ff0000]( HIGH SCORES DISABLED BY CHEATS )[/color]");
	change_state(gameState.GAME_OVER);

@export var workshopArea : Node3D;
func move_player_to_workshop():
	teleport_player(workshopArea.global_position);

############## BUTTON CALLS
func _on_btn_play_pressed():
	change_state(gameState.INIT_PLAY);
	pass # Replace with function body.
func _on_btn_menu_pressed():
	change_state(gameState.MAIN_MENU);
	pass # Replace with function body.
func _on_btn_credits_pressed():
	change_state(gameState.CREDITS);
	pass # Replace with function body.
func _on_btn_exit_pressed():
	GameState.quit_game();
	pass # Replace with function body.
func _on_btn_end_run_pressed():
	player.die();
	pass # Replace with function body.
func _on_btn_options_pressed():
	change_state(gameState.OPTIONS);
	pass # Replace with function body.


######################### DEATH TIMER MGMT
@export var deathTimer : DeathTimer;

func get_death_timer() -> DeathTimer:
	return deathTimer;


func _on_btn_editor_pressed():
	GameState.editor_mode_start();
	pass # Replace with function body.
