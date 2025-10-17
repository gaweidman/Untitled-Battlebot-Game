extends Robot

class_name Robot_Player

var gameHUD : GameHUD;
var barHP : healthBar;
var barEnergy : healthBar;

func _ready():
	super();

func stat_registry():
	super();

func grab_references():
	super();
	if !is_instance_valid(gameHUD):
		gameHUD = GameState.get_game_hud();
	if is_instance_valid(gameHUD):
		if !is_instance_valid(barHP):
			barHP = GameState.get_bar_hp();
		if !is_instance_valid(barEnergy):
			barEnergy = GameState.get_bar_energy();
		if !is_instance_valid(engineViewer):
			engineViewer = GameState.get_engine_viewer();


######################## INPUT MANAGEMENT

func phys_process_timers(delta):
	super(delta);
	forcedUpdateTimerHUD -= 1;
	if forcedUpdateTimerHUD <= 0:
		forcedUpdateTimerHUD = 5;
		update_bars();

func phys_process_combat(delta):
	super(delta);
	if Input.is_action_just_pressed("Fire0"):
		if fire_active(0):
			print("Ability? ",active_abilities[0].abilityName)
	if Input.is_action_just_pressed("Fire1"):
		if fire_active(1):
			print("Ability? ",active_abilities[1].abilityName)
	if Input.is_action_just_pressed("Fire2"):
		if fire_active(2):
			print("Ability? ",active_abilities[2].abilityName)
	if Input.is_action_just_pressed("Fire3"):
		if fire_active(3):
			print("Ability? ",active_abilities[3].abilityName)
	#if Input.is_action_just_pressed("Fire4"):
		#fire_active(4);

func get_movement_vector(rotatedByCamera : bool = true) -> Vector2:
	movementVector = Vector2.ZERO
		
	if Input.is_action_pressed("MoveLeft"):
		movementVector += Vector2.LEFT;
		
	if Input.is_action_pressed("MoveRight"):
		movementVector += Vector2.RIGHT;
		
	if Input.is_action_pressed("MoveUp"):
		movementVector += Vector2.UP;
		
	if Input.is_action_pressed("MoveDown"):
		movementVector += Vector2.DOWN;
	
	if rotatedByCamera:
		if not is_instance_valid(camera):
			camera = GameState.get_camera();
		
		var camRotY = - camera.targetRotationY;
		
		movementVector = movementVector.rotated(camRotY);
	
	if is_inputting_movement():
		movementVectorRotation = movementVector.angle();
	return movementVector.normalized();

func is_inputting_movement() -> bool:
	inputtingMovementThisFrame = false;
	#print("ASDASDASD")
	if GameState.get_in_state_of_play() and is_conscious():
		if Input.is_action_pressed("MoveLeft"):
			inputtingMovementThisFrame = true;
			return inputtingMovementThisFrame;
			
		if Input.is_action_pressed("MoveRight"):
			inputtingMovementThisFrame = true;
			return inputtingMovementThisFrame;
			
		if Input.is_action_pressed("MoveUp"):
			inputtingMovementThisFrame = true;
			return inputtingMovementThisFrame;
			
		if Input.is_action_pressed("MoveDown"):
			inputtingMovementThisFrame = true;
			return inputtingMovementThisFrame;
	
	return inputtingMovementThisFrame;

func die():
	#Hooks.OnDeath(self, GameState.get_player()); ##TODO: Fix hooks to use new systems before uncommenting this.
	alive = false;
	hide();
	freeze(true, true);
	gameBoard.game_over();
	
	##Play the death sound
	if GameState.get_in_state_of_play():
		#SND.play_sound_nondirectional(deathSound);
		SND.play_sound_nondirectional("Combatant.Die");
	##Play the death particle effects.
	ParticleFX.play("NutsBolts", GameState.get_game_board(), get_global_body_position());
	ParticleFX.play("BigBoom", GameState.get_game_board(), get_global_body_position());
	
	#print("Searching for Sockets ", Utils.get_all_children(self).size())
	#print("Searching for Sockets, checking ownership ", Utils.get_all_children(self, self).size())
	#print(Utils.get_all_children(self, self))

#################### COMBAT HANDLING

func update_bars():
	if is_instance_valid(barHP) and is_instance_valid(barEnergy):
		var currentHealth = get_health();
		var currentHealthMax = get_max_health();
		#print(currentHealth);
		barHP.set_health(currentHealth, currentHealthMax);
		barHP.set_alt_color(invincible);
		
		var currentEnergy = get_available_energy();
		var currentEnergyMax = get_maximum_energy();
		barEnergy.set_health(currentEnergy, currentEnergyMax);

func _on_health_or_energy_changed():
	super();
	update_bars();
	pass # Replace with function body

############# HUD
