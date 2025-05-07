extends Node3D

class_name ParticleEffect

var checkTimer := 1.0;
var nodeToFollow : Node3D;
var posOffset : Vector3;
@export var forceFireOnce := false;

func _ready():
	emit();

func emit():
	for child in get_children():
		if child is GPUParticles3D:
			child.emitting = true;
			if forceFireOnce:
				child.one_shot = true;

func _process(delta):
	if is_instance_valid(nodeToFollow):
		if nodeToFollow.is_visible_in_tree():
			global_position = nodeToFollow.global_position + posOffset;
			rotation = nodeToFollow.rotation;
	
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
