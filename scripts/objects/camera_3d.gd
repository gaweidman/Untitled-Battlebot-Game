extends Camera3D

class_name Camera

var playerBody : RigidBody3D;
var cameraOffset;
var targetPosition : Vector3;
var playerPosition : Vector3;
var targetRotationX := 0.0;
var rotXspeed := 0.0;
var targetRotationY := 0.0;
var rotYspeed := 0.0;
var targetRotationZ := 0.0;
var inputOffset : Vector3;
var targetInputOffset : Vector3;
var modInpVec : Vector3;
var modMouseVec : Vector3;
var viewport : Viewport;
@export var marker : MeshInstance3D;
@export var ray : RayCast3D;
@export var floor : StaticBody3D;
var parent : Node;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent();
	cameraOffset = global_position; # the player always starts at 0, 0, 0 so we don't do any subtraction here
	position = Vector3(0,0,0)
	playerBody = GameState.get_player_body();
	
	Hooks.add(self, "OnChangeGameState", "CameraChangePos", 
		func(oldState : GameBoard.gameState, newState : GameBoard.gameState) :
			if newState == GameBoard.gameState.INIT_PLAY:
				targetRotationX = deg_to_rad(20);
				targetRotationY = 0.0;
			elif newState == GameBoard.gameState.MAIN_MENU:
				targetRotationX = 0.0;
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(viewport):
		var mousePos = viewport.get_mouse_position();
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
			targetPosition = cameraOffset + inputOffset;
		else:
			viewport = get_viewport();
			playerBody = GameState.get_player_body();
		
		position = lerp(position, targetPosition, delta * 10);
		parent.position = lerp(parent.position, playerPosition, delta * 10);
		
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
			
			if Input.is_action_pressed("CameraPitchUp"):
				targetRotationX += rotXspeed * delta
			if Input.is_action_pressed("CameraPitchDown"):
				targetRotationX += -rotXspeed * delta
			if Input.is_action_pressed("CameraYawLeft"):
				targetRotationY += rotYspeed * delta
			if Input.is_action_pressed("CameraYawRight"):
				targetRotationY += -rotYspeed * delta
		else:
			targetRotationY += 0.1 * delta;
			targetRotationX = lerp(targetRotationX, 0.0, 5.0 * delta);
		
		targetRotationX = clamp(targetRotationX, deg_to_rad(-30), deg_to_rad(30))
		
		parent.rotation.y = lerp(parent.rotation.y, targetRotationY, delta * 30)
		
		parent.rotation.x = lerp(parent.rotation.x, targetRotationX, delta * 30)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if GameState.get_in_state_of_play():
				if Input.is_key_pressed(KEY_SHIFT):
					if event.button_index == MOUSE_BUTTON_WHEEL_UP:
						targetRotationX += 0.1
						# call the zoom function
					# zoom out
					if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
						targetRotationX -= 0.1
						# call the zoom function
				else:
				# zoom in
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
