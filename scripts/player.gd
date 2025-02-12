extends Node3D

var sawblade;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sawblade = get_node("Body/Sawblade");


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sawblade.rotation = Vector3(0, 0, Time.get_ticks_msec()%360)
