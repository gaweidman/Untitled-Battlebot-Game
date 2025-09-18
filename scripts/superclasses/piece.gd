extends MakesNoise

class_name Piece

########## STANDARD GODOT PROCESSING FUNCTIONS

func _ready():
	autograb_sockets();
	gather_colliders_and_meshes();

func _physics_process(delta):
	phys_process_collision(delta);
	phys_process_abilities(delta);

func _process(delta):
	process_draw(delta);


#################### VISUALS AND TRANSFORM

func process_draw(delta):
	#return;
	#print(hurtboxCollisionHolder.get_collision_layer())
	if not has_host():
		if visible: hide()
	else:
		if not visible: show()

################ PIECE MANAGEMENT

@export_category("Piece Management")
@export var pieceName : StringName = "Piece";
@export_multiline var partDescription := "No description given.";

@export var hostSocket : Socket;
@export var hostPiece : Piece;
@export var hostRobot : Robot;



################### COLLISION

@export_category("Collision")
@export var placementCollisionHolder : Node3D;
@export var hurtboxCollisionHolder : Area3D;
@export var hitboxCollisionHolder : Area3D;
@export var meshesHolder : Node3D;
#var bodyMeshes : Dictionary[StringName, MeshInstance3D] = {};

##Frame timer that updates scale of hitboxes every 3 frames.
var hitboxRescaleTimer := 0;
func phys_process_collision(delta):
	hitboxRescaleTimer -= 1;
	if hitboxRescaleTimer <= 0:
		if has_host():
			hitboxRescaleTimer = 3;
			##TODO: Figure out how to scale the hurtboxes vertically real tall...... this ain't it.
			#hitboxCollisionHolder.scale = Vector3.ONE;
			#hitboxCollisionHolder.call_deferred("global_scale", Vector3(1, 1000, 1));
			#hitboxCollisionHolder.set_deferred("global_position", Vector3((get_host_robot().get_global_body_position() + position) * Vector3(1, 0, 1) + Vector3(0,-5,0)));
			
			hurtboxCollisionHolder.collision_layer = 8 + 64; #Hurtbox layer and placed layer.
		else:
			hurtboxCollisionHolder.collision_layer = 8; #Only hurtbox layer.

##This function assigns socket data and generates all hitboxes. Should only ever be run once at _ready.
func gather_colliders_and_meshes():
	autograb_sockets();
	#Assign all sockets with this as their host piece.
	for child in Utils.get_all_children_of_type(self, Socket, self):
		child.hostPiece = self;
	
	#Clear all colliders from their respective areas.
	for child in placementCollisionHolder.get_children():
		child.queue_free();
	for child in hurtboxCollisionHolder.get_children():
		child.queue_free();
	for child in hitboxCollisionHolder.get_children():
		child.queue_free();
	
	var identifyingNum = 0;
	for child in get_children():
		if child is PieceCollisionBox:
			child.originalHost = self;
			if child.identifier == null:
				child.identifier = str(identifyingNum)
				identifyingNum += 1;
			if is_instance_valid(child.shape):
				##if the PieceCollisionBox is of type PlACEMENT then it should spawn a shapecast proxy with an identical shape.
				if child.isPlacementBox:
					var shapeCastNew = ShapeCast3D.new()
					placementCollisionHolder.add_child(shapeCastNew);
					shapeCastNew.set_deferred("target_position", Vector3(0,0,0));
					shapeCastNew.set_deferred("global_position", child.global_position);
					shapeCastNew.set_deferred("scale", child.scale * 0.95);
					shapeCastNew.set_deferred("rotation", child.rotation);
					shapeCastNew.set("shape", child.shape);
					#shapeCastNew.enabled = false;
					shapeCastNew.enabled = true;
					shapeCastNew.debug_shape_custom_color = Color("af7f006b");
				##if the PieceCollisionBox is of type HITBOX or HURTBOX then it should copy itself into those.
				if child.isHurtbox:
					var dupe = child.duplicate();
					dupe.disabled = false;
					hurtboxCollisionHolder.add_child(dupe);
					dupe.debug_color = Color("0099b36b");
					#dupe.global_position = child.global_position;
				if child.isHitbox:
					var dupe = child.duplicate();
					dupe.disabled = false;
					hitboxCollisionHolder.add_child(dupe);
					dupe.debug_color = Color("f6007f6b");
					#dupe.global_position = child.global_position;
			child.queue_free();
	#print(placementCollisionHolder)
	pass;

##Should ping all of the placement hitboxes and return TRUE if it collides with a Piece, of FALSE if it doesn't.
##TODO: Fix this. placementCollisionHolder is being freed for some ungodly reason.
func ping_placement_validation():
	var collided := false;
	#print(get_children())
	for child in placementCollisionHolder.get_children():
		#print("Hi 1")
		#print(placementCollisionHolder.get_children())
		if not collided:
			#print("Hi 2")
			if child is ShapeCast3D:
				#print("Hi 3")
				child.force_shapecast_update();
				if child.is_colliding(): 
					#print("Yello?")
					var collider = child.get_collider(0);
					if collider.is_in_group("Piece") or collider.is_in_group("Combatant"):
						collided = true;
	#print(collided)
	return collided;

func get_all_hitboxes():
	return hitboxCollisionHolder.get_children();

##TODO: Figure out what this is even useful for. Damaging stuff? 
##Figure out how to know the body is a Robot.
func on_hitbox_collision(body : CollisionObject3D):
	##TODO: Add a Hook here.
	#if body :
		#hostRobot.on_hitbox_collision(body, self);
	pass

func get_all_hurtboxes():
	return hurtboxCollisionHolder.get_children();

func _on_hitbox_shapes_body_entered(body):
	if body != self:
		on_hitbox_collision(body);
	pass # Replace with function body.

func _on_hitbox_shapes_area_entered(area):
	on_hitbox_collision(area);
	pass # Replace with function body.

var hitboxEnabled = false;
func disable_hurtbox(foo:bool):
	for child in hurtboxCollisionHolder.get_children():
		if child is PieceCollisionBox:
			child.disabled = foo;

##Fired whent he camera finds this piece.
##TODO: Fancy stuff. 
func select():
	print(pieceName)
	pass;

##Need to have support for a main 3D model. Sub-models will need to come later.
##Position should NEVER be changed from 0,0,0. 0,0,0 Origin is where this thing plugs in.

####################### INVENTORY STUFF

@export_category("Engine")
#var pieceBonusOut : Array[PartModifier] = [] ##TODO: MAKE A PIECE BONUS THING

##TODO:
##Copy from the original 2D inventories. 
##Needs ways of transmitting bonus data to the main body.
##Needs ways of storing bonus data in a concise way.




####################### CHAIN MANAGEMENT
##Needs ways of pinging 3D spacve when trying to place it with its collision to check where it can be placed.
##

##TODO: Functions for assigning the host robot and host piece.
##When the piece is assigned to a socket or robot, it should reparent itself to it.

@export var femaleSocketHolder : Node3D;
var allSockets : Array[Socket] = []

func autograb_sockets():
	Utils.append_array_unique(allSockets, Utils.get_all_children_of_type(self, Socket, self));
	for socket in allSockets:
		socket.set_host_piece(self);
	pass;

##Returns a list of all sockets on this part.
func get_all_female_sockets():
	autograb_sockets();
	return allSockets;

func register_socket(socket : Socket):
	Utils.append_unique(allSockets, socket);

var assignedToSocket := false;
##Assigns this Piece to a given Socket.
func assign_socket(socket:Socket):
	socket.add_occupant(self);
	hostRobot.reassign_body_collision();
	assignedToSocket = true;
	pass;

##Removes this piece from its assigned Socket.
func remove_from_socket():
	hostSocket.remove_occupant();
	hostSocket = null;
	hostRobot = null;
	assignedToSocket = false;
	#ping the
	pass;


func get_specific_female_socket(index):
	return femaleSocketHolder.get_child(index);

func disconnect_from_host_socket():
	hostSocket.remove_occupant();

func get_host_socket() -> Socket:
	if is_instance_valid(hostSocket):
		return hostSocket;
	else:
		return null;

func get_host_piece() -> Piece:
	if get_host_socket() == null:
		return null;
	else:
		return get_host_socket().get_host_piece();

func get_host_robot() -> Robot:
	if get_host_socket() == null:
		return null;
	else:
		return hostRobot;

##Returns true if the part has both a host socket and a host robot.
func has_host():
	return hostSocket and hostRobot and assignedToSocket;

var selectedSocket : Socket;
func assign_selected_socket(socket):
	deselect_all_sockets();
	socket.select();
	selectedSocket = socket;
	##TODO: Hook this into giving that socket a new Piece.

func deselect_all_sockets():
	for socket in get_all_female_sockets():
		socket.select(false);

####################### ABILITY AND ENERGY MANAGEMENT

@export_category("Ability")
@export var hurtboxAlwaysEnabled := false;

@export var input : InputEvent;
@export var energyDrawPassive := 0.0; #power drawn each frame, multiplied by time delta.
@export var energyDrawActive := 0.0; #power drawn when you use this part's active ability, given that it has one.
var energyDrawCurrent := 0.0; #updated each frame.

var incomingPower := 0.0;
var hasIncomingPower := true;
var transmittingPower := true; ##While false, no power is transmitted from this piece.

##Physics process step for abilities.
func phys_process_abilities(delta):
	if hurtboxAlwaysEnabled:
		disable_hurtbox(false);
	energyDrawCurrent = 0.0;
	##Use the passive ability of this guy.
	use_passive();

func get_outgoing_energy():
	if not is_transmitting(): return 0.0;
	return max(0.0, get_incoming_energy() - energyDrawCurrent);

##If this part is plugged into a socket, returns that socket's power.
##If not, then it's probably a robot body or not plugged in, and returns 0.
func get_incoming_energy():
	if get_host_socket() != null:
		var powerTransmitted = get_host_socket().get_energy_transmitted();
		if powerTransmitted <= 0.0: 
			hasIncomingPower = false;
		else: 
			hasIncomingPower = true;
		incomingPower = powerTransmitted;
		return incomingPower;
	else:
		if is_instance_valid(hostRobot):
			hasIncomingPower = true;
			incomingPower = hostRobot.get_available_energy();
			return incomingPower;
	incomingPower = 0.0;
	hasIncomingPower = false;
	return incomingPower;

func get_current_energy_draw():
	return energyDrawCurrent;

func get_active_energy_cost():
	##TODO: Bonuses
	return ( energyDrawActive );

func get_passive_energy_cost():
	##TODO: Bonuses
	return ( energyDrawPassive * get_physics_process_delta_time() );

func can_use_active():
	return  ( get_current_energy_draw() + energyDrawActive ) <= get_incoming_energy();

func can_use_passive():
	return (energyDrawPassive > 0) and (get_passive_energy_cost() <= get_incoming_energy());

##Extend with a super().
func use_active():
	if can_use_active():
		energyDrawCurrent += get_active_energy_cost();
	pass

func use_passive():
	if can_use_passive():
		energyDrawCurrent += get_passive_energy_cost();
		pass

func is_transmitting():
	return hasIncomingPower and transmittingPower;
