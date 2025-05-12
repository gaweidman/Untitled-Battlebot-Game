extends PartPassive

class_name Part_ImpactGenerator

var bonusActive := false;

func take_damage(damage:float):
	super(damage);
	if damage > 0:
		bonusActive = true;
		$EnergyBoostTimer.start(3.0);

func _process(delta):
	super(delta);
	if bonusActive:
		bonusEnergyRegen = 1.5;
	else: 
		bonusEnergyRegen = move_toward(bonusEnergyRegen, 0.0, delta  / 2);

func _on_energy_boost_timer_timeout():
	bonusActive = false;
	pass # Replace with function body.
