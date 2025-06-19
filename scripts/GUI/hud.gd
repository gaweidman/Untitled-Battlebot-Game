extends Control;
var TEXTUREPATH = "res://graphics/images/HUD/";
var gameBoard : GameBoard;
var refreshTimer = 0;
var ply : Player;
@export var MainMenuLogo : TextureRect;
var logoRotationSwitch = 1;
var logoRotationTarget = 0.0;

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
	
	if logoRotationSwitch > 0:
		if MainMenuLogo.rotation < deg_to_rad(4):
			logoRotationTarget += 0.025 * _delta;
		else:
			logoRotationSwitch = -1;
	else:
		if MainMenuLogo.rotation > deg_to_rad(-4):
			logoRotationTarget -= 0.025 * _delta;
		else:
			logoRotationSwitch = 1;
	logoRotationTarget = clamp(logoRotationTarget, -4, 4)
	MainMenuLogo.rotation = lerp(MainMenuLogo.rotation, logoRotationTarget, _delta * 3)

func update() -> void:
	if ! is_instance_valid(ply):
		ply = GameState.get_player();
