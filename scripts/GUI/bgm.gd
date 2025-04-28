extends AudioStreamPlayer

class_name MusicHandler

var curState := musState.NONE;

enum musState {
	NONE,
	MENU,
	BATTLING,
	SHOP,
	GAME_OVER,
	CREDITS,
	OPTIONS,
}

var base := 0.0;
var base_mod := 0.0;
var slapBass := 0.0;
var slapBass_mod := 0.0;
var melody := 0.0;
var melody_mod := 0.0;
var perc1 := 0.0;
var perc1_mod := 0.0;
var perc2 := 0.0;
var perc2_mod := 0.0;

var master_volume := 1.0;

func set_volume(inVol := 1.0):
	master_volume = inVol;

func change_state(inState:musState):
	if curState != inState:
		print(curState)
		curState = inState;
		if curState == musState.MENU:
			base = 1.0;
			slapBass = 0.0;
			melody = 0.0;
			perc1 = 0.60;
			perc2 = 0.0;
		elif curState == musState.BATTLING:
			base = 1.0;
			slapBass = 1.0;
			melody = 1.0;
			perc1 = 1.0;
			perc2 = 1.0;
		elif curState == musState.SHOP:
			base = 0.55;
			slapBass = 1.0;
			melody = 0.60;
			perc1 = 1.0;
			perc2 = 0.60;
		elif curState == musState.GAME_OVER:
			base = 1.0;
			slapBass = 1.0;
			melody = 0.0;
			perc1 = 0.60;
			perc2 = 0.60;
		elif curState == musState.CREDITS:
			base = 0.6;
			slapBass = 0.0;
			melody = 1.0;
			perc1 = 1.0;
			perc2 = 1.0;
		elif curState == musState.OPTIONS:
			base = 0.8;
			slapBass = 1.0;
			melody = 0.0;
			perc1 = 1.0;
			perc2 = 1.0;
		else:
			base = 0.0;
			slapBass = 0.0;
			melody = 0.0;
			perc1 = 0.0;
			perc2 = 0.0;

func _process(delta):
	base_mod = lerp_volume(0, base, base_mod, delta);
	slapBass_mod = lerp_volume(1, slapBass, slapBass_mod, delta);
	melody_mod = lerp_volume(2, melody, melody_mod, delta);
	perc1_mod = lerp_volume(3, perc1, perc1_mod, delta);
	perc2_mod = lerp_volume(4, perc2, perc2_mod, delta);

func clamp_volume(inVal) -> float:
	return linear_to_db(inVal);

func lerp_volume(index:int, volume:float, modifier:float, delta:float):
	var mod = modifier
	mod = lerp(mod, volume * master_volume, delta * 5);
	var vol = clamp_volume(modifier)
	stream.set_sync_stream_volume(index,vol)
	return mod;
