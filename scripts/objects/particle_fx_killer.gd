extends Node3D

class_name ParticleEffect

var checkTimer := 1.0;

func _process(delta):
	if checkTimer > 0:
		checkTimer -= delta;
	else:
		check_emitting();
		checkTimer = 1.0;

func check_emitting():
	for child in get_children():
		if child is GPUParticles3D:
			if child.emitting:
				return;
	
	queue_free();
