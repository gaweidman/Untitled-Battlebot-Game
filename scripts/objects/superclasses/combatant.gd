extends MakesNoise;

class_name Combatant

var body; 
var combatHandler : CombatHandler;
var motionHandler : MotionHandler;
var inventory : Inventory;
var _partOffset1 := Vector3(0, 0.086, 0.0);
var _partOffset2 := Vector3(0, 0.172, 0);
var bodyMesh : MeshInstance3D; 
var underbelly : UnderbellyContactPoints;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assign_refs();
	super._ready();

func assign_refs():
	if !is_instance_valid(body):
		body = get_node("Body");
	else:
		if !is_instance_valid(bodyMesh):
			if is_instance_valid(%BotBody):
				bodyMesh = %BotBody;
			if is_instance_valid(%UnderbellyRaycasts):
				underbelly = %UnderbellyRaycasts;
	if !is_instance_valid(combatHandler):
		combatHandler = get_node("CombatHandler");
	if !is_instance_valid(motionHandler):
		motionHandler = get_node("MotionHandler");
	if !is_instance_valid(inventory):
		inventory = get_node("Inventory");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	assign_refs();
	pass
	
func get_health() -> int:
	return combatHandler.health;
func at_max_health() ->bool:
	return is_equal_approx(combatHandler.health, combatHandler.maxHealth);
# if a given number is positive, returns 1. if it's negative, returns -1. if it's
# 0, returns 0.
func get_sign(num):
	if num == 0:
		return 0;
	else:
		return num/abs(num);
		
func die():
	if is_instance_valid(combatHandler):
		combatHandler.call_deferred("die");

func _on_body_body_entered(collider: Node) -> void:
	combatHandler._on_collision(collider);
	motionHandler._on_collision(%Body, collider);

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

func _get_combat_handler():
	return get_node_or_null("CombatHandler")

func _get_motion_handler():
	return get_node_or_null("MotionHandler")

func take_damage(damage, ):
	pass
	#combatHandler.take_damage(damage);

func take_knockback(inDir:Vector3):
	#body.apply_impulse(Vector3(0,10000,0))
	print("KNOCKBACK: ",inDir)
	body.call_deferred("apply_impulse",inDir);
	#body.apply_impulse(inDir);
	pass

func freeze(enable:=true):
	if is_instance_valid(body):
		body.set_freeze_enabled(enable);
