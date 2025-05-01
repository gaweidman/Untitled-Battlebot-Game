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
var thisBot : Combatant;
var body : RigidBody3D;

var activeParts = { 0 : null, 1: null, 2: null}

func _ready():
	thisBot = get_parent();

func die():
	get_parent().queue_free();

func take_damage(damage:float):
	if GameState.get_in_state_of_play():
		if invincible && damage > 0:
			return;
		health -= damage;
		add_invincibility()
		if health <= 0.0:
			die();
			health = 0.0;
		if health > get_max_health():
			health = get_max_health();

func add_invincibility(_time := maxInvincibleTimer):
	if _time >= invincibleTimer:
		invincibleTimer = _time;

func get_max_health():
	return maxHealth;

func get_max_energy():
	return maxEnergy;

func get_energy_refresh_rate():
	return energyRefreshRate;

func spend_energy(amt):
	energy -= amt;
	energy = clamp(energy, 0.0, get_max_energy())

func _process(delta):
	if ! is_instance_valid(thisBot):
		thisBot = get_parent();
	if ! is_instance_valid(body):
		body = thisBot.body;

func _on_collision(collider):
	pass;

func energy_affordable(inAmount:=0.0) -> bool:
	return inAmount <= energy;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	##Adds energy over time up to the max but not below 0
	if GameState.get_in_state_of_play():
		energy = max(0, min(energy + (delta * get_energy_refresh_rate()), get_max_energy()));
		if invincibleTimer > 0:
			invincible = true;
			invincibleTimer -= delta;
		else:
			invincible = false;
	#if Input.is_key_pressed(KEY_P):
		#take_damage(-9999);
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
		#if index == 
		part._activate();
	pass

func get_active_part(index) -> PartActive:
	if index in activeParts:
		if is_instance_valid(activeParts[index]):
			if activeParts[index] is PartActive:
				return activeParts[index];
		else:
			activeParts[index] = null;
	return null;

func is_active_slot_empty(index):
	if !(index <= 2 && index >= 0):
		return false;
	if index in activeParts:
		if activeParts[index] == null:
			return true;
	return false;

##Adds a part at the given index.
func set_active_part(part:PartActive, index:int, override := true):
	if override:
		activeParts[index] = part;
		return;
	else:
		if is_active_slot_empty(index):
			activeParts[index] = part;
			return;
	push_warning("Attempted to add to slot "+ str(index)+" which either doesn't exist or is full.");
	return;
