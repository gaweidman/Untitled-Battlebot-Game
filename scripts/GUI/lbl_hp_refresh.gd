extends Label

var timer = 0.0;

func _ready():
	modulate.a = 0;

func ping(damage:float):
	var damageStr = "";
	var color = "grey";
	if damage > 0:
		color = "unaffordable";
		damageStr = "-" + TextFunc.format_stat(abs(damage));
		timer = 1.0;
	elif damage < 0: 
		color = "utility";
		damageStr = "+" + TextFunc.format_stat(abs(damage));
		timer = 1.0;
	text = damageStr;
	TextFunc.set_text_color(self, color);

func _process(delta):
	if timer > 0:
		timer -= delta;
		modulate.a = 1;
	else:
		modulate.a = move_toward(modulate.a, 0.0, delta / 2);
