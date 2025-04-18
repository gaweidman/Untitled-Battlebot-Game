extends Node3D

class_name CombatHandlerEnemy

@export var scrap_worth := 1;

func _on_collision(collider):
	var parent = collider.get_parent();
	print(parent, parent.get_parent());
	if parent and parent.is_in_group("Projectile"):
		if parent.get_attacker() != self:
			pass;
			#take_damage(1);

func use_active(index):
	super(index);
	#print(can_fire(0))

func die():
	var inv = GameState.get_inventory();
	if is_instance_valid(inv):
		inv.add_scrap(scrap_worth);
	super();
