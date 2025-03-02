extends TextureRect
var TEXTURES;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TEXTURES = [
		load(%HUD.TEXTUREPATH + "Health 0.png"), 
		load(%HUD.TEXTUREPATH + "Health 1.png"),
		load(%HUD.TEXTUREPATH + "Health 2.png"),
		load(%HUD.TEXTUREPATH + "Health 3.png")
	];
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update(health: int) -> void:
	set_texture(TEXTURES[health]);
