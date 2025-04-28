extends AudioStreamPlayer3D

var on := false;

@export var inputHandler : InputHandler
@export var body : RigidBody3D
var snd : SND;

func switch(switchOn:bool):
	if playing:
		#print("step 1")
		if is_instance_valid(get_stream_playback()):
			#print("step 2")
			if switchOn != on:
				#print("step 3")
				if switchOn:
					#print("step 4 - turning on")
					get_stream_playback().switch_to_clip_by_name("Start")
				else:
					#print("step 4 - turning off")
					get_stream_playback().switch_to_clip(1)
					pass
		
				on = switchOn;
				return;
	on = false;

func _physics_process(delta):
	if ! is_instance_valid(snd):
		snd = SND.get_physical();
	else:
		if is_instance_valid(inputHandler):
			if ! playing:
				play();
			else:
				var moving := inputHandler.is_inputting_movement();
				if moving != on:
					switch(moving);
		if ! GameState.get_in_state_of_play():
			switch(false);
		var vol = linear_to_db(db_to_linear(-10.667) * snd.volumelevelWorld);
		set_deferred("volume_db", vol)
