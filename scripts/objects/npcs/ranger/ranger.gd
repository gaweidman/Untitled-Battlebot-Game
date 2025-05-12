extends EnemyBase

class_name EnemyRanger

func _process(delta):
	super(delta);
	if is_instance_valid(inventory):
		add_gun();

func add_gun():
	inventory.add_part_from_scene(0,0,"res://scenes/prefabs/objects/parts/enemyParts/part_ranger_gun.tscn",0);

var noFireTimer := 0.1;

func _physics_process(delta):
	if not is_asleep():
		if GameState.is_player_in_range(body.global_position, 20) and not GameState.is_player_in_range(body.global_position, 5) and GameState.is_player_alive():
			##This massive daisy chain below checks very meticulously if the gun can fire, then if its raycast is hitting the player's body specifically
			var gun = combatHandler.get_active_part(0);
			if gun is PartActiveProjectile:
				if gun.can_fire():
					var thingInRange = gun.get_closest_thing_in_line_of_fire();
					if thingInRange != null:
						if thingInRange is RigidBody3D:
							if is_instance_valid(thingInRange.get_parent()):
								if thingInRange.get_parent() is Player:
									noFireTimer -= delta;
									if noFireTimer <= 0:
										combatHandler.use_active(InputHandler.FIRE.SLOT0);
								else: noFireTimer = 0.15;
							else: noFireTimer = 0.15;
						else: noFireTimer = 0.15;
					else: noFireTimer = 0.15;
			pass;
