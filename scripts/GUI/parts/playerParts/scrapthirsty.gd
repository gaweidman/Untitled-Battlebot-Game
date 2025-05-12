extends PartPassive

class_name PartScrapthirsty

func _ready():
	super();
	Hooks.add(self, "OnGainScrap", "Scrapthirsty" + str(ageOrdering), 
	func(source:String, amt:int):
		if is_instance_valid(thisBot):
			if thisBot is Player:
				if ownedByPlayer:
					if source == "Kill":
						if amt > 0:
							thisBot.take_damage(-0.035 * amt);
	)
