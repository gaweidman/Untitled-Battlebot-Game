extends Part

class_name PartActive

@export_group("References")
@export var meshNode : MeshInstance3D;
@export var model : Mesh;
@export var modelMaterial : StandardMaterial3D;
@export var positionNode : Node3D; ##This needs to be the thing with the position on it - in this case, the Body node
var unequippedBlinkySprite = preload("res://graphics/images/HUD/parts/partActiveCorner_unequpped.png");
var equippedBlinkySprite = preload("res://graphics/images/HUD/parts/partActiveCorner_equpped.png");
@export var equippedBlinky : TextureRect;
@export var equippedBlinkyOffset := partIconOffset;
var combatHandler : CombatHandler;
var inputHandler : InputHandler;
var motionHandler : MotionHandler;
@export_group("Rotation and offsets")
@export var looksAtMouse := true;
@export var rotateWithPlayer := false;
@export var rotationSpeedFactor := 1.0; ##This is multiplied by 30 as a lerp_angle() delta component.
@export var modelOffset = Vector3(0,0,0);
@export var modelScale = Vector3(1,1,1);
@export var firingOffset := Vector3(0,0.50,0); ##This is mainly used in gameplay for ranged parts, but needs to be here so parts that look at the mouse can take it into account.
var rot := Vector3.ZERO;
var prevRot := rot;
var rotAngle := 0.0;
var prevRotAngle := rotAngle;
var targetRotAngle := rotAngle;
var aimingRotAngle := targetRotAngle;
var equipped := false;
@export_group("Active tab")
@export var ammoAmountOverride : String;
@export var ammoAmountColorOverride := "ranged";

@export_group("Modifiable Stats")
@export var baseEnergyCost = 1.0;
##This is the calculated final energy cost.
var energyCost = baseEnergyCost;
##This modifier should be what is used for damage bonuses from other parts.
var baseEnergyCostModifier = baseEnergyCost;
##This energy cost modifier interacts with the Mods system.
var mod_energyCost := mod_resetValue.duplicate();

func get_damage(base:=false):
	if !base:
		return damage;
	else:
		return baseDamageModifier * (baseDamage + mod_damage.add) * (mod_damage.mult * mod_damage.flat);

##This is the base fire rate (in seconds) for the part's active ability. Do not modify in code.
@export var baseFireRate := 0.15;
##This is the calculated fire rate (in seconds) for the part's active ability.
var fireRate := baseFireRate;
##This modifier should be what is used for fire rate bonuses from other parts.
var baseFireRateModifier := 1.0;
##This is a timer. Do not modify.
var fireRateTimer := 0.0;
##This fire rate modifier interacts with the Mods system.
var mod_fireRate := mod_resetValue.duplicate();

func get_fire_rate(base:=false):
	if !base:
		return fireRate;
	else:
		return baseFireRateModifier * (baseFireRate + mod_fireRate.add) * (mod_fireRate.mult * mod_fireRate.flat);

##This is the base damage before any modifiers. Do not modify in code.
@export var baseDamage := 1.0;
##This modifier can be changed within the part itself; used fo rthings like sawblade gaining damage when using its active.
var damageModifier := 1.0;
##This modifier should be what is used for damage bonuses from other parts.
var baseDamageModifier := 1.0;
##This is the calculated final damage.
var damage := baseDamage;
##This damage modifier interacts with the Mods system.
var mod_damage := mod_resetValue.duplicate();

func get_energy_cost(base:=false):
	if !base:
		return energyCost;
	else:
		return baseEnergyCostModifier * (baseEnergyCost + mod_energyCost.add) * (mod_energyCost.mult * mod_energyCost.flat);

func mods_reset(foo:=false):
	super(foo);
	mod_energyCost = mod_resetValue.duplicate();
	mod_fireRate = mod_resetValue.duplicate();
	mod_damage = mod_resetValue.duplicate();

func _ready():
	super();
	meshNode.set_deferred("mesh", model);
	meshNode.set_deferred("surface_material_override/0", modelMaterial);
	meshNode.set_deferred("scale", modelScale);
	meshNode.hide();

func inventory_vanity_setup():
	super();
	equippedBlinky.set_deferred("position", equippedBlinkyOffset * 48);

func _activate():
	if can_fire():
		if combatHandler:
			##Get Inventory's energy total and subtract energyCost from it
			combatHandler.spend_energy(get_energy_cost());
			Hooks.OnActiveUse(self);
			_set_fire_rate_timer();
			return true;
		else:
			return false;
	else:
		return false;

func energy_affordable() -> bool:
	if is_instance_valid(combatHandler):
		return combatHandler.energy_affordable(get_energy_cost());
	return false

func _set_fire_rate_timer():
	set_deferred("fireRateTimer", get_fire_rate());

func _assign_refs():
	if ! is_instance_valid(combatHandler):
		if is_instance_valid(inventoryNode.combatHandler):
			combatHandler = inventoryNode.combatHandler;
	if ! is_instance_valid(thisBot):
		thisBot = inventoryNode.thisBot;
	else:
		if ! is_instance_valid(motionHandler):
			motionHandler = thisBot.motionHandler;
		if ! is_instance_valid(positionNode):
			positionNode = thisBot.body;

func _physics_process(delta):
	_assign_refs();
	if looksAtMouse: call_deferred("_rotate_to_look_at_mouse",delta)
	if rotateWithPlayer: call_deferred("_rotate_with_player");

func can_fire() -> bool: 
	if ! GameState.get_in_state_of_play() : return false;
	return get_equipped() and (fireRateTimer <= 0);

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
	
	_assign_refs();
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
	damage = (baseDamage + mod_damage.add) * baseDamageModifier * damageModifier * (1 + (mod_damage.flat * mod_damage.mult));
	fireRate = (baseFireRate + mod_fireRate.add) * baseDamageModifier * (1 + (mod_fireRate.flat * mod_fireRate.mult));
	energyCost = (baseEnergyCost + mod_energyCost.add) * baseEnergyCostModifier * (1 + (mod_energyCost.flat * mod_energyCost.mult));
	

func _rotate_to_look_at_mouse(delta):
	prevRot = rot;
	rot = Vector3.ZERO;
	prevRotAngle = rotAngle;
	rotAngle = 0.0;
	#targetRotAngle
	
	if is_instance_valid(positionNode):
		if thisBot is Player:
			var cam = GameState.get_camera();
			if is_instance_valid(cam):
				#rot = InputHandler.mouseProjectionRotation(positionNode);
				if positionNode.global_position is Vector3 and firingOffset is Vector3 and modelOffset is Vector3:
					var mouseAim = cam.get_rotation_to_fake_aiming(positionNode.global_position + firingOffset + modelOffset);
					if mouseAim:
						rotAngle = mouseAim;
					else:
						rotAngle = prevRotAngle;
				#print(rot)
					targetRotAngle = rotAngle;
				else:
					rotAngle = prevRotAngle;
					targetRotAngle = rotAngle;
				
				#if is_instance_valid(meshNode):
					#meshNode.rotation.y = lerp_angle(meshNode.rotation.y, -targetRotAngle, delta * 30);
		else:
			var posV2 = Vector2(positionNode.global_position.x, positionNode.global_position.z);
			var playerPos = GameState.get_player_position();
			var playerPosV2 = Vector2(playerPos.x, playerPos.z);
			rotAngle = posV2.angle_to_point(playerPosV2);
			targetRotAngle = rotAngle;
			#rot = InputHandler.playerPosRotation(positionNode);
			#rot = rot.rotated(Vector3(0,1,0), deg_to_rad(90))
			#print(rot);
			
			#targetRotAngle = positionNode.global_position
			#if is_instance_valid(meshNode):
				#meshNode.look_at(meshNode.global_transform.origin + rot, Vector3.UP)
				#meshNode.set_deferred("rotation", meshNode.rotation +  positionNode.rotation);
	
	if is_instance_valid(meshNode):
		aimingRotAngle = lerp_angle(aimingRotAngle, -targetRotAngle, delta * 30.0 * rotationSpeedFactor)
		meshNode.rotation.y = aimingRotAngle;

func slerp_rotation(transform:Transform3D, transform2:Transform3D):
	# Convert basis to quaternion, keep in mind scale is lost
	var a = Quaternion(transform.basis)
	var b = Quaternion(transform2.basis)
	# Interpolate using spherical-linear interpolation (SLERP).
	var c = a.slerp(b,0.5) # find halfway point between a and b
	# Apply back
	transform.basis = Basis(c)

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
	if is_instance_valid(equippedBlinky):
		if foo:
			equippedBlinky.texture = equippedBlinkySprite;
		else:
			equippedBlinky.texture = unequippedBlinkySprite;

func get_equipped() -> bool:
	return equipped;

func destroy():
	meshNode.call_deferred("queue_free");
	super();
