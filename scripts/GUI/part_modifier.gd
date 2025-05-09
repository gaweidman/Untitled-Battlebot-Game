extends Resource

class_name PartModifier;

@export var priority := 0.0;
@export var valueAdd : float = 0.0;
@export var valueFlatMult : float = 0.0;
@export var valueTimesMult : float = 1.0;
@export var modName : StringName;
@export var offset := Vector2i.ZERO;
@export var enabled := true;
@export var myModType : modifierType;
##The owner of this modifier; AKA the one that applied it. Can be any type that descends from Node.
var owner : Node;
var target : Part;
var inventoryNode : Inventory;
var currentlyApplying := false;


func create_modifier(_owner : Node, _inventoryNode: Inventory, _name : StringName, _modType : modifierType, _offset : Vector2i, _priority, _valueAdd := 0.0, _valueFlatMult := 1.0, _valueTimesMult := 1.0, _enabledAtStart := true, ):
	owner = _owner;
	inventoryNode = _inventoryNode;
	modName = _name;
	myModType = _modType;
	offset = _offset;
	if ! (_priority is float):
		priority = 0.0;
	else:
		priority = _priority;
	valueAdd = _valueAdd;
	valueFlatMult = _valueFlatMult;
	valueTimesMult = _valueTimesMult;
	enabled = _enabledAtStart;
	return modName;

enum modifierType {
	ENERGY_COST,
	FIRE_RATE,
	DAMAGE_BASE,
	SELL_REFUND_PERCENT,
	SCRAP_COST,
}
var modifierTypesDict = {
	modifierType.ENERGY_COST : "mod_energyCost",
	modifierType.FIRE_RATE : "mod_fireRate",
	modifierType.DAMAGE_BASE : "mod_damage",
	modifierType.SELL_REFUND_PERCENT : "mod_sellPercent",
	modifierType.SCRAP_COST : "mod_scrapCost",
}

##Yoinks the owner. Might be null.
func get_owner():
	return owner;

func get_owner_priority():
	if owner is Part:
		return owner.effectPriority;
	return 0;

func get_owner_age():
	if owner is Part:
		return owner.ageOrdering;
	return 0;

func get_owner_index():
	if owner is Part:
		return owner.get_inventory_slot_priority();
	return 0;

##Returns the part at the square this modifier is targeting. Might be null.
func get_part_at_offset():
	var invPosition = offset;
	if owner is Part:
		if owner.invPosition != null:
			invPosition += owner.invPosition;
	var slot = inventoryNode.get_slot_at(invPosition.x, invPosition.y);
	if is_instance_valid(slot):
		if slot is Part:
			print("inventory slot grabbed: ", slot.partName);
			target = slot;
			return slot;
	target = null;
	return null;

##Tries to add itself to the target.
func distribute_modifier():
	if is_applicable():
		target.mods_recieve(self);

##Tries to apply itself to the target, if able.
func apply_modifier():
	currentlyApplying = try_apply_mod(modifierTypesDict[myModType]);

##Only returns true if there's a part where this modifier is supposed to apply, and this modifier is enabled.
func is_applicable():
	if ! enabled: return false;
	print(modName + " is enabled");
	var partAt  = get_part_at_offset()
	if partAt == null: return false;
	print(modName + " has a part at the target");
	return true;

##Tries to apply the modifier to the specified property on the part. If the part doesn't have it, then nothing happens.
func try_apply_mod(propertyName : String):
	if is_applicable():
		if propertyName in target:
			return target.mods_apply(propertyName, valueAdd, valueFlatMult, valueTimesMult);
	return false;

func is_applying():
	return currentlyApplying;

##Enables/disables the modifier, then reprompts modifier applicants.
func disable(switch):
	if switch:
		enabled = true;
	else:
		enabled = false;
	if target is Part:
		distribute_modifier();

func kill_if_invalid():
	if ! is_instance_valid(owner) or ! is_instance_valid(inventoryNode):
		free();
