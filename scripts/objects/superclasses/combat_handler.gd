extends Node3D

class_name CombatHandler

@export var maxHealth := 1.0;
var health := maxHealth;

@export var maxEnergy := 3.0;
var energy := maxEnergy;
@export var energyRefreshRate := 2.0;
var invincible := false;
var invincibleTimer := 0.0;
@export var maxInvincibleTimer := 0.25;

var activeParts = { 0 : null, 1: null, 2: null}

func die():
	get_parent().queue_free();

func take_damage(damage:float):
	if GameState.get_game_board_state() == GameBoard.gameState.PLAY:
		if invincible && damage > 0:
			return;
		health -= damage;
		invincibleTimer = maxInvincibleTimer;
		if health <= 0.0:
			die();
			health = 0.0;
		if health > maxHealth:
			health = maxHealth;

	
func _on_collision(collider):
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	##Adds energy over time up to the max but not below 0
	if GameState.get_game_board_state() == GameBoard.gameState.PLAY:
		energy = max(0, min(energy + (delta * energyRefreshRate), maxEnergy));
		if invincibleTimer > 0:
			invincible = true;
			invincibleTimer -= delta;
		else:
			invincible = false;
	if Input.is_key_pressed(KEY_P):
		take_damage(0.5);
	pass

func can_fire(index) -> bool: 
	if health <= 0.0:
		return false;
	var part = get_active_part(index);
	if part:
		return (energy >= part.get_energy_cost()) && part.can_fire();
	return false;

func use_active(index):
	var part := get_active_part(index);
	if part and can_fire(index):
		part._activate();
	pass

func get_active_part(index) -> PartActive:
	if index in activeParts:
		if is_instance_valid(activeParts[index]):
			if activeParts[index] is PartActive:
				return activeParts[index];
	return null;
