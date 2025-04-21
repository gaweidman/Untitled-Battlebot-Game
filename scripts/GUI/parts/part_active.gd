extends Part

class_name PartActive

@export var meshNode : MeshInstance3D;
@export var model : Mesh;
@export var modelMaterial : StandardMaterial3D;
@export var modelOffset = Vector3(0,0,0);
@export var modelScale = Vector3(1,1,1);
##This is the base energy cost before any modifiers. Do not modify in code.
@export var positionNode : Node3D; ##This needs to be the thing with the position on it - in thbis case, the Body node
@export var looksAtMouse := true;
@export var rotateWithPlayer := false;
var combatHandler : CombatHandler;
var inputHandler : InputHandler;
var motionHandler : MotionHandler;
var equipped := false;
var unequippedBlinkySprite = preload("res://graphics/images/HUD/parts/partActiveCorner_unequpped.png");
var equippedBlinkySprite = preload("res://graphics/images/HUD/parts/partActiveCorner_equpped.png");

@export var baseEnergyCost = 1;
##This is the calculated final energy cost.
var energyCost = baseEnergyCost;
##This modifier should be what is used for damage bonuses from other parts.
var baseEnergyCostModifier = baseEnergyCost;

##This is the base fire rate (in seconds) for the part's active ability. Do not modify in code.
@export var baseFireRate := 0.15;
##This is the calculated fire rate (in seconds) for the part's active ability.
var fireRate := baseFireRate;
##This modifier should be what is used for fire rate bonuses from other parts.
var baseFireRateModifier := 1.0;
##This is a timer. Do not modify.
var fireRateTimer := 0.0;

##This is the base damage before any modifiers. Do not modify in code.
@export var baseDamage := 1.0;
##This modifier can be changed within the part itself; used fo rthings like sawblade gaining damage when using its active.
var damageModifier := 1.0;
##This modifier should be what is used for damage bonuses from other parts.
var baseDamageModifier := 1.0;
##This is the calculated final damage.
var damage := baseDamage;

func _ready():
	super();
	meshNode.set_deferred("mesh", model);
	meshNode.set_deferred("surface_material_override/0", modelMaterial);
	meshNode.set_deferred("scale", modelScale);
	meshNode.hide();

func _activate():
	if can_fire():
		if combatHandler:
			combatHandler.energy -= get_energy_cost();
		else:
			return
	else:
		return
	
	Hooks.OnActiveUse(self);
	_set_fire_rate_timer();
	return;
	##Get Inventory's energy total and subtract energyCost from it

func get_damage(base:=false):
	if !base:
		return damage;
	else:
		return baseDamageModifier * baseDamage;

func get_fire_rate(base:=false):
	if !base:
		return fireRate;
	else:
		return baseFireRateModifier * baseFireRate;

func get_energy_cost(base:=false):
	if !base:
		return energyCost;
	else:
		return baseEnergyCostModifier * baseEnergyCost;

func energy_affordable() -> bool:
	if is_instance_valid(combatHandler):
		return combatHandler.energy_affordable(get_energy_cost());
	return false

func _set_fire_rate_timer():
	set_deferred("fireRateTimer", get_fire_rate());

func _assign_refs():
	if ! is_instance_valid(combatHandler):
		combatHandler = inventoryNode.combatHandler;
	if ! is_instance_valid(thisBot):
		thisBot = inventoryNode.thisBot;
	else:
		if ! is_instance_valid(motionHandler):
			motionHandler = thisBot.motionHandler;
		if ! is_instance_valid(positionNode):
			positionNode = thisBot.body;

func _physics_process(delta):
	if looksAtMouse: call_deferred("_rotate_to_look_at_mouse",delta)
	if rotateWithPlayer: call_deferred("_rotate_with_player");

func can_fire() -> bool: 
	return equipped and (fireRateTimer <= 0);

##Returns the cooldown timer divided by the fire rate.
func get_cooldown() -> float:
	return fireRateTimer / get_fire_rate();

##Returns a """percentage""" of the cooldown's completion.
func get_reverse_cooldown() -> float:
	return 1.0 - get_cooldown();

func _process(delta):
	super(delta);
	
	if fireRateTimer <= 0:
		fireRateTimer = 0;
		pass
	else:
		fireRateTimer -= delta;
	
	_assign_refs()
	if is_instance_valid(positionNode):
		if get_equipped() == false:
			if meshNode.visible == true:
				meshNode.hide()
		if ownedByPlayer:##If the player owns it...
			if inPlayerInventory:
				if get_equipped() == true:
					if positionNode.visible == true:
						if meshNode.visible == false:
							meshNode.show()
				else:
					if meshNode.visible == true:
						meshNode.hide()
		else:##If they don't (at all or yet)
			if inPlayerInventory: ##if in the player's prescence:
				if meshNode.visible == true:
					meshNode.hide()
			else: ##if NOT in the player's prescence:
				if positionNode.visible == true:
					if meshNode.visible == false:
						meshNode.show()
	meshNode.set_deferred("position", modelOffset);
	damage = baseDamage * baseDamageModifier * damageModifier;
	fireRate = baseFireRate * baseDamageModifier;
	energyCost = baseEnergyCost * baseEnergyCostModifier;

func _rotate_to_look_at_mouse(delta):
	var rot = Vector3.ZERO;
	if is_instance_valid(positionNode):
		if thisBot is Player:
			rot = InputHandler.mouseProjectionRotation(positionNode);
		else:
			rot = InputHandler.playerPosRotation(positionNode);
		rot = rot.rotated(Vector3(0,1,0), deg_to_rad(90))
		#print(rot)
		if is_instance_valid(meshNode):
			meshNode.look_at(meshNode.global_transform.origin + rot, Vector3.UP)
			meshNode.set_deferred("rotation", meshNode.rotation +  positionNode.rotation);

func _rotate_with_player():
	if thisBot is Player:
		var bdy = GameState.get_player_body_mesh();
		meshNode.rotation = bdy.rotation;
	elif thisBot is Combatant:
		var bdy = thisBot.body;
		meshNode.rotation = bdy.rotation;
	else:
		pass;

func set_equipped(foo):
	equipped = foo;
	if is_instance_valid($TextureBase/EquippedBlinky):
		if foo:
			$TextureBase/EquippedBlinky.texture = equippedBlinkySprite;
		else:
			$TextureBase/EquippedBlinky.texture = unequippedBlinkySprite;

func get_equipped() -> bool:
	return equipped;

func destroy():
	meshNode.call_deferred("queue_free");
	super();
