extends Piece

class_name Piece_Weapon

@export var damageBase := 1.0;
@export var knockbackBase := 0.0;
var damageModifier := 1.0;

func stat_registry():
	super();
	register_stat("Damage", damageBase, statIconDamage);
	register_stat("Knockback", knockbackBase, statIconDamage);

func get_damage():
	return get_stat("Damage");

func get_knockback(positionOfTarget : Vector3, factorBodyVelocity := true) -> Vector3:
	var knockbackVal = get_stat("Knockback");
	var knockbackVector = knockbackVal * (positionOfTarget - position).normalized();
	if factorBodyVelocity:
		var bodVel = get_host_robot().body.linear_velocity;
		knockbackVector += bodVel;
	return knockbackVector;
