extends MakesNoise;

@export var maxSpeed: float;
@export var startingHealth: int;

var body; 
var health;
var maxHealth;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_node("Body");
	print("BODY ASDFSFA", body);
	maxHealth = startingHealth;
	health = startingHealth;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func take_damage(damage):
	print("TAKING DAMAGE")
	health -= damage;
	get_node("../GUI/Health").text = "Health: " + health + "/" + maxHealth;
	if health <= 0:
		die();
		
func die():
	print("WE ARE DYING")
	queue_free();
	
func process_collision():
	pass

# if a given number is positive, returns 1. if it's negative, returns -1. if it's
# 0, returns 0.
func get_sign(num):
	if num == 0:
		return 0
	else:
		return num/abs(num);


func _on_sawblade_body_entered(otherBody: Node) -> void:
	print("we're here", otherBody)

func _on_body_body_entered(collider: Node) -> void:
	print("COLLISIONIN BODY BODY ENTERED")
	if collider.is_in_group("Damager"):
		take_damage(1);
