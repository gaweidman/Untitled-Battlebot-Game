extends Combatant;

class_name Player

var gameBoard : GameBoard;

func _ready():
	super();
	hide();

func live():
	show();
	$CombatHandler.live();
	pass;

func get_health(integer := true):
	if integer:
		return int(combatHandler.health);
	return combatHandler.health;

func get_ammo(integer := true):
	if integer:
		return int(combatHandler.energy);
	return combatHandler.energy;

func _get_input_handler():
	return get_node_or_null("InputHandler");

func _process(delta):
	super(delta);

func get_body_position():
	return get_node("Body").get_position();

func get_global_body_position():
	return get_node("Body").get_global_position();
	
func take_damage(damage:float):
	combatHandler.take_damage(damage)
