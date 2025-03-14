extends Control;
var TEXTUREPATH = "res://graphics/images/HUD/";
var refreshTimer = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass; # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	refreshTimer -= _delta;
	if refreshTimer <= 0:
		refreshTimer = 0.5;
		update();

func update() -> void:
	print(GameState.get_player()) #debug print
	var ply = GameState.get_player();
	print("Player node? ", ply)
	print(ply.is_node_ready())
	print(ply.get_script())
	$Health.update(ply.get_health());
	$Ammo.update(GameState.get_player().combatHandler.magazineCount);
