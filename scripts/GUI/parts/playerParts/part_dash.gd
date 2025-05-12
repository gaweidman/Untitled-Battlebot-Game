extends PartActive

class_name PartDash

func _activate():
	if thisBot is Player:
		if super():
			var inDir = thisBot._get_input_handler().get_movement_vector()
			var pos = thisBot.body.global_position
			var parent = GameState.get_game_board()
			ParticleFX.play("SmokePuffSingle", parent, pos);
			SND.play_sound_at("Movement.Dash", pos, parent, 1.0, randf_range(0.8, 1.2));
			thisBot.body.linear_velocity.x = 0;
			thisBot.body.linear_velocity.z = 0;
			thisBot.take_knockback(Vector3(inDir.x * -1300, 600, inDir.y * -1300));
			thisBot.combatHandler.add_invincibility(0.20);

func can_fire():
	if super():
		if thisBot is Player:
			var under = thisBot.underbelly;
			if under.is_on_driveable():
				return true;
	return false;
