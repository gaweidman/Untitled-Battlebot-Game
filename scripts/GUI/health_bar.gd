@icon ("res://graphics/images/class_icons/healthbar.png")
extends SubViewportContainer

class_name HealthBar

@export var resourceName := "HP";
@export var emptyBar : TextureRect;
@export var width := 163.0;
@export var offset := 0.0;
@onready var targetPosX := width;
@onready var lerpPosX := width;
var currentAmt := 0.0;
var currentMax := 0.0;
@export var label : Label;
@export var colorBase := "lightred"
@export var colorAlt := "scrap"
var altColorOn : bool = false;
@export var maskTexture :CompressedTexture2D = preload("res://graphics/images/HUD/Health_EmptyOverlayMask.png");
@export var fullTexture := preload("res://graphics/images/HUD/Health_FullOverlay.png");
@export var emptytexture := preload("res://graphics/images/HUD/Health_EmptyOverlay.png")
enum directions {
	FILL_TO_RIGHT,
	FILL_TO_LEFT,
	FILL_TO_TOP,
	FILL_TO_BOTTOM,
}
@export var direction : directions = directions.FILL_TO_RIGHT;
var vertical;
@export_subgroup("Label Settings")
@export var hasLabel := true;
@export var addSpaces := true;
@export var addZeroes := false;
@export var decimalPlaces := 2;

func _ready():
	%FullHealth.texture = fullTexture;
	%EmptyHealth.texture = emptytexture;
	material.set("shader_parameter/mask", maskTexture);
	#%BarHolder.set_deferred("size", size);
	#material.shader_parameter.mask = maskTexture;
	#set("material/shader_parameter/mask", maskTexture);
	if not hasLabel:
		$%Lbl_Health.hide();
	else:
		if label == $%Lbl_Health:
			$%Lbl_Health.size = size;
		else:
			$%Lbl_Health.hide();

func set_health(amt: float, max: float):
	var percentage : float = amt/max;
	targetPosX = offset;
	
	match direction:
		directions.FILL_TO_RIGHT:
			vertical = false;
			targetPosX += percentage * width;
		directions.FILL_TO_LEFT:
			vertical = false;
			targetPosX += -percentage * width;
		directions.FILL_TO_TOP:
			vertical = true;
			targetPosX += -percentage * width;
			pass;
		directions.FILL_TO_BOTTOM:
			vertical = true;
			targetPosX += percentage * width;
			pass;
	
	currentAmt = amt;
	currentMax = max;
	update_text(currentAmt, currentMax);

func set_alt_color(on := false):
	altColorOn = on;

var counter = 0;
func _process(delta):
	lerpPosX = lerp(lerpPosX, targetPosX, delta*20);
	if vertical:
		emptyBar.position.x = 0;
		emptyBar.position.y = clamp(lerpPosX, offset - width, offset + width);
	else:
		emptyBar.position.x = clamp(lerpPosX, offset - width, offset + width);
		emptyBar.position.y = 0;
	
	counter -= 1;
	if counter <= 0:
		counter = 2;
		update_text(currentAmt, currentMax);

func update_text(amt : float, max: float):
	if not hasLabel:
		return;
	var stringHealth = TextFunc.format_stat(amt, decimalPlaces, addSpaces, addZeroes) + "/" + TextFunc.format_stat(max, decimalPlaces, addSpaces, addZeroes);
	label.text = stringHealth;
	tooltip_text = str(resourceName, "\n",stringHealth);
	if altColorOn:
		TextFunc.set_text_color(label, colorAlt);
	else:
		TextFunc.set_text_color(label, colorBase);
