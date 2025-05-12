extends PartPassive

class_name PartTurtleCoil

func _physics_process(delta):
	#super(delta);
	if is_instance_valid(thisBot):
		if is_instance_valid(thisBot.body):
			if ownedByPlayer:
				var length = thisBot.body.linear_velocity.length();
				if length <= 5.0:
					var bonus = (5 - length) / 5;
					bonusEnergyRegen = move_toward(bonusEnergyRegen, bonus, delta / 2);
				else:
					bonusEnergyRegen = 0;
				print(length);
