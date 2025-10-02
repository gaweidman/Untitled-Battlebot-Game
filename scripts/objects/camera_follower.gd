extends Camera

class_name FollowerCamera

@export var camToFollow : Camera;

func _process(delta):
	global_position = camToFollow.global_position
	global_rotation = camToFollow.global_rotation
	h_offset = camToFollow.h_offset;
	v_offset = camToFollow.v_offset;
	fov = camToFollow.fov;

func switch_cameras(newCam : Camera):
	camToFollow = newCam;
