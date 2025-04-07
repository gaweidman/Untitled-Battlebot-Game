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

func _ready():
	spawnPlayer();
	add_enemy_to_spawn_list(load("res://scenes/prefabs/objects/npcs/enemy.tscn"), 1)
	add_enemy_to_spawn_list(load("res://scenes/prefabs/objects/npcs/enemy_thruster.tscn"), 2)
	print(return_random_enemy())
	#return_random_spawn_location()
	

func _process(delta):
	waveTimer -= delta;
	if waveTimer <= 0:
		waveTimer = 10;
		wave += 1;
		var amtAlive = check_alive_enemies()
		print("alive: ", amtAlive)
		var amtToSpawn = max(0, min(6, wave + 2 - amtAlive))
		spawn_wave(amtToSpawn)
	#if spawnChecker.is_colliding():
		#print("HI")
	#return_random_spawn_location()
	pass

func spawnPlayer(_in_position := playerSpawnPosition) -> Node3D:
	var newPlayer = playerScene.instantiate();
	newPlayer.global_position = _in_position;
	add_child(newPlayer);
	return newPlayer;

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
