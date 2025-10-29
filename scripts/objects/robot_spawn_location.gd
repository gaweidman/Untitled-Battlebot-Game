@icon("res://graphics/images/class_icons/spawnLocation.png")
extends Node3D

class_name RobotSpawnLocation

var cast : ShapeCast3D;
var decal : Decal;
var is_ready = false;
@export var casterShape = preload("res://scenes/prefabs/arenas/spawningLocationRayShape.tres");
@export var decalTexture = preload("res://graphics/images/HUD/enemyPing.png");

func _ready():
	var newCast = ShapeCast3D.new();
	newCast.shape = casterShape;
	add_child(newCast);
	cast = newCast;
	
	var newDecal = Decal.new();
	newDecal.size = Vector3(3,0.75,3);
	newDecal.texture_albedo = decalTexture;
	add_child(newDecal);
	decal = newDecal;
	decal.position.y = -0.5;
	
	is_ready = true;

func check_is_unoccupied() -> bool:
	if !is_ready: return false;
	if newEnemy != null: return false;
	if !is_instance_valid(cast): return false;
	
	#cast.force_shapecast_update();
	if cast.is_colliding():
		for result in cast.collision_result:
			if result.collider is RobotBody:
				return false;
	return true;


var enemyTypeToSpawn := preload("res://scenes/prefabs/objects/robots/robot_test.tscn");
var gameBoard : GameBoard;
var newEnemy : Node3D;
var timer := 0.0;
var timerLength := 1.0;
var forceTimerLength := 5.0;

func spawn_enemy():
	if is_instance_valid(newEnemy):
		if newEnemy is Combatant:
			newEnemy.live();
		if newEnemy is Robot:
			gameBoard.add_child(newEnemy);
			newEnemy.global_position = global_position + Vector3(0,0.5,0);
			newEnemy.queue_live();
	newEnemy = null;

func assign_enemy_type_from_string_path(inPath : String):
	enemyTypeToSpawn = load(inPath);
func assign_enemy_type_from_resource(inPath : Resource):
	enemyTypeToSpawn = inPath;

func start_spawn(time: float = 1):
	ParticleFX.play("SpawnerFX", GameState.get_game_board(), self.global_position, 1.0, self);
	timerLength = time;
	newEnemy = enemyTypeToSpawn.instantiate();
	newEnemy.sleepTimer += time;
	timer = 0;
	return newEnemy;

##Enemy spawns whent he timer runs out.
func _physics_process(delta):
	if not GameState.is_paused():
		if newEnemy != null:
			timer += delta;
			if timerLength > 0:
				if timer > forceTimerLength:
					spawn_enemy();
				else:
					if check_is_unoccupied():
						spawn_enemy();

func assign_gameBoard(newBoard : GameBoard):
	gameBoard = newBoard;
