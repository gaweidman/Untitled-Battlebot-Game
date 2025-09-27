extends Camera3D

class_name Camera

@export_category("Adjustables and Stats")
@export var XRotInPlay = 20.0;
@export var rotXspeed := 0.0;
@export var rotYspeed := 0.0;
var cameraOffset;
var targetPosition : Vector3;
var playerPosition : Vector3;
var targetRotationX := 0.0;
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
		#project_local_ray_normal()
		
		#var proj = project_position(mousePos, 20);
		##marker.global_position = proj;
		#var proj2 = project_local_ray_normal(mousePos);
		##marker.global_position = proj2 + global_position;
		#ray.look_at(global_position + proj2);
		#ray.rotation -= rotation;
		#if ray.is_colliding():
			#marker.global_position = ray.get_collision_point();
		#print(proj2);
		#marker
		
		
		
		##This is experimental code that was giving me motion sickness.
		#var mousePos = viewport.get_mouse_position();
		#var viewRect = viewport.get_visible_rect();
		#var mousePosMoved = (mousePos - (viewRect.size / 2)) / (viewRect.size / 2)
		#targetRotationY = (mousePosMoved.x / -15) + deg_to_rad(180);
		#targetRotationX = deg_to_rad(-64.3) +  (mousePosMoved.y / -15);
		#targetRotationZ = (mousePosMoved.x / -15);
		#
		#var targetRotationBase = Vector3(deg_to_rad(-64.3),deg_to_rad(180),deg_to_rad(0));
		#targetRotationBase = targetRotationBase.rotated(Vector3(1,0,0), -64.3);
		#targetRotationBase = targetRotationBase.rotated(Vector3(0,1,0), -targetRotationY);
		#targetRotationBase = targetRotationBase.rotated(Vector3(0,0,1), -targetRotationZ);
		#look_at(targetRotationBase + get_global_position());ds
		#rotation = Vector3(0,0,0).rotated(targetRotationBase.normalized(), deg_to_rad());
		#print(rotation)
		#
		#print(targetRotationY)
		#print(targetRotationX)
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
		if GameState.get_in_state_of_play():
			if Input.is_action_pressed("CameraPitchUp") or Input.is_action_pressed("CameraPitchDown"):
				if rotXspeed < 4: 
					rotXspeed += 0.1
			else:
				if rotXspeed > 0: 
					rotXspeed /= 3
			
			if Input.is_action_pressed("CameraYawLeft") or Input.is_action_pressed("CameraYawRight"):
				if rotYspeed < 2: 
					rotYspeed = 2
				if rotYspeed < 10: 
					rotYspeed += 0.1
			else:
				if rotYspeed > 0: 
					rotYspeed /= 3
			
			if Input.is_action_pressed("CameraZoomIn"):
				targetZoomLevel -= 0.1;
			if Input.is_action_pressed("CameraZoomOut"):
				targetZoomLevel += 0.1;
			
			if in_camera_tilt_state():
				if Input.is_action_pressed("CameraPitchUp"):
					targetRotationX += rotXspeed * delta
				if Input.is_action_pressed("CameraPitchDown"):
					targetRotationX += -rotXspeed * delta
			else:
				targetRotationX = lerp_angle(targetRotationX, XRotInPlay, 15.0 * delta);
			
			if Input.is_action_pressed("CameraYawLeft"):
				targetRotationY += rotYspeed * delta
			if Input.is_action_pressed("CameraYawRight"):
				targetRotationY += -rotYspeed * delta
		else:
			targetRotationY += 0.1 * delta;
			targetRotationX = lerp_angle(targetRotationX, 0.0, 5.0 * delta);
		
		targetRotationX = clamp(targetRotationX, deg_to_rad(-30), deg_to_rad(30))
		
		positionParent.rotation.y = lerp_angle(positionParent.rotation.y, targetRotationY, delta * 30)
		currentRotationY = positionParent.rotation.y;
		
		positionParent.rotation.x = lerp_angle(positionParent.rotation.x, targetRotationX, delta * 30)
		
		
		targetZoomLevel = clamp(targetZoomLevel, 0.5, 1.15);
		currentZoomLevel = lerp(currentZoomLevel, targetZoomLevel, delta * 30);
	
	
	
	
		##Selecting pieces.
		if Input.is_action_just_pressed("Select"):
			click_on_piece();
		
		hover_socket();

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

func get_rotation_to_fake_aiming(firingOrigin:=Vector3(0,0,0)):
	var collisionMask = floor.get_collision_layer() - 1;
	
	#print(collisionMask);
	var raycastPos = RaycastSystem.get_mouse_world_position(collisionMask);
	#print(raycastPos);
	if raycastPos: 
		var Yoffset = raycastPos.y - firingOrigin.y;
		var raycastPosYAdjusted = Vector3(raycastPos.x, raycastPos.y + Yoffset, raycastPos.z)
		var unproject = unproject_position(raycastPosYAdjusted);
		#print(get_viewport().get_mouse_position())
		#print(unproject)
		var raycastPos2 = RaycastSystem.get_mouse_world_position(collisionMask, unproject);
		if raycastPos2:
			var firingOriginV2 = Vector2(firingOrigin.x, firingOrigin.z);
			var raycastPos2V2 = Vector2(raycastPos2.x, raycastPos2.z);
			#var rot = firingOriginV2.direction_to(raycastPos2V2);
			var offset = raycastPos2V2 - firingOriginV2;
			#var lookAt = Vector3(rot.x, 0, rot.y);
			var rot = firingOriginV2.angle_to_point(raycastPos2V2);
			
		
			return rot;
	return null;

func click_on_piece():
	var collisionMask = 8;
	
	var raycastHit = RaycastSystem.get_raycast_hit_object(collisionMask);
	#print(raycastHit)
	if is_instance_valid(raycastHit): 
		#print(raycastHit)
		if raycastHit is HurtboxHolder:
			raycastHit.select_piece();

var socketHovering : Socket;
var pieceHovering : Piece;
func hover_socket():
	var collisionMask = 32 + 128;
	
	var raycastHit = RaycastSystem.get_raycast_hit_object(collisionMask);
	#print(raycastHit)
	if is_instance_valid(raycastHit): 
		print(raycastHit, pieceHovering)
		if raycastHit is Socket and raycastHit.is_valid():
			pieceHovering = raycastHit.hover_from_camera(self);
			if pieceHovering != null:
				socketHovering = raycastHit;
		if raycastHit == pieceHovering and is_instance_valid(socketHovering): 
			socketHovering.hover_from_camera(self);
			
	else:
		if is_instance_valid(socketHovering):
			socketHovering.hover(false);
			socketHovering = null;

func in_camera_tilt_state():
	return GameState.get_in_state_of_building();

func get_camera_offset():
	return cameraOffset * currentZoomLevel;

func get_v_offset_vector():
	return Vector3(vOffset, 0.0, 0.0).rotated(Vector3(0,1,0), currentRotationY);
