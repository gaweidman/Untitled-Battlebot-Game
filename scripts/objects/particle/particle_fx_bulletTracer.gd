extends ParticleEffect

class_name PFXBulletTracer
## A [ParticleEffect] that follows the position of a node and keeps emitting, until that node stops being visible or gets deleted. Then follows the standard "delete when not emitting" rules.

@export var tracers : Array[GPUParticles3D]; ## A list of all the particle effects that should be stopped when the conditions to stop trailing are met. This is for any [GPUParticles3D] that do not have [member GPUParticles3D.one_shot] as [code]true[/code].

func _process(delta):
	super(delta);
	if is_instance_valid(nodeToFollow):
		if nodeToFollow.is_queued_for_deletion():
			stop_trailing();
		if nodeToFollow.is_visible_in_tree() == false:
			stop_trailing();
	else:
		stop_trailing();

func stop_trailing():
	for tracer in tracers:
		tracer.emitting = false;
