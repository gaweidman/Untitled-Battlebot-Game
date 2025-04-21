extends EnemyBase

class_name EnemyRanger

func _process(delta):
	super(delta);
	if is_instance_valid(inventory):
		inventory.add_part_from_scene(0,0,"res://scenes/prefabs/objects/parts/enemyParts/part_ranger_gun.tscn",0);

func _physics_process(delta):
	var offset = GameState.get_player_pos_offset(body.global_position)

	var lenToPlayer = offset.length();
	#Vector3.
	#print(lenToPlayer)
	if lenToPlayer <= 20:
		combatHandler.use_active(InputHandler.FIRE.SLOT1);
		
		pass;
		
