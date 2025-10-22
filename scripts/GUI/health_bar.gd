extends SubViewportContainer

class_name healthBar

@export var emptyBar : TextureRect;
@export var width := 163.0;
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
@export var hasLabel := true;
enum directions {
	FILL_TO_RIGHT,
	FILL_TO_LEFT,
	FILL_TO_TOP,
	FILL_TO_BOTTOM,
}
@export var direction : directions = directions.FILL_TO_RIGHT;
var vertical;

func _ready():
	%FullHealth.texture = fullTexture;
	%EmptyHealth.texture = emptytexture;
	material.set("shader_parameter/mask", maskTexture);
	#material.shader_parameter.mask = maskTexture;
	#set("material/shader_parameter/mask", maskTexture);
	if not hasLabel:
		$%Lbl_Health.hide();
	else:
		$%Lbl_Health.size = size;

func set_health(amt: float, max: float):
	if not hasLabel:
		return;
	var percentage := amt/max;
	
	match direction:
		directions.FILL_TO_RIGHT:
			vertical = false;
			targetPosX = percentage * width;
		directions.FILL_TO_LEFT:
			vertical = false;
			targetPosX = -percentage* width;
		directions.FILL_TO_TOP:
			vertical = true;
			targetPosX = percentage * width;
			pass;
		directions.FILL_TO_BOTTOM:
			vertical = true;
			targetPosX = percentage * width;
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
		emptyBar.position.y = lerpPosX;
	else:
		emptyBar.position.x = lerpPosX;
		emptyBar.position.y = 0;
	
	counter -= 1;
	if counter <= 0:
		counter = 2;
		update_text(currentAmt, currentMax);

func update_text(amt : float, max: float):
	var stringHealth = "";
	label.text = TextFunc.format_stat(amt) + "/" + TextFunc.format_stat(max);
	if altColorOn:
		TextFunc.set_text_color(label, colorAlt);
	else:
		TextFunc.set_text_color(label, colorBase);


func _on_editor_description_changed(node):
	if node == self:
		print("FUCK")
		%FullHealth.texture = fullTexture;
		%EmptyHealth.texture = emptytexture;
		set("material/shader_parameter/mask", maskTexture);
		queue_redraw();
	else:print("huh?")
	pass # Replace with function body.


func _on_values_changed():
	print("HI")
	pass # Replace with function body.
