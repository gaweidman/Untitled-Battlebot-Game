extends Node3D

class_name RobotSpawner

var enemyTypeToSpawn := preload("res://scenes/robots/buildingBlocks/robot_base.tscn");
var gameBoard : GameBoard;
var newEnemy : Node3D;
var timerLength := 1.0;

func spawn_enemy():
	#newEnemy.global_position = global_position;
	#if not newEnemy.pr
	if is_instance_valid(newEnemy):
		newEnemy.live();
	queue_free();

func assign_enemy_type_from_string_path(inPath : String):
	enemyTypeToSpawn = load(inPath);
func assign_enemy_type_from_resource(inPath : Resource):
	enemyTypeToSpawn = inPath;

func start_spawn(pos := Vector3(0,0,0), time: float = 1):
	#Start the timer.
	timerLength = time;
	global_position = pos;
	newEnemy = enemyTypeToSpawn.instantiate();
	gameBoard.add_child(newEnemy);
	newEnemy.hide();
	newEnemy.freeze();
	newEnemy.global_position = global_position + Vector3(0,0.5,0);
	newEnemy.sleepTimer += time;
	return newEnemy;

##Enemy spawns whent he timer runs out.
func _physics_process(delta):
	timerLength -= delta;
	if timerLength <= 0:
		spawn_enemy();

func assign_gameBoard(newBoard : GameBoard):
	gameBoard = newBoard;
