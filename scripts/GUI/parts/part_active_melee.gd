extends PartActive

class_name PartActiveMelee

var weaponNode;
var collisionNode;

func _process(delta):
	super(delta);
	if ! is_instance_valid(weaponNode):
		weaponNode = %Weapon;
		weaponNode.add_to_group("Player Part");
		#weaponNode.add_collision_exception_with(positionNode)
	weaponNode.set_deferred("global_position", meshNode.global_position);

func _physics_process(delta):
	super(delta);
	if ! is_instance_valid(weaponNode):
		weaponNode = %Weapon;
		weaponNode.add_to_group("Player Part");

func _activate():
	if super():
		if can_fire():
			Hooks.OnActiveUse(self);
			Hooks.OnMeleeWeaponSwing(self);
			_set_fire_rate_timer();
			return true;
		else: return false;
	else:
		return false;

func _on_weapon_body_entered(collider: Node) -> void:
	_assign_refs();
	combatHandler._on_collision(collider);
	motionHandler._on_collision(GameState.get_player_body(), collider);
	contact_damage(collider);
	Hooks.OnCollision(%Weapon, collider);
	
	pass 

func contact_damage(collider: Node) -> void:
	if get_equipped():
		SND.play_collision_sound(%Weapon, collider);
	if collider.get_parent() is Combatant:
		Hooks.OnMeleeWeaponHit(self, collider);
		pass;
	else:
		return;
