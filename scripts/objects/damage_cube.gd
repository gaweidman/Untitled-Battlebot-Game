extends Node3D

var health;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = 3;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_damage(amount):
	health -= amount;
	if health <= 0:
		queue_free();

func _on_body_body_entered(collider: Node) -> void:
	if collider.is_in_group("Damager") && collider.is_in_group("Player Part"):
		take_damage(1)
