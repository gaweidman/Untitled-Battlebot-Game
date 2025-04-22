extends EnemyBase

class_name EnemyRanger

func _process(delta):
	super(delta);
	if is_instance_valid(inventory):
		inventory.add_part_from_scene(0,0,"res://scenes/prefabs/objects/parts/enemyParts/part_ranger_gun.tscn",0);

func _physics_process(delta):
	if not is_asleep():
		if GameState.is_player_in_range(body.global_position, 20) and not GameState.is_player_in_range(body.global_position, 5):
			combatHandler.use_active(InputHandler.FIRE.SLOT1);
			
			pass;
			
