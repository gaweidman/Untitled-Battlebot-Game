extends Node3D

class_name CombatHandler

var maxHealth = 3;
var health = maxHealth;
var maxEnergy = 3.0;
var energy = maxEnergy;
var energyRefreshRate := 2;

var activeParts = { 0 : null, 1: null}

var inputHandler : InputHandler;
var inventory : Inventory;

var player;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inputHandler = $"../InputHandler"
	player = GameState.get_player();
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	##Adds energy over time up to the max but not below 0
	energy = max(0, min(energy + (delta * energyRefreshRate), maxEnergy))
	pass

func can_fire(index) -> bool: 
	if health <= 0:
		return false;
	var part = get_active_part(index);
	if part:
		return (floor(energy) >= part.energyCost) && part.can_fire();
	return false;

func use_active(index):
	var part := get_active_part(index);
	if part:
		part._activate();
	pass

func get_active_part(index) -> PartActive:
	if index in activeParts:
		if activeParts[index] is PartActive:
			return activeParts[index];
	return null;

func take_damage(damage):
	health -= damage;
	get_node("../GUI/Health").text = "Health: " + health + "/" + maxHealth;
	if health <= 0:
		die();
		
	GameState.get_hud().update();
		
func die():
	queue_free();

func _on_collision(colliderdw):
	pass

func _exit_tree():
	pass;
