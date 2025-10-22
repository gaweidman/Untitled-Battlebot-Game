extends Control

class_name AbilitySlot

enum modes {
	NONE,
	ASSIGNING,
}
var curMode : modes = modes.NONE;
@export var btn_assign : Button;
@export var prevSlot : AbilitySlot;
@export var nextSlot : AbilitySlot;
@export var manager : AbilitySlotManager;
@export var lbl_name : Label;
@export var bar_cooldown : healthBar;
@export var bar_energy : healthBar;
@export var blinky_energy : TextureRect;

var index : int;
var referencedAbility : AbilityManager;

func _ready():
	focus_next = get_path_to(nextSlot);
	focus_previous = get_path_to(prevSlot);
	clear_assignment();

func _process(delta):
	update_ability(referencedAbility);
	
	match curMode:
		modes.NONE:
			btn_assign.visible = false;
			btn_assign.disabled = true;
			pass;
		modes.ASSIGNING:
			btn_assign.visible = true;
			btn_assign.disabled = false;
			pass;
		_:
			curMode = modes.NONE;
			pass;
	
	
func _on_assign_pressed():
	manager.button_pressed.emit(self);
	pass # Replace with function body.


func assign_ability(ability : AbilityManager):
	if ! (ability != referencedAbility):
		return;
	if is_instance_valid(ability):
		print("Ability assigned!")
		referencedAbility = ability;
		#TextFunc.set_text_color(lbl_name, "white");
		lbl_name.text = ability.abilityName;
		update_ability(ability);
	else:
		clear_assignment();
	pass;

var counter := 0.;
func update_ability(ability : AbilityManager):
	counter += 1;
	if counter > 200:
		counter = 0;
	if ! is_instance_valid(ability):
		clear_assignment();
		return;
	var data = ability.get_ability_slot_data();
	if not data is Dictionary: ## If the data is invalid, no more of it.
		clear_assignment();
		return;
	var incomingEnergy = data.incomingPower;
	var requiredEnergy = data.requiredEnergy;
	print("what")
	blinky_energy.visible = incomingEnergy >= requiredEnergy;
	bar_energy.set_health(min(incomingEnergy, requiredEnergy), requiredEnergy);

func clear_assignment():
	referencedAbility = null;
	lbl_name.text = "Ability Slot Empty";
	#TextFunc.set_text_color(lbl_name, "lightred");
	bar_energy.set_health(0, 3);
	pass;
