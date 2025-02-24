extends MakesNoise;

var body; 
var combatHandler;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_node("Body");
	combatHandler = get_node("CombatHandler");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
# if a given number is positive, returns 1. if it's negative, returns -1. if it's
# 0, returns 0.
func get_sign(num):
	if num == 0:
		return 0
	else:
		return num/abs(num);
		
func _on_body_body_entered(collider: Node) -> void:
	combatHandler._on_collision(collider);
