extends EnemyRanger

class_name EnemySoldier

func add_gun():
	inventory.add_part_from_scene(0,0,"res://scenes/prefabs/objects/parts/enemyParts/part_soldier_cannon.tscn",0);
	inventory.add_part_from_scene(0,0,"res://scenes/prefabs/objects/parts/playerParts/part_sawblade.tscn",1);
