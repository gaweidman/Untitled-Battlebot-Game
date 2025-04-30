extends Combatant;

class_name Player

var gameBoard : GameBoard;
var closestAiNode : AINode;

func _ready():
	super();
	hide();
	freeze(true);
	inventory = GameState.get_inventory();

func live():
	show();
	freeze(false);
	body.show();
	$CombatHandler.live();
	$Inventory.clear_shop(true, true);
	pass;

func get_health(integer := true):
	if integer:
		return int(combatHandler.health);
	return combatHandler.health;

func get_ammo(integer := true):
	if integer:
		return int(combatHandler.energy);
	return combatHandler.energy;

func take_knockback(_inDir:Vector3):
	#var inDir = _inDir * 100;
	#print("Player knockback")
	#super(inDir);
	super(_inDir);

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

func heal(health:float):
	combatHandler.take_damage(-health)

######

func start_new_game():
	live();
	inventory.startingKitAssigned = false;

func start_round():
	inventory.new_round();

func end_round():
	GameState.add_death_time(60);
	inventory.end_round();

func enter_shop():
	inventory.inventory_panel_toggle(true);
	inventory.HUD_shop.open_up_shop();
	
func get_closest_ainode():
	return closestAiNode;
