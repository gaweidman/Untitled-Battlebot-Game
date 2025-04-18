extends SubViewportContainer

class_name healthBar

@export var fromRight := true;
@export var emptyBar : TextureRect;
@export var width := 204.0;
var targetPosX := width;
var lerpPosX := width;

func set_health(amt: float, max: float):
	var percentage := amt/max;
	if fromRight:
		targetPosX = percentage * width;
		pass
	else:
		targetPosX = -percentage*width;

func _physics_process(delta):
	lerpPosX = lerp(lerpPosX, targetPosX, delta*20);
	emptyBar.position.x = lerpPosX;
