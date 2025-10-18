extends TextureRect

class_name DigitalSeparator

@export var brightTexture := preload("res://graphics/images/HUD/screenGFX/screenBG_white.png");
@export var darkTexture := preload("res://graphics/images/HUD/screenGFX/screenBG_grey.png");

func _ready():
	texture = darkTexture;
	%bright.texture = brightTexture;
