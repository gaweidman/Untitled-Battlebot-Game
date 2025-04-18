extends CombatHandler

class_name CombatHandlerPlayer

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
	super(delta);
	if Input.is_key_pressed(KEY_P):
		take_damage(0.5);
	pass

func take_damage(damage:float):
	super(damage);
			
	GameState.get_hud().update();

func die():
	get_parent().hide();
	GameState.set_game_board_state(GameBoard.gameState.GAME_OVER)
	inventory.inventory_panel_toggle(false);
	pass;

func live():
	health = maxHealth;
	energy = maxEnergy;
	pass;

func _on_collision(collider):
	#super(collider);
	#var parent = collider.get_parent();
	#if parent and parent.is_in_group("Projectile"):
	#	if parent.get_attacker() != self:
	#		pass
	#		#take_damage(1);
	pass;
