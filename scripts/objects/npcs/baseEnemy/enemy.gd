extends Combatant;

class_name EnemyBase;

@export var sleepTimerLength := 0.0;
var sleepTimer := sleepTimerLength;
var closestAiNode : AINode;

func _ready():
	super();
	set_sleep_timer(sleepTimerLength);

func _get_AI_handler():
	return get_node_or_null("AIHandler");
	
func take_damage(damage):
	get_node("CombatHandler").take_damage(damage);

func _process(delta):
	super(delta);
	if sleepTimer > 0:
		sleepTimer -= delta;

func set_sleep_timer(inTime:=0.0):
	sleepTimer = inTime;

func is_asleep() -> bool:
	return sleepTimer > 0;
	
func get_body_position():
	return %Body.get_position();
	
func get_global_body_position():
	return %Body.get_position();

func get_closest_ainode():
	return closestAiNode;
