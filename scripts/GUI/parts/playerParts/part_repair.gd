extends PartActive;

class_name PartRepair

@export var scrapCost = 15;
@export var healing = 2.0;

func _activate():
	if ! thisBot.at_max_health():
		super();
		if inventoryNode is InventoryPlayer:
			inventoryNode.remove_scrap(12);
		thisBot.take_damage(-healing);
