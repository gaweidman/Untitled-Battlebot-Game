extends Combatant;

class_name Thruster;

func _get_AI_handler():
	return get_node_or_null("AIHandler");
	
func take_damage(damage):
	get_node("CombatHandler").take_damage(damage);

func _process(delta):
	super(delta);
	if is_instance_valid(inventory):
		inventory.add_part_from_scene(0,0,"res://scenes/prefabs/objects/parts/playerParts/part_sawblade.tscn",0);
