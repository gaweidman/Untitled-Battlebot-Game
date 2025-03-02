extends Control;
var TEXTUREPATH = "res://graphics/images/HUD/";
var refreshTimer = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update();
	pass; # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	refreshTimer -= delta;
	if refreshTimer <= 0:
		refreshTimer = 0.5;
		update();
	
	
func update() -> void:
	$Health.update(GameState.get_player().get_health());
	$Ammo.update(GameState.get_player().combatHandler.recountMagazine());
	pass;
