extends Camera

class_name MakerCamera

var zoom := 5.0;

var yaw := 0.0;
var pitch := 0.0;
var roll := 0.0;

var x := 0.0;
var y := 0.0;

@export var cyube : MeshInstance3D;

var enabled = true;

func enable():
	enabled = true;

func disable():
	enabled = false;

func _process(delta):
	position = Vector3(0, 0, zoom);
	h_offset = x;
	v_offset = y;
	get_parent().rotation.y = yaw;
	get_parent().rotation.x = pitch;
	get_parent().rotation.z = roll;
	
	if is_instance_valid(cyube):
		cyube.rotation = -get_parent().rotation;
		cyube.position.x = x;
		cyube.position.y = y;
	
	var rotationVector = get_parent().rotation.normalized();
	
	var inputted = false;
		## Q/E - Roll
	#cyube.visible = (Input.is_action_pressed("CameraYawLeft") or Input.is_action_pressed("CameraYawRight") or Input.is_action_pressed("MoveDown") or Input.is_action_pressed("MoveUp") or Input.is_action_pressed("MoveRight") or Input.is_action_pressed("MoveLeft"));
	if not enabled: return;

	if Input.is_action_pressed("CameraTiltModeKey"):
		## Q/E - Roll
		if Input.is_action_pressed("CameraYawLeft"):
			roll += delta * 4;
		if Input.is_action_pressed("CameraYawRight"):
			roll -= delta * 4;
		## W/S - Y offset
		if Input.is_action_pressed("MoveDown"):
			y -= delta * 4;
		if Input.is_action_pressed("MoveUp"):
			y += delta * 4;
		## A/D - X offset
		if Input.is_action_pressed("MoveRight"):
			x += delta * 4;
		if Input.is_action_pressed("MoveLeft"):
			x -= delta * 4;
	elif Input.is_action_pressed("CameraZoomModeKey"):
		## Q/E - Reset position, reset rotation
		if Input.is_action_pressed("CameraYawLeft"):
			reset_transforms(false, true);
		if Input.is_action_pressed("CameraYawRight"):
			reset_transforms(true, false);
		## W/S - Save and load position
		if Input.is_action_pressed("MoveDown"):
			save_position();
		if Input.is_action_pressed("MoveUp"):
			load_position();
		## A/D - Save and load rotation
		if Input.is_action_pressed("MoveRight"):
			save_rotation();
		if Input.is_action_pressed("MoveLeft"):
			load_rotation();
	else:
		var moveVector = Vector3.ZERO;
		## Q/E - Zoom
		if Input.is_action_pressed("CameraYawLeft"):
			zoom += delta * 4;
		if Input.is_action_pressed("CameraYawRight"):
			zoom -= delta * 4;
		## W/S - Pitch
		if Input.is_action_pressed("MoveDown"):
			pitch += delta * 4;
		if Input.is_action_pressed("MoveUp"):
			pitch -= delta * 4;
		## A/D - Yaw
		if Input.is_action_pressed("MoveRight"):
			yaw += delta * 4;
		if Input.is_action_pressed("MoveLeft"):
			yaw -= delta * 4;

func reset_transforms(rot := true, pos := true):
	if rot:
		yaw = 0.0;
		pitch = 0.0;
		roll = 0.0;
		get_parent().rotation = Vector3(0,0,0)
	if pos:
		zoom = 5.0;
		x = 0;
		y = 0;

func _on_clear_preview_pressed():
	reset_transforms();
	pass # Replace with function body.

var savedPos : Vector3;
var savedRot : Vector3;
func save_position():
	savedPos = get_parent().position;
func load_position():
	get_parent().position = savedPos;
func save_rotation():
	savedRot = get_parent().position;
func load_rotation():
	get_parent().rotation = savedRot;
