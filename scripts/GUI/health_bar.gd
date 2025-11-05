@tool
@icon ("res://graphics/images/class_icons/healthbar.png")
extends SubViewportContainer

class_name HealthBar

@export_subgroup("Numbers")
@export var resourceName := "HP";
@export var emptyBar : TextureRect;
@export var width := 163.0;
@export var height := 72.0;
var realLength := 0.;
@export var offset := 0.0;
@export var paddingStart := 0.0; ## Padding for the bar on the left if horizontal and top if vertical.
@export var paddingEnd := 0.0; ## Padding for the bar on the right if horizontal and bottom if vertical.
@onready var targetPos := width;
@onready var lerpPosX := width;
@export var currentAmt := 0.0;
@export var currentMax := 0.0;
@export var EDITOR_fillAmt := -1.;
@export_subgroup("Textures")
@export var maskTexture :CompressedTexture2D = preload("res://graphics/images/HUD/Health_EmptyOverlayMask.png");
@export var fullTexture := preload("res://graphics/images/HUD/Health_FullOverlay.png");
@export var emptyTexture := preload("res://graphics/images/HUD/Health_EmptyOverlay.png")
enum directions {
	FILL_TO_RIGHT,
	FILL_TO_LEFT,
	FILL_TO_TOP,
	FILL_TO_BOTTOM,
}
@export var direction : directions = directions.FILL_TO_RIGHT;
var vertical;
@export_subgroup("Label Settings")
@export var label : Label;
@export var colorBase := "lightred";
@export var colorAlt := "scrap";
var altColorOn : bool = false;
@export var hasLabel := true;
@export var addSpaces := true;
@export var addZeroes := false;
@export var decimalPlaces := 2;

func _ready():
	%FullHealth.texture = fullTexture;
	%EmptyHealth.texture = emptyTexture;
	
	material.set("shader_parameter/mask", maskTexture);
	
	if not hasLabel:
		$%Lbl_Health.hide();
	else:
		if label == $%Lbl_Health:
			$%Lbl_Health.set_deferred("size", size);
		else:
			$%Lbl_Health.hide();
	
	currentAmt = 0.0;
	currentMax = 3.0;
	
	if Engine.is_editor_hint():
		currentMax = 100.

func set_health(_amt: float, _max: float):
	var percentage : float = _amt/_max;
	if is_equal_approx(_amt, _max):
		percentage = 1.0;
	if is_equal_approx(_amt, 0):
		percentage = 0.0;
	match direction:
		directions.FILL_TO_RIGHT:
			targetPos = paddingStart;
			vertical = false;
			realLength = width - paddingEnd - paddingStart;
			targetPos += percentage * (realLength);
			pass;
		directions.FILL_TO_LEFT:
			targetPos = paddingEnd;
			vertical = false;
			realLength = width - paddingEnd - paddingStart;
			targetPos += -percentage * (realLength);
			pass;
		directions.FILL_TO_TOP:
			targetPos = -paddingEnd;
			vertical = true;
			realLength = height - paddingEnd - paddingStart;
			targetPos += -percentage * (realLength);
			pass;
		directions.FILL_TO_BOTTOM:
			targetPos = -height+paddingStart;
			vertical = true;
			realLength = height - paddingEnd - paddingStart;
			targetPos += percentage * (realLength);
			pass;
	
	currentAmt = _amt;
	currentMax = _max;
	if !Engine.is_editor_hint():
		update_text(currentAmt, currentMax);

func set_alt_color(on := false):
	altColorOn = on;

var counter = 0;
func _process(delta):
	if targetPos is not float: return;
	var oldPos = lerpPosX;
	lerpPosX = lerp(lerpPosX, targetPos, delta*20);
	if oldPos > targetPos:
		lerpPosX = clamp(lerpPosX, targetPos, oldPos);
	else:
		lerpPosX = clamp(lerpPosX, oldPos, targetPos);
	if vertical:
		emptyBar.position.x = 0;
		emptyBar.position.y = clamp(lerpPosX, -height, height);
	else:
		emptyBar.position.x = clamp(lerpPosX, -width, width);
		emptyBar.position.y = 0;
	
	%FullHealth.size = fullTexture.get_size();
	%EmptyHealth.size = emptyTexture.get_size();
	
	if Engine.is_editor_hint():
		if EDITOR_fillAmt >= 0:
			currentAmt = EDITOR_fillAmt;
		else:
			currentAmt += 0.05;
			if currentAmt > currentMax:
				currentAmt -= currentMax;
		
		set_health(currentAmt, currentMax);
		#print(currentAmt, currentMax)
		#print(emptyBar.size)
		
		if altColorOn:
			TextFunc.set_text_color(label, colorAlt);
		else:
			TextFunc.set_text_color(label, colorBase);
	else:
		counter -= 1;
		if counter <= 0:
			counter = 2;
			update_text(currentAmt, currentMax);

func update_text(_amt : float, _max: float):
	if not hasLabel:
		return;
	var stringHealth = TextFunc.format_stat(_amt, decimalPlaces, addSpaces, addZeroes) + "/" + TextFunc.format_stat(_max, decimalPlaces, addSpaces, addZeroes);
	label.text = stringHealth;
	tooltip_text = str(resourceName, "\n",stringHealth);
	if altColorOn:
		TextFunc.set_text_color(label, colorAlt);
	else:
		TextFunc.set_text_color(label, colorBase);
