extends PartActive;

class_name PartRepair

@export var scrapCost = 15;
@export var healing = 2.0;

func _activate():
	if ! thisBot.at_max_health():
		if super():
			if inventoryNode is InventoryPlayer:
				if inventoryNode.is_affordable(scrapCost):
					inventoryNode.remove_scrap(12);
					thisBot.take_damage(-healing);
					fx(true)
			else:
				fx()
				thisBot.take_damage(-healing);

func can_fire():
	if ! is_instance_valid(thisBot): return false;
	if thisBot.at_max_health(): return false;
	if ! inventoryNode.is_affordable(scrapCost): return false;
	return super();

func fx(player:=false):
	var pos = thisBot.body.global_position
	var parent = GameState.get_game_board()
	if player:
		ParticleFX.play("NutsBolts", parent, pos)
		SND.play_sound_nondirectional("Shop.Chaching")
	else:
		ParticleFX.play("NutsBolts", parent, pos)
		SND.play_sound_at("Shop.Chaching", pos);
