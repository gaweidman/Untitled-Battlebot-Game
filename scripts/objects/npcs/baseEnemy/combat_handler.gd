extends CombatHandler

class_name CombatHandlerEnemy
	
func _on_collision(collider):
	super(collider);
	var parent = collider.get_parent();
	if parent and parent.is_in_group("Projectile"):
		if parent.get_attacker() != self:
			pass;
			#take_damage(1);

func use_active(index):
	super(index);
	#print(can_fire(0))
