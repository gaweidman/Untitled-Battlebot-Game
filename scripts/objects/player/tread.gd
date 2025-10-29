@icon ("res://graphics/images/class_icons/tread.png")
extends Node3D

class_name TreadContactPoints

@export var contactPointFront : ContactPoint;
@export var contactPointBack : ContactPoint;

func is_on_floor():
	return contactPointFront.is_on_floor() or contactPointBack.is_on_floor();

func is_on_something_driveable():
	return contactPointFront.is_on_something_driveable() or contactPointBack.is_on_something_driveable();

## -1 means only the back is touching, 1 means only the front, 0 is both, null is none.
func get_driveable_contact_axis():
	if is_on_something_driveable():
		var axis = 0;
		if contactPointFront.is_on_something_driveable():
			axis += 1;
		if contactPointBack.is_on_something_driveable():
			axis -= 1;
		return axis;
	return null;

func get_tread_normal() -> Vector3:
	if contactPointFront.is_on_something_driveable() && contactPointBack.is_on_something_driveable():
		var normF := contactPointFront.get_collider_normal();
		var normB := contactPointBack.get_collider_normal();
		return ((normF + normB) / 2).normalized();
	elif contactPointFront.is_on_something_driveable() and not contactPointBack.is_on_something_driveable():
		var normF := contactPointFront.get_collider_normal();
		return (normF).normalized();
	elif contactPointBack.is_on_something_driveable() and not contactPointFront.is_on_something_driveable():
		var normB := contactPointBack.get_collider_normal();
		return (normB).normalized();
	else:
		return Vector3.ZERO;

func status_report():
	return {"onFloor":is_on_floor(), "onDriveable":is_on_something_driveable(), "driveableAxis":get_driveable_contact_axis()};

func dust_particle():
	if randf() > 0.1:
		if is_on_floor() and not GameState.is_paused():
			ParticleFX.play("SmokePuffSingleShort", self, global_position)
