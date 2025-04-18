extends Node3D

class_name GameBoard;

@export var playerSpawnPosition : Vector3;
@export var enemySpawnPositions : Node3D;
@export var enemySpawnList := {};
@onready var playerScene = preload("res://scenes/prefabs/objects/player.tscn");
@export var spawnChecker : ShapeCast3D;
var waveTimer := 0.0;
var wave := 0;
var enemiesAlive = [];
var player : Player;
@export_category("HUD nodes")
@export var HUD_playerStats : Control;
@export var HUD_mainMenu : Control;
@export var HUD_credits : Control;
@export var HUD_gameOver : Control;

func _ready():
	spawnPlayer();
	add_enemy_to_spawn_list(load("res://scenes/prefabs/objects/npcs/enemy.tscn"), 1)
	add_enemy_to_spawn_list(load("res://scenes/prefabs/objects/npcs/enemy_thruster.tscn"), 2)
	change_state(gameState.MAIN_MENU);
	#return_random_spawn_location()

##State stuff
enum gameState {
	START,
	MAIN_MENU,
	INIT_PLAY,
	PLAY,
	GAME_OVER,
	CREDITS,
}
var curState := gameState.START
func change_state(newState : gameState):
	if curState != newState:
		exit_state(curState);
		curState = newState;
		enter_state(newState);

func exit_state(state:gameState):
	if state == gameState.MAIN_MENU:
		HUD_mainMenu.hide();
		pass
	elif state == gameState.GAME_OVER:
		HUD_playerStats.hide();
		HUD_gameOver.hide();
		pass
	elif state == gameState.CREDITS:
		HUD_credits.hide();
		pass
	elif state == gameState.PLAY:
		pass
	else:
		pass

func enter_state(state:gameState):
	if state == gameState.MAIN_MENU:
		destroy_all_enemies();
		HUD_mainMenu.show();
		pass
	elif state == gameState.GAME_OVER:
		HUD_gameOver.show();
		pass
	elif state == gameState.CREDITS:
		HUD_credits.show();
		pass
	elif state == gameState.INIT_PLAY:
		waveTimer = 0;
		wave = 0;
		spawnPlayer(return_random_unoccupied_spawn_location());
		player.live();
		HUD_playerStats.show();
		change_state(gameState.PLAY)
		pass
	elif state == gameState.PLAY:
		pass
	else:
		pass

func _process(delta):
	if curState == gameState.MAIN_MENU:
		pass
	elif curState == gameState.GAME_OVER:
		pass
	elif curState == gameState.CREDITS:
		pass
	elif curState == gameState.PLAY:
		waveTimer -= delta;
		if waveTimer <= 0:
			waveTimer = 10;
			wave += 1;
			var amtAlive = check_alive_enemies()
			#print("alive: ", amtAlive)
			var amtToSpawn = max(0, min(6, wave + 2 - amtAlive))
			spawn_wave(amtToSpawn)
		pass
	else:
		pass
	pass

func spawnPlayer(_in_position := playerSpawnPosition) -> Node3D:
	if player != null:
		print("PLyaer already exist,s ", _in_position)
		print(player.body.position)
		#player.body.position = _in_position;
		player.body.set_deferred("position", _in_position)
	else:
		var newPlayer = playerScene.instantiate();
		newPlayer.global_position = _in_position;
		add_child(newPlayer);
		player = newPlayer;
	
	return player;

func add_enemy_to_spawn_list(scene : PackedScene, weight : int):
	if scene in enemySpawnList.keys():
		enemySpawnList[scene] += weight;
		if enemySpawnList[scene] && enemySpawnList[scene] <= 0:
			enemySpawnList.erase(scene);
	else:
		enemySpawnList[scene] = weight;

func return_random_enemy():
	var pool = []
	var spawnListCopy = enemySpawnList.duplicate(true);
	for scene in spawnListCopy.keys():
		var weight = spawnListCopy[scene];
		
		while weight > 0:
			pool.append(scene);
			weight -= 1;
	
	var sceneReturn = pool.pick_random();
	return sceneReturn;

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
	while numOfEnemies > 0:
		var enemyScene = return_random_enemy();
		var pos = return_random_unoccupied_spawn_location();
		if pos != null:
			var enemy = enemyScene.instantiate();
			enemy.global_position = pos;
			enemiesAlive.append(enemy);
			add_child(enemy);
		else:
			print("no available positions")
			numOfEnemies = 0;
		numOfEnemies -= 1;

func check_alive_enemies():
	for enemy in enemiesAlive:
		var _continue = true
		if enemy == null && _continue:
			enemiesAlive.erase(enemy);
			_continue = false
		if _continue:
			var checkedEnemy = get_node_or_null(enemy.get_path())
			if checkedEnemy == null:
				enemiesAlive.erase(enemy);
	return enemiesAlive.size();

func destroy_all_enemies():
	check_alive_enemies();
	for enemy in enemiesAlive:
		if enemy:
			enemy.call_deferred("die");

##Button calls
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
	get_tree().quit();
	pass # Replace with function body.
