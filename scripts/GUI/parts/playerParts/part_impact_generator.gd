extends PartPassive

class_name Part_ImpactGenerator

func take_damage(damage:float):
	super(damage);
	if damage > 0:
		thisBot.combatHandler.energy += 2;
