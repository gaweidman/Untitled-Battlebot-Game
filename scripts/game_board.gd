extends Node3D

class_name GameBoard;

@export var playerSpawnPosition : Vector3;
@export var enemySpawnPositions : Array[Vector3];
@onready var playerScene = preload("res://scenes/prefabs/objects/player.tscn");

func _ready():
	spawnPlayer();

func _process(delta):
	pass

func spawnPlayer(_in_position := playerSpawnPosition) -> Node3D:
	var newPlayer = playerScene.instantiate();
	newPlayer.position = _in_position;
	add_child(newPlayer);
	return newPlayer;
