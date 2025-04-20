extends PartPassive

class_name Part_RoundBell

@export var healAmount := 0.25

func end_round():
	super();
	thisBot.take_damage(-healAmount);
