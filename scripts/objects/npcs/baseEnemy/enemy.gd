extends Combatant;

class_name EnemyBase

func _get_AI_handler():
	return get_node_or_null("AIHandler");
	
func take_damage(damage):
	get_node("CombatHandler").take_damage(damage);
