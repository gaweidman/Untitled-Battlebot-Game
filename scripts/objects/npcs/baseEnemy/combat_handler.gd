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
	get_parent().queue_free();
	
func _on_collision(collider):
	var parent = collider.get_parent();
	print(parent, parent.get_parent());
	if parent and parent.is_in_group("Projectile"):
		if parent.get_attacker() != self:
			pass;
			#take_damage(1);
