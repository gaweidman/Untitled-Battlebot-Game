extends PartActive

class_name PartActiveMelee

var contactDamage := 1.0;
var weaponNode;
var collisionNode;

func _process(delta):
	super(delta);
	if ! is_instance_valid(weaponNode):
		weaponNode = %Weapon;
		weaponNode.add_to_group("Player Part");
		#weaponNode.add_collision_exception_with(positionNode)
	weaponNode.set_deferred("global_position", meshNode.global_position);

func _on_weapon_body_entered(collider: Node) -> void:
	print("melee hit")
	print(collider)
	
	combatHandler._on_collision(collider);
	motionHandler._on_collision(GameState.get_player_body(), collider);
	contact_damage(collider);
	pass 

func contact_damage(collider: Node) -> void:
	if collider.get_parent() is Combatant:
		print("hi")
	else:
		return;
