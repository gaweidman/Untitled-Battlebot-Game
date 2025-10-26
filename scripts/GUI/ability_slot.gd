@icon ("res://graphics/images/class_icons/abilitySlot.png")
extends Control
class_name AbilitySlot
## The visual representation on the [GameHUD] for each of the player's currently equipped Active Abilities ([member Robot.active_abilities]).

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
@export var lbl_energy : Label;
@export var bar_cooldown : HealthBar;
@export var bar_energy : HealthBar;
@export var blinky_energy : TextureRect;
@export var blinky_usable : TextureRect;
@export var misc_energy : Control;
@export var energyCase : TextureRect;
@export var misc_ammo : Control;
@export var misc_magazine : MagazineSlicer;
@export var misc_text : Label;
@export var lbl_cooldownCurrent : Label;
#@export var lbl_cooldownSlash : Label;
#@export var lbl_cooldownStart : Label;
@export var blinky_cooldown : TextureRect;


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
		TextFunc.set_text_color(lbl_name, "white");
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
	
	## Energy. Deals with both the bar, as well as the icon in the misc window.
	var incomingEnergy = data.incomingPower;
	var requiredEnergy = data.requiredEnergy;
	var hasAvailableEnergy = incomingEnergy >= requiredEnergy;
	blinky_energy.visible = hasAvailableEnergy;
	bar_energy.set_health(min(incomingEnergy, requiredEnergy), requiredEnergy);
	bar_energy.set_alt_color(hasAvailableEnergy);
	var barTooltip = bar_energy.tooltip_text;
	misc_energy.tooltip_text = barTooltip;
	misc_energy.visible = true;
	energyCase.tooltip_text = barTooltip;
	
	var usable = data.usable;
	blinky_usable.visible = usable;
	
	## Miscellaneous text.
	var miscTextDat = "";
	if data.has("miscText"):
		miscTextDat = data["miscText"];
	misc_text.text = miscTextDat;
	misc_text.tooltip_text = miscTextDat;
	
	## Magazine.
	var showMagazine = false;
	if data.has("showMagazine"):
		if data["showMagazine"] == true:
			showMagazine = true;
			var magSize = data["magazineSize"];
			var magAmt = data["magazineAmt"];
			var cooldownTime = data["regenBulletCooldown"];
			var cooldownTimeStart = data["regenBulletCooldownStart"];
			#var cooldownPercent = data["regenBulletPercent"];
			#var cooldownPercent = 1.0;
			misc_magazine.update_contents(magSize, magAmt, cooldownTime, cooldownTimeStart);
	misc_magazine.visible = showMagazine;
	
	## Cooldown.
	var cooldownStartTime = data["cooldownStartTime"];
	if not (cooldownStartTime == 0.0 or is_zero_approx(cooldownStartTime)):
		var cooldownTime = data["cooldownTime"];
		var onCooldown = data["onCooldown"];
		blinky_cooldown.visible = onCooldown;
		lbl_cooldownCurrent.text = TextFunc.format_stat(cooldownTime, 2, false, true);
	else:
		blinky_cooldown.visible = true;
		lbl_cooldownCurrent.text = "     ";
	#lbl_cooldownStart.text = TextFunc.format_stat(cooldownStartTime, 2, false, true);
	#lbl_cooldownSlash.text = "/";

func clear_assignment():
	referencedAbility = null;
	lbl_name.text = "Ability Slot Empty";
	TextFunc.set_text_color(lbl_name, "lightred");
	bar_energy.set_health(0, 0);
	blinky_energy.visible = false;
	blinky_usable.visible = false;
	blinky_cooldown.visible = false;
	misc_magazine.visible = false;
	misc_magazine.update_contents(-1,-1,0,0);
	misc_energy.visible = false;
	misc_text.text = "";
	misc_text.tooltip_text = "";
	lbl_cooldownCurrent.text = "";
	#lbl_cooldownStart.text = "";
	#lbl_cooldownSlash.text = "";
	pass;
