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
	var ply = GameState.get_player();
	#if ply and %Health and %HealthLabel and %Ammo and %AmmoLabel:
		#%Health.update(ply.get_health());
		#%HealthLabel.text = str(ply.get_health(false));
		#%Ammo.update(ply.get_ammo());
		#%AmmoLabel.text = str(ply.get_ammo(false));
