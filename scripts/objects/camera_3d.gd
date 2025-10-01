extends Camera3D

class_name Camera



var socketHovering : Socket;
var pieceHovering : Piece;

func click_on_piece():
	var collisionMask = 8;
	
	var raycastHit = RaycastSystem.get_raycast_hit_object(collisionMask);
	#print(raycastHit)
	if is_instance_valid(raycastHit): 
		#print(raycastHit)
		if raycastHit is HurtboxHolder:
			raycastHit.select_piece();

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
