extends PartPassive

class_name Part_ImpactGenerator

var bonusActive := false;

func take_damage(damage:float):
	super(damage);
	if damage > 0:
		bonusActive = true;
		$EnergyBoostTimer.start(1.0);

func _process(delta):
	super(delta);
	if bonusActive:
		bonusEnergyRegen = 2.0;
	else: 
		bonusEnergyRegen - 0.0;

func _on_energy_boost_timer_timeout():
	bonusActive = false;
	pass # Replace with function body.
