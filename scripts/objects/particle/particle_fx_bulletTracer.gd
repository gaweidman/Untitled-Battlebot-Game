extends ParticleEffect

class_name PFXBulletTracer

@export var tracers : Array[GPUParticles3D];

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
