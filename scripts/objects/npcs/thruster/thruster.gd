extends EnemyBase;

class_name Thruster;

func _process(delta):
	super(delta);
	if is_instance_valid(inventory):
		inventory.add_part_from_scene(0,0,"res://scenes/prefabs/objects/parts/playerParts/part_sawblade.tscn",0);
