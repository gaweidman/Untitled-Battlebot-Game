extends AudioStreamPlayer3D

class_name Sound3D

func set_sound(inSound:AudioStream):
	if is_instance_valid(inSound):
		stream = inSound;
		play();
		return true;
	else: 
		queue_free();
		return false;

func set_and_play_sound(inSound:AudioStream):
	if set_sound(inSound):
		play();

var leakTimer := 2.0;

func _process(delta):
	if leakTimer > 0:
		leakTimer -= delta;
	else:
		if playing:
			leakTimer = 2.0;
		else:
			queue_free();
