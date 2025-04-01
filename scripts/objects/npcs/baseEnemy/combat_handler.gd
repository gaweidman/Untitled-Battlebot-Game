extends Node3D

@export var health: int;

var inputHandler;
var leakTimer : Timer;

var player;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func take_damage(damage):
	health -= damage;
	if health <= 0:
		die();
	
func die():
	queue_free();
	
func _on_collision(collider):
	pass
