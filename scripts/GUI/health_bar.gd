extends SubViewportContainer

class_name healthBar

@export var fromRight := true;
@export var emptyBar : TextureRect;
@export var width := 204.0;
var targetPosX := width;
var lerpPosX := width;
var currentAmt := 0.0;
var currentMax := 0.0;
@export var label : Label;
@export var colorBase := "lightred"
@export var colorAlt := "scrap"
var altColorOn : bool = false;

func set_health(amt: float, max: float):
	var percentage := amt/max;
	if fromRight:
		targetPosX = percentage * width;
		pass
	else:
		targetPosX = -percentage*width;
	currentAmt = amt;
	currentMax = max;
	update_text(currentAmt, currentMax);

func set_alt_color(on := false):
	altColorOn = on;

var counter = 0;
func _process(delta):
	lerpPosX = lerp(lerpPosX, targetPosX, delta*20);
	emptyBar.position.x = lerpPosX;
	
	counter -= 1;
	if counter <= 0:
		counter = 2;
		update_text(currentAmt, currentMax);

func update_text(amt : float, max: float):
	var stringHealth = "";
	label.text = TextFunc.format_stat_num(amt) + "/" + TextFunc.format_stat_num(max);
	if altColorOn:
		TextFunc.set_text_color(label, colorAlt);
	else:
		TextFunc.set_text_color(label, colorBase);
