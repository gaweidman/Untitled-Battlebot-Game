extends CombatHandler

class_name CombatHandlerPlayer

var inputHandler : InputHandler;
var inventory : InventoryPlayer;

var player;

@export var activeSlotTab0 : ActiveSlotTab;
@export var activeSlotTab1 : ActiveSlotTab;
@export var activeSlotTab2 : ActiveSlotTab;

var activeSlotTabs := {};

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inputHandler = $"../InputHandler"
	player = GameState.get_player();
	inventory = GameState.get_inventory();
	activeSlotTabs = {
		0 : activeSlotTab0,
		1 : activeSlotTab1,
		2 : activeSlotTab2,
	}
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	super(delta);
	if Input.is_key_pressed(KEY_P):
		take_damage(0.5);
		inventory.add_scrap(99999);
	pass

func take_damage(damage:float):
	super(damage);
	GameState.get_hud().update();
	inventory.take_damage(damage);

func die():
	player.body.hide();
	player.freeze();
	GameState.set_game_board_state(GameBoard.gameState.GAME_OVER)
	if is_instance_valid(inventory):
		inventory.inventory_panel_toggle(false);
	pass;

func live():
	health = maxHealth;
	energy = maxEnergy;
	pass;

func _on_collision(collider):
	super(collider);
	#var parent = collider.get_parent();
	#if parent and parent.is_in_group("Projectile"):
	#	if parent.get_attacker() != self:
	#		pass
	#		#take_damage(1);
	pass;

##Adds a part at the given index. Custom version for the player.
func set_active_part(part:PartActive, index:int, override := true):
	if override:
		print(get_active_part(index));
		remove_active_part(index);
		activeParts[index] = part;
		activeSlotTabs[index].partRef = part;
		#print("new part equipped with override: ", part.partName);
		part.call_deferred("set_equipped", true);
		return;
	else:
		if is_active_slot_empty(index):
			print(get_active_part(index));
			activeParts[index] = part;
			activeSlotTabs[index].partRef = part;
			#print("new part equipped: ", part.partName);
			part.call_deferred("set_equipped", true);
			return;
	push_warning("Attempted to add to slot "+ str(index)+" which either doesn't exist or is full.");
	return;

func remove_active_part(index):
	var part = get_active_part(index)
	if part != null:
		if part is PartActive:
			if ! check_active_slots_for_part(part, index):
				part.call_deferred("set_equipped", false);
	#print("part being removed: ", part);
	activeParts[index] = null;
	activeSlotTabs[index].partRef = null;

func get_active_part(index):
	if is_instance_valid(activeParts[index]):
		var part = activeParts[index]
		return part;
	return null;

func check_active_slots_for_part(part:Part, ignoreIndex:int):
	if get_active_part(0) == part && ignoreIndex != 0: return true;
	if get_active_part(1) == part && ignoreIndex != 1: return true;
	if get_active_part(2) == part && ignoreIndex != 2: return true;
	return false;

##Reassigns the player's selected part to the slot specified.
func _on_active_reassignment_buttons_reassignment_button_pressed(index):
	set_active_part(inventory.get_selected_part(), index);
	pass # Replace with function body.
