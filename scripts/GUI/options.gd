extends Control

@export var box_music := SpinBox;
@export var box_UI := SpinBox;
@export var box_world := SpinBox;
@export var box_master := SpinBox;
var snd : SND;

func _process(delta):
	if ! is_instance_valid(snd):
		snd = SND.get_physical();

func _on_btn_reset_pressed():
	reset();
	pass # Replace with function body.

func reset():
	box_music.value = 100.0;
	box_UI.value = 90.0;
	box_world.value = 80.0;
	box_master.value = 100.0;
	invShooting.button_pressed = true;
	devCheats.button_pressed = false;

func _on_music_volume_value_changed(value):
	var vol = (value * 1.3) / 100.0
	print(vol)
	if is_instance_valid(snd):
		snd.set_volume_music(vol);
	pass # Replace with function body.

func _on_master_volume_value_changed(value):
	var vol = value / 100.0
	if is_instance_valid(snd):
		snd.set_volume_master(vol);
	pass # Replace with function body.

func _on_ui_volume_value_changed(value):
	var vol = value / 100.0
	if is_instance_valid(snd):
		snd.set_volume_UI(vol);
	pass # Replace with function body.

func _on_world_volume_value_changed(value):
	var vol = value / 100.0
	if is_instance_valid(snd):
		snd.set_volume_world(vol);
	pass # Replace with function body.


func _on_inv_shooting_toggled(toggled_on):
	GameState.set_setting("inventoryDisableShooting", toggled_on);
	pass # Replace with function body.

@export var invShooting : CheckButton;
@export var devCheats : CheckButton;
@export var moneyCheat : CheckButton;
@export var invincibleCheat : CheckButton;

func _on_dev_cheats_toggled(toggled_on):
	GameState.set_setting("devMode", toggled_on);
	if ! toggled_on:
		moneyCheat.button_pressed = false;
		invincibleCheat.button_pressed = false;
		moneyCheat.hide();
		invincibleCheat.hide();
	else:
		moneyCheat.show();
		invincibleCheat.show();
	moneyCheat.disabled = !toggled_on;
	invincibleCheat.disabled = !toggled_on;
	pass # Replace with function body.

func _on_moneys_toggled(toggled_on):
	if toggled_on:
		GameState.set_setting("startingScrap", 99999999);
	else:
		GameState.set_setting("startingScrap", 0);
	pass # Replace with function body.

func _on_godmode_toggled(toggled_on):
	GameState.set_setting("godMode", toggled_on);
	pass # Replace with function body.

func _on_sawblade_drone_toggled(toggled_on):
	GameState.set_setting("sawbladeDrone", toggled_on);
	pass # Replace with function body.
