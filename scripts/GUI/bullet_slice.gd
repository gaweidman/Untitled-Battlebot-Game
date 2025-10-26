@icon ("res://graphics/images/class_icons/bullet_green_v.png")
extends MarginContainer
class_name BulletSlice;
## Represents a single [Bullet] within a [Piece_Projectile] as displayed by [MagazineSlicer]. Fills up with cooldown.

@export var bg_empty := preload("res://graphics/images/HUD/screenGFX/screenBG_indigo.png")
@export var bg_filling := preload("res://graphics/images/HUD/screenGFX/screenBG_darkBlue.png")
@export var fg_full := preload("res://graphics/images/HUD/screenGFX/screenBG_blue.png")
@export var fg_used := preload("res://graphics/images/HUD/screenGFX/screenBG_lightBlue.png")

var currentPercent = 0.0;
var maxSize = 14;

func _ready():
	update_percent(0, 1);

func update_percent(current:float, max:float, forceFull := false, forceEmpty := false):
	%Full.set_deferred("size", size);
	if current <= 0 or is_zero_approx(current) or forceEmpty:
		%Empty.texture = bg_empty;
		%Full.visible = false;
		return;
	
	#%Full.visible = true;
	%Full.texture = fg_full;
	%Full.visible = true;
	if current >= max or is_equal_approx(current, max) or forceFull:
		currentPercent = 1.0;
	else:
		currentPercent = min(current / max, 1.0);
	
	%Empty.texture = bg_filling;
	
	var curHeight = size.y;
	var pos = size.y - roundi(size.y * (currentPercent));
	
	
	#size.y = size.y;
	%Full.flip_v = (int(pos) % 2 == 0);
	%Full.position.y = pos;
	%Full.visible = true;

var counter = 0;
func _process(delta):
	## Testing.
	return;
	counter += 1 * delta;
	if counter > 5: counter = -1;
	update_percent(counter, 5);
