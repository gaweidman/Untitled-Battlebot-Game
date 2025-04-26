extends PartPassive

class_name PartScrapPlating

func _process(delta):
	super(delta);
	if inventoryNode is InventoryPlayer:
		bonusHP = clamp(inventoryNode.get_scrap_total() * 0.05, 0, 3.0);
