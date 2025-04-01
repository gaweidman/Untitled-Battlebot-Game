extends Combatant;

class_name Player

func get_ammo() -> int:
	return combatHandler.energy;

func _get_input_handler():
	return get_node_or_null("InputHandler");
