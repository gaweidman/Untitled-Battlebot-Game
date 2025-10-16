extends Camera

class_name GameCamera



@export_category("Adjustables and Stats")
@export var XRotInPlay = 20.0;
@export var rotXspeed := 0.0;
@export var rotYspeed := 0.0;
@export var zoomSpeed := 5.0;
var cameraOffset;
var targetPosition : Vector3;
var playerPosition : Vector3;
var targetRotationX := 0.0;
var currentRotationX := 0.0;
var targetRotationY := 0.0;
var currentRotationY := 0.0;
var targetRotationZ := 0.0;
@export var VOffsetInBuild := 6.0;
var vOffset := 0.0;
@export var zoomLevelBase := 1.0;
var targetZoomLevel := zoomLevelBase;
var currentZoomLevel := zoomLevelBase;

var inputOffset : Vector3;
var targetInputOffset : Vector3;
var modInpVec : Vector3;
var modMouseVec : Vector3;
@export_category("Node Refs")
var playerBody : RigidBody3D;
var viewport : Viewport;
@export var marker : MeshInstance3D; ## @experimental: Used for showing where the mouse projection is landing while experimenting.
@export var ray : RayCast3D; ## @deprecated: Used to have a ray attached to the camera at all times. Don't now. May again, who knows.
@export var floor : StaticBody3D;
@export var positionParent : Node;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cameraOffset = global_position; # the player always starts at 0, 0, 0 so we don't do any subtraction here
	position = Vector3(0,0,0)
	playerBody = GameState.get_player_body();
	
	Hooks.add(self, "OnChangeGameState", "CameraChangePos", 
		func(oldState : GameBoard.gameState, newState : GameBoard.gameState) :
			if newState == GameBoard.gameState.INIT_PLAY:
				targetRotationX = deg_to_rad(XRotInPlay);
				targetRotationY = 0.0;
			elif newState == GameBoard.gameState.MAIN_MENU:
				targetRotationX = 0.0;
			elif newState == GameBoard.gameState.SHOP:
				targetRotationX = 0.0;
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(viewport):
		var mousePos = viewport.get_mouse_position();
		
		## Offset the camera when in the shop.
		if GameState.get_in_state_of_building(): ##TODO: Come up with a better, more exact state for this to happen.
			v_offset = lerp(v_offset, VOffsetInBuild, delta * 7.0);
		else:
			v_offset = lerp(v_offset, 0.0, delta * 7.0);
		pass
	else:
		viewport = get_viewport();

func _physics_process(delta):
	if is_node_ready():
		if is_instance_valid(playerBody) && is_instance_valid(viewport):
			var inp = GameState.get_player();
			var inpVec = inp.get_movement_vector(false);
			modInpVec = - Vector3(inpVec.x, 0, inpVec.y);
			var viewRect = viewport.get_visible_rect();
			var mousePos = Vector2(clamp(viewport.get_mouse_position().x, 0, viewRect.size.x), clamp(viewport.get_mouse_position().y, 0, viewRect.size.y));
			var mousePosMoved = (mousePos - (viewRect.size / 2)) / (viewRect.size / 2)
			var targetInputOffsetX = (-mousePosMoved.x);
			var targetInputOffsetZ = (-mousePosMoved.y);
			#targetRotationX = deg_to_rad(-64.3) +  (mousePosMoved.y / -15);sa
			#targetRotationZ = (mousePosMoved.x / -15);
			modMouseVec = Vector3(targetInputOffsetX, 0, targetInputOffsetZ)
			#modMouseVec = InputHandler.mouseProjectionRotation(self);
			
			targetInputOffset = modMouseVec + modInpVec;
			inputOffset = lerp (inputOffset, targetInputOffset, delta * 5)
			playerPosition = playerBody.get_global_position()
			targetPosition = get_camera_offset() + inputOffset + get_v_offset_vector();
		else:
			viewport = get_viewport();
			playerBody = GameState.get_player_body();
		
		position = lerp(position, targetPosition, delta * 10);
		positionParent.position = lerp(positionParent.position, playerPosition, delta * 10);
		
			#list[hookName][instanceName] = null;
		
		
		##Rotating the camera
		if not GameState.is_paused():
			if GameState.get_in_state_of_play():
				var pitching := false;
				var zooming := false;
				if (Input.is_action_pressed("CameraTiltModeKey") and in_camera_tilt_state()):
					if Input.is_action_pressed("CameraPitchUp") or Input.is_action_pressed("CameraPitchDown"):
						if rotXspeed < 4: 
							rotXspeed += 0.1
					else:
						if rotXspeed > 0: 
							rotXspeed /= 3
				
				if Input.is_action_pressed("CameraZoomIn"):
					zooming = true;
					targetZoomLevel -= zoomSpeed * delta;
				if Input.is_action_pressed("CameraZoomOut"):
					zooming = true;
					targetZoomLevel += zoomSpeed * delta
				
				if in_camera_tilt_state():
					if Input.is_action_pressed("CameraPitchUp"):
						pitching = true;
						targetRotationX += rotXspeed * delta
					if Input.is_action_pressed("CameraPitchDown"):
						pitching = true;
						targetRotationX += -rotXspeed * delta
				else:
					targetRotationX = lerp_angle(targetRotationX, XRotInPlay, 15.0 * delta);
				
				if not (pitching or zooming):
					if Input.is_action_pressed("CameraYawLeft") or Input.is_action_pressed("CameraYawRight"):
						if rotYspeed < 2: 
							rotYspeed = 2
						if rotYspeed < 10: 
							rotYspeed += 0.1
					else:
						if rotYspeed > 0: 
							rotYspeed /= 3
					
					if Input.is_action_pressed("CameraYawLeft"):
						targetRotationY += rotYspeed * delta
					if Input.is_action_pressed("CameraYawRight"):
						targetRotationY += -rotYspeed * delta
			else:
				targetRotationY += 0.1 * delta;
				targetRotationX = lerp_angle(targetRotationX, 0.0, 5.0 * delta);
		
		targetRotationX = clamp(targetRotationX, deg_to_rad(-30), deg_to_rad(30))
		
		positionParent.rotation.y = lerp_angle(positionParent.rotation.y, targetRotationY, delta * 30)
		
		positionParent.rotation.x = lerp_angle(positionParent.rotation.x, targetRotationX, delta * 30)
		
		
		currentRotationX = positionParent.rotation.x;
		currentRotationY = positionParent.rotation.y;
		
		
		targetZoomLevel = clamp(targetZoomLevel, 0.5, 1.15);
		currentZoomLevel = lerp(currentZoomLevel, targetZoomLevel, delta * 30);
	
	
	
		
		if GameState.get_in_state_of_building():
			##Hovering pieces.
			hover_socket();
	
			##Selecting pieces.
			if Input.is_action_just_pressed("Select"):
				click_on_piece();

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if GameState.get_in_state_of_play():
				if Input.is_action_pressed("CameraZoomModeKey"):
					if event.button_index == MOUSE_BUTTON_WHEEL_UP:
						targetZoomLevel -= 0.1
						# call the zoom function
					# zoom out
					if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
						targetZoomLevel += 0.1
						# call the zoom function
				elif Input.is_action_pressed("CameraTiltModeKey") and in_camera_tilt_state():
					if event.button_index == MOUSE_BUTTON_WHEEL_UP:
						targetRotationX += 0.1
						# call the zoom function
					# zoom out
					if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
						targetRotationX -= 0.1
						# call the zoom function
				else:
				# rotate around the Y
					if event.button_index == MOUSE_BUTTON_WHEEL_UP:
						targetRotationY += 0.1
						# call the zoom function
					# zoom out
					if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
						targetRotationY -= 0.1
						# call the zoom function


func in_camera_tilt_state():
	return true;
	return GameState.get_in_state_of_building();

func get_camera_offset():
	return cameraOffset * currentZoomLevel;

func get_v_offset_vector():
	return Vector3(vOffset, 0.0, 0.0).rotated(Vector3(0,1,0), currentRotationY);
