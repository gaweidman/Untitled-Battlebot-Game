extends PartPassive

class_name PartImpactMagnet

@export var scrapAmount := 1;

func take_damage(damage:float):
	super(damage);
	if damage > 0:
		if inventoryNode is InventoryPlayer:
			inventoryNode.add_scrap(scrapAmount);
