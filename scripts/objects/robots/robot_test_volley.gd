extends Robot

func phys_process_timers(delta):
	super(delta);
	
	testTimer -= delta;

var testTimer := 5.0;
func phys_process_combat(delta):
	super(delta);
	if testTimer < 0:
		testTimer += 2;
		var randomIndex = randi_range(0,4);
		for abilityIndex in active_abilities:
			var ability = active_abilities[abilityIndex];
			if ability is AbilityManager:
				ability.call_ability();
