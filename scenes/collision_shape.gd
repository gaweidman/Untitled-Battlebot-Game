extends CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func area_shape_entered():
	print("WE ARE HERE DSFSAFAS");

func _on_body_entered():
	print("WE ARE HERE DSFSAFAS");
