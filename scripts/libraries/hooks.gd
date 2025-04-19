extends Node;

# List of all hooks:
# Attack
#	OnFireProjectile
#	OnMeleeWeaponHit
#	OnMeleeWeaponSwing
# 
# Movement
#	OnMovementInput
#
# Physics
#	OnHitWall
# 	OnHitCombatant
# 	OnPlayerCollision
# 
# Passive
#	PassiveItemTick
#
# Special Abilities
#	OnUseShield
#	OnDropEntity

var body;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;

func default_OnFireProjectile():
	pass; # todo
	
func default_OnMeleeWeaponHit():
	pass;
	
func default_OnMeleeWeaponSwing():
	pass;
	
func default_OnMovementInput():
	GameState.HandleMovement();
	
func default_OnHitWall():
	pass;
	
func default_OnHitCombatant():
	pass;
	
func default_PassiveItemTick():
	pass;
	
func default_OnUseShield():
	pass;
	
func default_OnDropEntity():
	pass
	
func OnPlayerCollision(collider: Node):
	pass
