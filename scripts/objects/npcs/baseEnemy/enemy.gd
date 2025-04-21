extends Combatant;

class_name EnemyBase;

func _get_AI_handler():
	return get_node_or_null("AIHandler");
	
func take_damage(damage):
	get_node("CombatHandler").take_damage(damage);

func _on_body_entered(otherBody: Node) -> void:
	Hooks.OnCollision(%Body, otherBody);
	#Hooks.OnEnemyCollision($Body, otherBody);
