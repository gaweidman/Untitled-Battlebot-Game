extends Control

class_name EnemyProgressBar

var updateTimer := 0.0;
var progress := 0.0;
var progressBarTargetX := 24.0;
@onready var length := float(size.x);

var buttonModeSwitchCounter = 0;
var buttonMode:= true;
var buttonScreenOnA = preload("res://graphics/images/HUD/nextRound/screen_on.png");
var buttonScreenOnB = preload("res://graphics/images/HUD/nextRound/screen_onB.png");

@export var nextWaveButton_gfx : TextureButton;
@export var nextWaveButton_big : Button;
@export var progressBar : TextureRect;
@export var Lbl_EnemiesLeft : Label;

func _process(delta):
	if updateTimer > 0:
		updateTimer -= delta;
	else:
		updateTimer = 0.10
		update();
	progressBar.position.x = move_toward(progressBar.position.x, progressBarTargetX, delta * 340);

func update():
	if GameState.get_in_state_of_play():
		if not progressBar.visible:
			progressBar.show()
		progress = GameState.get_round_completion();
		#print(length)
		#print(progress)
		progressBarTargetX = (1.0 - progress) * -length
		var enemiesLeft = GameState.get_wave_enemies_left();
		Lbl_EnemiesLeft.text = str(enemiesLeft);
		
		if enemiesLeft > 0 or not is_equal_approx(progressBar.position.x, -length):
			nextWaveButton_gfx.disabled = true;
			nextWaveButton_big.disabled = true;
		else:
			nextWaveButton_gfx.disabled = false;
			nextWaveButton_big.disabled = false;
			
			##Makes the 'go' button flash fancy-like
			if buttonModeSwitchCounter >= 2:
				if buttonMode:
					nextWaveButton_gfx.set_deferred("texture_normal", buttonScreenOnB)
					buttonMode = false;
				else:
					nextWaveButton_gfx.set_deferred("texture_normal", buttonScreenOnA)
					buttonMode = true;
				buttonModeSwitchCounter = 0;
			else:
				buttonModeSwitchCounter +=1;
	else:
		nextWaveButton_gfx.disabled = true;
		nextWaveButton_big.disabled = true;
		if progressBar.visible:
			progressBar.hide()

func _on_next_wave_button_pressed():
	var board = GameState.get_game_board();
	board.change_state(GameBoard.gameState.INIT_ROUND);
	pass # Replace with function body.
