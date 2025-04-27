extends PartActive;

class_name PartRepair

@export var scrapCost = 15;
@export var healing = 2.0;

func _activate():
	if ! thisBot.at_max_health():
		super();
		if inventoryNode is InventoryPlayer:
			if inventoryNode.is_affordable(scrapCost):
				inventoryNode.remove_scrap(12);
				thisBot.take_damage(-healing);
				SND.play_sound_nondirectional("Shop.Chaching")
		else:
			thisBot.take_damage(-healing);
			SND.play_sound_at("Shop.Chaching", thisBot.body.global_position);

func can_fire():
	if ! is_instance_valid(thisBot): return false;
	if thisBot.at_max_health(): return false;
	if ! inventoryNode.is_affordable(scrapCost): return false;
	return super();
