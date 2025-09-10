extends Control;
var TEXTUREPATH = "res://graphics/images/HUD/";
var gameBoard : GameBoard;
var refreshTimer = 0;
var ply : Player;
@export var MainMenuLogo : TextureRect;
var logoRotationSwitch = 1;
var logoRotationTarget = 0.0;

var pauseMenuUp := false;
var pauseOptionsUp := false;

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
			toggle_pause(!pauseMenuUp);
		
		if pauseOptionsUp: 
			if $Options.visible == false:
				$Options.open_sesame(true);
		else:
			if pauseOptionsUp:
				toggle_pause_options(false);
	else:
		if pauseMenuUp:
			toggle_pause(false);
	
	#if is_instance_valid($Pause) and is_instance_valid($Pause/Btn_EndRun) and is_instance_valid($Pause/Btn_Options):
	if pauseMenuUp:
		$Pause.global_position.y = lerp($Pause.global_position.y, 0.0, _delta * 30);
	else:
		$Pause.global_position.y = lerp($Pause.global_position.y, -100.0, _delta * 30);
	
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

func _on_btn_pause_options_pressed():
	toggle_pause_options(!pauseOptionsUp)
	pass # Replace with function body.

func toggle_pause_options(toggle):
	if pauseMenuUp:
		pauseOptionsUp = toggle;
		$Options.open_sesame(toggle);
		if is_instance_valid(ply):
			ply.inventory.inventory_panel_toggle(false);
	else:
		pauseOptionsUp = false;
		$Options.open_sesame(false);

func toggle_pause(toggle):
	pauseMenuUp = toggle;
	$Pause/Btn_EndRun.disabled = !toggle;
	$Pause/Btn_PauseOptions.disabled = !toggle;
	if toggle:
		pass;
	else:
		toggle_pause_options(false);
