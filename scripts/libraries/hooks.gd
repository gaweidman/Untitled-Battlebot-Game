extends Node;

# List of all hooks:
# Attack
#	OnFireProjectile
#	OnMeleeWeaponHit
#	OnMeleeWeaponSwing
#	OnUtilityUse
#	OnActiveUsed
# 
# Movement
#	OnMovementInput
#
# Physics
#	OnWallCollision
# 	OnEnemyCollision
# 	OnPlayerCollision
#	OnCollision
# 
# Passive
#	PassiveItemTick
#
# Special Abilities
#	OnUseShield

var list = {
	"OnFireProjectile": {},
	"OnMeleeWeaponHit": {},
	"OnMeleeWeaponSwing": {},
	"OnUtilityUse": {},
	"OnActiveUsed": {},
	"OnMovementInput": {},
	"OnWallCollision": {},
	"OnEnemyCollision": {}, 
	"OnPlayerCollision": {},  #
	"OnCollision": {}, #
	"PassiveItemTick": {},
};

var body;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;

## Called when a part owner fires a projectile.
func OnFireProjectile(firer: Node3D):
	for hookFunc in list.OnFireProjectile:
		hookFunc.call(firer);
	
## Called when a melee weapon hits a combatant.
func OnMeleeWeaponHit(weapon: Node3D):
	for hookFunc in list.OnMeleeWeaponHit:
		hookFunc.call(weapon);
	
## Called when a melee weapon is swung or otherwise used.
func OnMeleeWeaponSwing(weapon: Node3D):
	for hookFunc in list.OnMeleeWeaponSwing:
		hookFunc.call(weapon);
	
## Called when the player inputs movement
func OnMovementInput(movementVector: Vector2):
	for hookFunc in list.OnMovementInput:
		hookFunc.call(movementVector);
	
func OnHitWall(collider: StaticBody3D):
	for hookFunc in list.OnHitWall:
		hookFunc.call(collider);
	
func OnHitCombatant(collider: StaticBody3D, combatant: Combatant):
	for hookFunc in list.OnHitCombatant:
		hookFunc.call(collider, combatant);
	
func PassiveItemTick(item: PartPassive):
	for hookFunc in list.PassiveItemTick:
		hookFunc.call(item);
	
func OnUseShield(item: PartActive):
	for hookFunc in list.OnUseShield:
		hookFunc.call(item);
	
func OnPlayerCollision(collider: Node):
	for hookFunc in list.OnPlayerCollision:
		hookFunc.call(collider);

func OnCollision(collider1: CollisionObject3D, collider2: CollisionObject3D):
	for hookFunc in list.OnCollision:
		hookFunc.call(collider1, collider2);
	
func add(hookName: String, instanceName: String, hookFunc: Callable):
	list[hookName][instanceName] = hookFunc;
	list[hookName][instanceName] = null;
