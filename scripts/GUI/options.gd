extends Control

@export var box_music : SpinBox;
@export var box_UI : SpinBox;
@export var box_world : SpinBox;
@export var box_master : SpinBox;
var snd : SND;

@export var invShooting : CheckButton;
@export var sawbladeDrone : CheckButton;

@export var devCheats : CheckButton;
@export var moneyCheat : CheckButton;
@export var invincibleCheat : CheckButton;
@export var killAllCheat : CheckButton;
@export var cheatsControl : Control;

@export var btn_scoreReset : Button;
@export var lbl_highScores : RichTextLabel;

var loadingSettings := false;

func load_settings():
	#return
	loadingSettings = true;
	invShooting.button_pressed = GameState.get_setting("inventoryDisableShooting");
	sawbladeDrone.button_pressed = GameState.get_setting("sawbladeDrone");
	moneyCheat.button_pressed = GameState.get_setting("startingScrap") == 99999999;
	invincibleCheat.button_pressed = GameState.get_setting("godMode");
	killAllCheat.button_pressed = GameState.get_setting("killAllKey");
	loadingSettings = false;
	
	devCheats.button_pressed = GameState.get_setting("devMode");
	
	if ! is_instance_valid(snd):
		snd = SND.get_physical();
	
	var musicValue = (GameState.get_setting("volumeLevelMusic") / 1.3) * 100.0
	box_music.set_deferred("value", musicValue);
	
	var UIValue = GameState.get_setting("volumeLevelUI") * 100.0;
	box_UI.set_deferred("value",UIValue);
	
	var worldValue = GameState.get_setting("volumeLevelWorld") * 100.0;
	box_world.set_deferred("value", worldValue);
	
	var masterValue = GameState.get_setting("volumeLevelMaster") * 100.0;
	box_master.set_deferred("value", masterValue);

func _process(delta):
	if ! is_instance_valid(snd):
		snd = SND.get_physical();
	
	if cheatsControl.visible == false:
		if devCheats.button_pressed:
			cheatsControl.show();
	else:
		if devCheats.button_pressed == false:
			cheatsControl.hide();

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
	sawbladeDrone.button_pressed = true;
	#drone


func _on_music_volume_value_changed(value):
	var vol = (value * 1.3) / 100.0
	print(vol)
	if is_instance_valid(snd):
		prints("[color=purple]Music volume being adjusted to "+str(value))
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
	if not loadingSettings:
		GameState.set_setting("inventoryDisableShooting", toggled_on);
	pass # Replace with function body.

func _on_dev_cheats_toggled(toggled_on):
	if not loadingSettings:
		GameState.set_setting("devMode", toggled_on);
		if ! toggled_on:
			moneyCheat.button_pressed = false;
			invincibleCheat.button_pressed = false;
			killAllCheat.button_pressed = false;
			cheatsControl.hide();
		else:
			cheatsControl.show();
		moneyCheat.disabled = !toggled_on;
		invincibleCheat.disabled = !toggled_on;
		killAllCheat.disabled = !toggled_on;
	pass # Replace with function body.

func _on_moneys_toggled(toggled_on):
	if not loadingSettings:
		if toggled_on:
			GameState.set_setting("startingScrap", 99999999);
		else:
			GameState.set_setting("startingScrap", 0);
	pass # Replace with function body.

func _on_godmode_toggled(toggled_on):
	if not loadingSettings:
		GameState.set_setting("godMode", toggled_on);
	pass # Replace with function body.

func _on_killall_toggled(toggled_on):
	if not loadingSettings:
		GameState.set_setting("killAllKey", toggled_on);
	pass # Replace with function body.

func _on_sawblade_drone_toggled(toggled_on):
	if not loadingSettings:
		GameState.set_setting("sawbladeDrone", toggled_on);
	pass # Replace with function body.

func open_sesame(toggle):
	if toggle:
		update_score_text();
		show();
	else:
		hide();
	pass

func update_score_text():
	var scores = GameState.load_data();
	
	lbl_highScores.clear();
	lbl_highScores.append_text("[i][b]STATS[/b]");
	lbl_highScores.newline();
	lbl_highScores.append_text("HIGHEST ROUND: " + str(scores[StringName("Highest Round")]));
	lbl_highScores.newline();
	lbl_highScores.append_text("MOST ENEMIES KILLED: " + str(scores[StringName("Most Enemies Killed")]));
	lbl_highScores.newline();
	lbl_highScores.append_text("MOST SCRAP GAINED: " + str(scores[StringName("Most Scrap Earned")]));

func _on_btn_scores_reset_pressed():
	GameState.reset_data();
	update_score_text();
	pass # Replace with function body.
