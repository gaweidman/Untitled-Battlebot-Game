extends Node3D
class_name ProjectileLauncher

#@onready var bulletRef : ;
#@onready var bulletRef = @preload("res://scenes/Bullet.tscn");
var magazine = [];
@export var magazineMax := 3;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func fireBullet():
	if recountMagazine() < 3:
		var bullet = bulletRef.instantiate();
		bullet = 
	pass

func recountMagazine() -> int:
	var count = 0
	for bullet in magazine:
		if is_instance_valid(bullet):
			if not bullet.dying:
				count+=1;
	magazine = get_children()
	return count;
