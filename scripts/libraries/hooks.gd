extends Node;

# List of all hooks:
# Attack
#	OnFireProjectile
#	OnMeleeWeaponHit
#	OnMeleeWeaponSwing
#	OnActiveUse
#
# Physics
#	OnWallCollision
# 	OnEnemyCollision
# 	OnPlayerCollision
#	OnCollision

var list = {
	"OnFireProjectile": {}, #
	"OnMeleeWeaponHit": {}, #
	"OnMeleeWeaponSwing": {}, #
	"OnActiveUse": {}, #
	"OnWallCollision": {}, #
	"OnEnemyCollision": {}, #
	"OnPlayerCollision": {},  #
	"OnCollision": {}, #
};

var body;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;

## Called when a part owner fires a projectile.
func OnFireProjectile(firer: PartActiveProjectile, projectile: Node3D):
	for hookFunc in list.OnFireProjectile:
		hookFunc.call(firer);
	
## Called when a melee weapon hits a combatant.
func OnMeleeWeaponHit(weapon: PartActiveMelee, victim: Node3D):
	for hookFunc in list.OnMeleeWeaponHit:
		hookFunc.call(weapon);
	
## Called when a melee weapon is swung or otherwise used.
func OnMeleeWeaponSwing(weapon: PartActiveMelee):
	for hookFunc in list.OnMeleeWeaponSwing:
		hookFunc.call(weapon);
	
## Called when something hits the wall.
func OnHitWall(collider: CollisionObject3D):
	for hookFunc in list.OnHitWall:
		hookFunc.call(collider);
	
## Called when something collides with an enemy.
func OnEnemyCollision(collider1: CollisionObject3D, collider2: CollisionObject3D):
	for hookFunc in list.OnEnemyCollision:
		hookFunc.call(collider1, collider2);
	
## Called when something collides with a player.
func OnPlayerCollision(collider: Node):
	for hookFunc in list.OnPlayerCollision:
		hookFunc.call(collider);

## Called when two things collide.
func OnCollision(collider1: CollisionObject3D, collider2: CollisionObject3D):
	for hookFunc in list.OnCollision:
		hookFunc.call(collider1, collider2);
		
func OnActiveUse(activePart: PartActive):
	for hookFunc in list.OnCollision:
		activePart;

## Use to add a hook.
## To use, we go to any file and call
## Hooks.add("OnActiveUse", "OurImplementation", func (part: ActivePart):
## 	 print("We used an active item!")
## )
func add(hookName: String, instanceName: String, hookFunc: Callable):
	list[hookName][instanceName] = hookFunc;
	list[hookName][instanceName] = null;
