extends PartActive

class_name PartJump

var jumpMod := 1.0;

func _activate():
	if thisBot is Player:
		if super():
			var inDir = thisBot._get_input_handler().get_movement_vector()
			var pos = thisBot.body.global_position
			var parent = GameState.get_game_board()
			ParticleFX.play("SmokePuffSingle", parent, pos);
			SND.play_sound_at("Movement.Dash", pos, parent, 1.0, randf_range(1.3, 1.6));
			thisBot.take_knockback(Vector3(0, 700*jumpMod, 0));
			thisBot.combatHandler.add_invincibility(0.30 * jumpMod);

func mods_conditional():
	var jumpModNew := 1.0
	var checkPos1 = Vector2i(0,3) + invPosition;
	var checkResult1 = inventoryNode.is_slot_free_and_in_bounds(checkPos1.x, checkPos1.y, null, true);
	push_warning(checkResult1);
	var free1 = checkResult1.free;
	var inBounds1 = checkResult1.inBounds;
	if free1 or (!inBounds1):
		jumpModNew = 1.25
		var checkPos2 = Vector2i(0,4) + invPosition;
		var checkResult2 = inventoryNode.is_slot_free_and_in_bounds(checkPos2.x, checkPos2.y, null, true);
		push_warning(checkResult2);
		var free2 = checkResult2.free;
		var inBounds2 = checkResult2.inBounds;
		if free2 or (!inBounds2):
			jumpModNew = 1.5;
	jumpMod = jumpModNew;
