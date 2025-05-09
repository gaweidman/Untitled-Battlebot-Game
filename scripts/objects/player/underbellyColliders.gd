extends Node3D

class_name UnderbellyContactPoints

@export var underbellyCollider : ContactPoint;
@export var rightTread : TreadContactPoints;
@export var leftTread : TreadContactPoints;

func full_status_report():
	var onFloor = is_on_floor();
	var onDriveable = is_on_driveable();
	return {"right":rightTread.status_report(), "left":leftTread.status_report(), "center":underbellyCollider.status_report(), "onFloor":onFloor, "onDriveable":onDriveable};

func is_on_floor(centerOnly:=false):
	if centerOnly:
		return underbellyCollider.is_on_floor();
	else:
		return rightTread.is_on_floor() or leftTread.is_on_floor() or underbellyCollider.is_on_floor();

func is_on_driveable(centerOnly:=false):
	if centerOnly:
		return underbellyCollider.is_on_something_driveable();
	else:
		return rightTread.is_on_something_driveable() or leftTread.is_on_something_driveable();

##gets the vector that the contact of the treads is returning.
func get_tread_contact_vector():
	var left = leftTread.get_driveable_contact_axis();
	var right = rightTread.get_driveable_contact_axis();
	var x = 0;
	var y = 0;
	if right != null and left != null:
		x = 0;
		y = right + left;
	else:
		if left == null:
			x += 1;
		else:
			y += left;
		if right == null:
			x -= 1;
		else: 
			y += right;
	return Vector2(x, y);

func get_tread_normal() -> Vector3:
	if rightTread.is_on_something_driveable() && leftTread.is_on_something_driveable():
		var normF := rightTread.get_tread_normal();
		var normB := leftTread.get_tread_normal();
		return ((normF + normB) / 2).normalized();
	elif rightTread.is_on_something_driveable() and not leftTread.is_on_something_driveable():
		var normB := rightTread.get_tread_normal();
		return (normB).normalized();
	elif leftTread.is_on_something_driveable() and not rightTread.is_on_something_driveable():
		var normF := leftTread.get_tread_normal();
		return (normF).normalized();
	else:
		return Vector3.ZERO;
