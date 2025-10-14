extends Resource

class_name DamageData

var damageAmount := 1.0;
var knockbackAmount := 0.0;
var damageDirection := Vector3.ZERO;
enum damageTypes {
	BLUDGEONING,
	PIERCING,
	HEATED,
	CORROSIVE,
	EXPLOSIVE,
}
var tags : Array[damageTypes] = [];

func create(_damageAmount, _knockback, _direction := Vector3.ZERO, _damageTypes : Array[damageTypes] = [damageTypes.BLUDGEONING]):
	damageAmount = _damageAmount;
	knockbackAmount = _knockback;
	damageDirection = _direction;
	tags = _damageTypes;
	return self;

func make_copy():
	var copy = duplicate(true);
	return copy;

func get_damage():
	return damageAmount;

func get_knockback():
	return knockbackAmount * damageDirection;

func has_type(tag : damageTypes):
	return tags.has(tag);
