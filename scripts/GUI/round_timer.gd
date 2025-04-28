extends Label

class_name DeathTimer

var blinkCycle := 0.0;
var blinkTimer := 0.0;

var time := 120.0;
var paused := true;

func _process(delta):
	
	text = format_time(time);
	
	if not paused:
		if time > 0:
			if GameState.get_game_board_state() == GameBoard.gameState.PLAY: ##This time it's specific
				time -= delta;
		else:
			time = 0.0;
		
		if blinkTimer > 0:
			blinkTimer -= delta;
			$TimerBlinky.show();
		else:
			$TimerBlinky.hide();
		
		blinkCycle -= delta;
		if blinkCycle < 0:
			if time <= 90.0:
				blink();
				blinkCycle = max(0.1, time / 60)
				#if time <= 91.0:
					#blinkCycle = 5.0;
				#if time <= 61.0:
					#blinkCycle = 1.0;
				#if time <= 31.0:
					#blinkCycle = 0.5;
				#if time <= 11.0:
					#blinkCycle = 0.25;
				#if time <= 6:
					#blinkCycle = 0.15;
				if time <= 0:
					GameState.get_player().die();
					pause();

func blink():
	if GameState.get_in_state_of_play():
		SND.play_sound_nondirectional("Bip", 1.15);
		blinkTimer = 0.10;
		var player = GameState.get_player();
		var particlePos := Vector3(randf_range(0.5,-0.5),randf_range(0.5,-0.5),randf_range(0.5,-0.5));
		particlePos += player.body.global_position;
		ParticleFX.play("SmokePuffSingle", GameState.get_game_board(), particlePos);

func add_time(_time:float):
	time += _time;

func pause(enable:=true):
	paused = enable;

func start(_startTime := 120.0, _reset := false):
	pause(true);
	if _reset:
		time = 0.0;
	add_time(_startTime);
	pause(false);

func format_time(_time:float):
	var minutes = 0;
	var seconds = floori(_time)
	while seconds > 60:
		seconds -= 60;
		minutes += 1;
	minutes = min(99,minutes);
	seconds = min(60,max(0,seconds));
	var minuteString = "00"
	if minutes < 10 && minutes > 0:
		minuteString = "0" + str(minutes)
	elif minutes >= 10:
		minuteString = str(minutes)
	
	var secondString = "00"
	if seconds < 10 && seconds > 0:
		secondString = "0" + str(seconds)
	elif seconds >= 10:
		secondString = str(seconds)
	
	return minuteString + ":" + secondString;
