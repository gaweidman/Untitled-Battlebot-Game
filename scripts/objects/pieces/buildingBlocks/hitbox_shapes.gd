extends Area3D

class_name HitboxHolder

func _init():
	collision_layer = 16;
	collision_mask = 1 + 512;
