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
	box_UI.value = 100.0;
	box_world.value = 100.0;
	box_master.value = 100.0;

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
