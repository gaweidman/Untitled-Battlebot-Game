extends TextureRect
var TEXTURES;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TEXTURES = [
		load(%HUD.TEXTUREPATH + "Ammo 0.png"),
		load(%HUD.TEXTUREPATH + "Ammo 1.png"),
		load(%HUD.TEXTUREPATH + "Ammo 2.png"),
		load(%HUD.TEXTUREPATH + "Ammo 3.png")
	];
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;

func update(ammo: int) -> void:
	set_texture(TEXTURES[ammo]);
