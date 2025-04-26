extends Control;
var TEXTUREPATH = "res://graphics/images/HUD/";
var gameBoard : GameBoard;
var refreshTimer = 0;

var pauseMenuUp := false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass; # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if refreshTimer <= 0:
		refreshTimer = 0.5;
		if is_instance_valid(gameBoard):
			update();
		else:
			gameBoard = GameState.get_game_board();
	else:
		refreshTimer -= _delta;
	
	if GameState.get_in_state_of_play():
		if Input.is_action_just_pressed("Pause"):
			pauseMenuUp = !pauseMenuUp;
	else:
		pauseMenuUp = false;
	
	if pauseMenuUp:
		$Pause.global_position.y = lerp($Pause.global_position.y, 0.0, _delta * 30);
		$Pause/Btn_EndRun.disabled = false;
	else:
		$Pause.global_position.y = lerp($Pause.global_position.y, -100.0, _delta * 30);
		$Pause/Btn_EndRun.disabled = true;

func update() -> void:
	var ply = GameState.get_player();
		#var newPos = $EnemyPings.position.x, $EnemyPings.position.z
		 #= enemy.global_position;
		#var screen = 
	#if ply and %Health and %HealthLabel and %Ammo and %AmmoLabel:
		#%Health.update(ply.get_health());
		#%HealthLabel.text = str(ply.get_health(false));
		#%Ammo.update(ply.get_ammo());
		#%AmmoLabel.text = str(ply.get_ammo(false));
