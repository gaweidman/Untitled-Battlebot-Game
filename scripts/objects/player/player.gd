extends MakesNoise;

var body; 
var combatHandler;
var motionHandler;
var _partOffset1 := Vector3(0, 0.086, 0.0);
var _partOffset2 := Vector3(0, 0.172, 0);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_node("Body");
	combatHandler = get_node("CombatHandler");
	motionHandler = get_node("MotionHandler");
	super._ready();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func get_health() -> int:
	return combatHandler.health;
	
func get_ammo() -> int:
	return combatHandler.magazine.size();
	
# if a given number is positive, returns 1. if it's negative, returns -1. if it's
# 0, returns 0.
func get_sign(num):
	if num == 0:
		return 0;
	else:
		return num/abs(num);
		
func _on_body_body_entered(collider: Node) -> void:
	combatHandler._on_collision(collider);
	motionHandler._on_collision(%Body, collider);


func _on_sawblade_body_entered(collider: Node) -> void:
	print()
	motionHandler._on_collision(%Sawblade, collider);

func _get_part_offset(num):
	var offset = Vector3(0,0,0);
	if num == 1:
		offset = _partOffset1;
	elif num == 2:
		offset = _partOffset2;
	else:
		return offset;
	
	var newOffset = offset.rotated(Vector3(1,0,0), body.rotation.x);
	newOffset = offset.rotated(Vector3(0,1,0), body.rotation.y);
	newOffset = offset.rotated(Vector3(0,0,1), body.rotation.z);
	return newOffset;