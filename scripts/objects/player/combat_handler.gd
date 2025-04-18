extends Node3D

class_name CombatHandler

var maxHealth = 3.0;
var health = maxHealth;
var maxEnergy = 3.0;
var energy = maxEnergy;
var energyRefreshRate := 2;
var invincible := false;
var invincibleTimer := 0.0;

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
	if GameState.get_game_board_state() == GameBoard.gameState.PLAY:
		energy = max(0, min(energy + (delta * energyRefreshRate), maxEnergy))
		if invincibleTimer > 0:
			invincible = true;
			invincibleTimer -= delta;
		else:
			invincible = false;
	if Input.is_key_pressed(KEY_P):
		take_damage(0.5);
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
	if GameState.get_game_board_state() == GameBoard.gameState.PLAY:
		if invincible:
			return;
		health -= damage;
		invincibleTimer = 0.25;
		#get_node("../GUI/Health").text = "Health: " + str(health) + "/" + str(maxHealth);
		if health <= 0:
			die();
			health = 0;
			
	GameState.get_hud().update();

func die():
	get_parent().hide();
	GameState.set_game_board_state(GameBoard.gameState.GAME_OVER)
	if is_instance_valid(inventory):
		inventory.inventory_panel_toggle(false);
	pass;
	#get_parent().queue_free();

func live():
	health = maxHealth;
	energy = maxEnergy;
	pass;

func _on_collision(collider):
	var parent = collider.get_parent();
	
	if parent and parent.is_in_group("Projectile"):
		if parent.get_attacker() != self:
			pass
			#take_damage(1);

func _exit_tree():
	pass;
