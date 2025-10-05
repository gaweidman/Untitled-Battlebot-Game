extends StatHolder3D

class_name Piece

########## STANDARD GODOT PROCESSING FUNCTIONS

func _ready():
	hide();
	ability_registry();
	super(); #Stat registry.
	gather_colliders_and_meshes();

func _physics_process(delta):
	if not is_paused():
		phys_process_collision(delta);
		phys_process_abilities(delta);

func _process(delta):
	process_draw(delta);

func stat_registry():
	if energyDrawPassive > 0:
		register_stat("PassiveEnergyDraw", energyDrawPassive, statIconEnergy);
	if energyDrawPassive < 0:
		register_stat("PassiveEnergyRegeneration", energyDrawPassive, statIconEnergy);
	
	#Stats that only matter if the thing has abilities.
	if activeAbilities.size() > 0:
		register_stat("ActiveEnergyDraw", energyDrawActive, statIconEnergy);
		register_stat("ActiveCooldown", activeCooldownTime, statIconCooldown);
	
	#Stats regardig Scrap Cost.
	register_stat("ScrapCost", scrapCostBase, statIconMagazine, null, null, StatTracker.roundingModes.Ceili);
	register_stat("ScrapSellModifier", scrapSellModifierBase, statIconMagazine);
	register_stat("ScrapSalvageModifier", scrapSellModifierBase, statIconMagazine);
	register_stat("Weight", weightBase, statIconCooldown);

##This is here for when things get out of whack and some of the export variables disconnect themselves for no good reason.
func assign_references():
	var allOK = true;
	if !is_instance_valid(placementCollisionHolder):
		if is_instance_valid($"PlacementShapes [Leave empty]"):
			placementCollisionHolder = $"PlacementShapes [Leave empty]";
			pass;
	else:
		allOK = false;
	if !is_instance_valid(hurtboxCollisionHolder):
		if is_instance_valid($"HurtboxShapes [Leave empty]"):
			hurtboxCollisionHolder = $"HurtboxShapes [Leave empty]";
			pass;
	else:
		allOK = false;
	if !is_instance_valid(hitboxCollisionHolder):
		if is_instance_valid($"HitboxShapes [Leave empty]"):
			hitboxCollisionHolder = $"HitboxShapes [Leave empty]";
			pass;
	else:
		allOK = false;
	if !is_instance_valid(meshesHolder):
		if is_instance_valid($"Meshes"):
			meshesHolder = $"Meshes";
			pass;
	else:
		allOK = false;
	if !is_instance_valid(femaleSocketHolder):
		if is_instance_valid($"FemaleSockets"):
			femaleSocketHolder = $"FemaleSockets";
			pass;
	else:
		allOK = false;
	
	if not allOK:
		print("References for piece ", name, " were invalid. ")
		queue_free();

#################### VISUALS AND TRANSFORM

@export var force_visibility := false; 

func process_draw(delta):
	#return;
	#print(hurtboxCollisionHolder.get_collision_layer())
	if not has_host(true, false, false) and not force_visibility:
		if visible: hide()
	else:
		if not visible: show()

enum selectionModes {
	NOT_SELECTED,
	SELECTED,
	PLACEABLE,
	NOT_PLACEABLE,
}
var selectionModeMaterials = {
	selectionModes.NOT_SELECTED : null,
	selectionModes.SELECTED : preload("res://graphics/materials/glow_selected_fx.tres"),
	selectionModes.PLACEABLE : preload("res://graphics/materials/CanPlace.tres"),
	selectionModes.NOT_PLACEABLE : preload("res://graphics/materials/cannot_be_placed.tres"),
}
var selectionMode := selectionModes.NOT_SELECTED;
func set_selection_mode(mode : selectionModes = selectionModes.NOT_SELECTED):
	if selectionMode == mode: return;
	selectionMode = mode;
	if mode == selectionModes.NOT_SELECTED:
		for mesh in get_all_meshes():
			mesh.set_surface_override_material(0, meshMaterials[mesh]);
	else:
		for mesh in get_all_meshes():
			mesh.set_surface_override_material(0, selectionModeMaterials[mode]);
	pass;
var meshMaterials = {};
#var meshMaterials = Dictionary[MeshInstance3D, StandardMaterial3D] = {};
func get_all_mesh_init_materials():
	for mesh in get_all_meshes():
		meshMaterials[mesh] = mesh.get_active_material(0);
func get_all_meshes() -> Array:
	var meshes = Utils.get_all_children_of_type(self, MeshInstance3D, self);
	return meshes;

################ PIECE MANAGEMENT

@export_category("Piece Data")
@export var pieceName : StringName = "Piece";
@export_multiline var pieceDescription := "No Description Found.";
@export var weightBase := 1.0;

@export var scrapCostBase : int;
@export var scrapSellModifierBase := (2.0/3.0);
@export var scrapSalvageModifierBase := (1.0/6.0);

@export var removable := true;

##TODO: Scrap sell/buy/salvage functions for when this has Parts inside of it.
##Gets the Scrap amount for when you sell this Piece. Does not take into account the price of any Parts inside its Engine.
##discountMultiplier is multiplied by the price.
func get_sell_price_piece_only(discountMultiplier := 1.0):
	return max(0, ceili(get_stat("ScrapCost") * get_stat("ScrapSellModifier") * discountMultiplier));

##Gets the Scrap amount for when the Robot this is attached to dies and you're awarded Scrap. Does not take into account the price of any Parts inside its Engine.
##discountMultiplier is multiplied by the price.
func get_salvage_price_piece_only(discountMultiplier := 1.0):
	return max(0, ceili(get_stat("ScrapCost") * get_stat("ScrapSalvageModifier") * discountMultiplier));

##Gets the Scrap amount for attempting to buy this Piece.
##discountMultiplier is multiplied by the price.
##fixedMarkup is added to the price.
func get_buy_price_piece_only(discountMultiplier := 1.0, fixedMarkup := 0):
	var currentPrice = maxi(0, ceili(get_stat("ScrapCost") * discountMultiplier))
	return currentPrice + fixedMarkup;

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
		if has_host(true, true, true):
			hitboxRescaleTimer = 3;
			##TODO: Figure out how to scale the hurtboxes vertically real tall...... this ain't it.
			#hitboxCollisionHolder.scale = Vector3.ONE;
			#hitboxCollisionHolder.call_deferred("global_scale", Vector3(1, 1000, 1));
			#hitboxCollisionHolder.set_deferred("global_position", Vector3((get_host_robot().get_global_body_position() + position) * Vector3(1, 0, 1) + Vector3(0,-5,0)));
			
			hurtboxCollisionHolder.collision_layer = 8 + 64; #Hurtbox layer and placed layer.
		else:
			hurtboxCollisionHolder.collision_layer = 8; #Hurtbox layer and hover layer.

##Assign all sockets with this as their host piece.
func autoassign_child_sockets_to_self():
	for child in Utils.get_all_children_of_type(self, Socket, self):
		child.hostPiece = self;

##This function assigns socket data and generates all hitboxes. Should only ever be run once at [method _ready()].
func gather_colliders_and_meshes():
	autograb_sockets();
	get_all_mesh_init_materials();
	autoassign_child_sockets_to_self();
	refresh_and_gather_collision_helpers();

##This function regenerates all collision boxes. Should in theory only ever be run at [method _ready()], but the Piece Helper tool scene uses it also.
func refresh_and_gather_collision_helpers():
	#Clear out all copies.
	reset_collision_helpers();
	
	#Clear all colliders from their respective areas, given that the resets didn't work.
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
			if child.isOriginal and not child.copied:
				child.reset();
				child.originalOffset = child.global_position - global_position;
				child.originalRotation = child.global_rotation - global_rotation;
				if child.identifier == null:
					child.identifier = str(identifyingNum)
					identifyingNum += 1;
				if is_instance_valid(child.shape):
					##if the PieceCollisionBox is of type PlACEMENT then it should spawn a shapecast proxy with an identical shape.
					if child.isPlacementBox:
						var shapeCastNew = child.make_shapecast();
						shapeCastNew.reparent(placementCollisionHolder, true);
						shapeCastNew.add_exception(hitboxCollisionHolder);
						shapeCastNew.add_exception(hurtboxCollisionHolder);
					##if the PieceCollisionBox is of type HITBOX or HURTBOX then it should copy itself into those.
					if child.isHurtbox:
						var dupe = child.make_copy();
						dupe.disabled = false;
						hurtboxCollisionHolder.add_child(dupe);
						dupe.debug_color = Color("0099b36b");
						#print("COllider ID when copying from ", name, " ", dupe.colliderID)
						#dupe.global_position = child.global_position;
					if child.isHitbox:
						var dupe = child.make_copy();
						dupe.disabled = false;
						hitboxCollisionHolder.add_child(dupe);
						dupe.debug_color = Color("f6007f6b");
						#dupe.global_position = child.global_position;
	#print(placementCollisionHolder)
	pass;

##Runs the Reset function on all collision helpers.
func reset_collision_helpers():
	for child in get_children():
		if child is PieceCollisionBox and child.isOriginal:
			child.reset();

##Should ping all of the placement hitboxes and return TRUE if it collides with a Piece, of FALSE if it doesn't.
func ping_placement_validation():
	if is_node_ready():
		var collided := false;
		#print(get_children())
		var shapecasts = []
		for child in placementCollisionHolder.get_children():
			#print("Hi 1")
			#print(placementCollisionHolder.get_children())
			if not collided:
				#print("Hi 2")
				if child is ShapeCast3D:
					#print("Hi 3")
					#child.reparent(self, true);
					#shapecasts.append(child);
					child.force_shapecast_update();
					if child.is_colliding(): 
						var collider = child.get_collider(0);
						if collider is HurtboxHolder:
							#print(self, collider.get_piece())
							if self != collider.get_piece():
								collided = true;
						if collider is RobotBody:
							collided = true;
						else:
							#print("what")
							#print(collider)
							pass;
	
	##Put all the shapecasts back.
	#for cast in shapecasts:
		#cast.reparent(placementCollisionHolder, true);
	
		#print(collided)
		if collided: set_selection_mode(selectionModes.NOT_PLACEABLE);
		else: set_selection_mode(selectionModes.PLACEABLE);
		return collided;
	return true;

func get_all_hitboxes():
	return hitboxCollisionHolder.get_children();

##TODO: Figure out what this is even useful for. Taking damage? 
##Figure out how to know the body is a Robot.
func on_hurtbox_collision(body : CollisionObject3D):
	##TODO: Add a Hook here.
	GameState
	#if body :
		#hostRobot.on_hitbox_collision(body, self);
	pass

func get_all_hurtboxes():
	return hurtboxCollisionHolder.get_children();

func _on_hitbox_shapes_body_entered(body):	
	if body != self:
		on_hurtbox_collision(body);
	pass # Replace with function body.

func _on_hitbox_shapes_area_entered(area):
	on_hurtbox_collision(area);
	pass # Replace with function body.

var hitboxEnabled = false;
func disable_hurtbox(foo:bool):
	for child in hurtboxCollisionHolder.get_children():
		if child is PieceCollisionBox:
			child.disabled = foo;

##Fired whent he camera finds this piece.
##TODO: Fancy stuff. 
var selected := false;

func get_selected() -> bool:
	return selected;

func select(foo : bool = not get_selected()):
	if foo == selected: return foo;
	if foo: deselect_other_pieces(self);
	else: deselect_other_pieces();
	selected = foo;
	if selected: 
		if selectionMode == selectionModes.NOT_SELECTED:
			set_selection_mode(selectionModes.SELECTED);
	else: set_selection_mode(selectionModes.NOT_SELECTED);
	print(pieceName)
	return selected;
	pass;

func select_via_robot():
	if is_instance_valid(get_host_robot()):
		get_host_robot().select_piece(self);

func deselect():
	deselect_all_sockets();
	select(false);

func deselect_other_pieces(filterPiece := self):
	if has_host(false, true, false):
		var bot = get_host_robot();
		bot.deselect_all_pieces(filterPiece);

##Need to have support for a main 3D model. Sub-models will need to come later.
##Position should NEVER be changed from 0,0,0. 0,0,0 Origin is where this thing plugs in.

####################### CHAIN MANAGEMENT
##Needs ways of pinging 3D spacve when trying to place it with its collision to check where it can be placed.
##

##TODO: Functions for assigning the host robot and host piece.
##When the piece is assigned to a socket or robot, it should reparent itself to it.
@export_category("Chain Management")
@export var hostPiece : Piece;
@export var hostRobot : Robot;

@export var femaleSocketHolder : Node3D;
@export var hostSocket : Socket;
@export var assignedToSocket := false;
var allSockets : Array[Socket] = []

func autograb_sockets():
	var sockets = Utils.get_all_children_of_type(self, Socket, self);
	for socket in sockets:
		Utils.append_unique(allSockets, socket);
		socket.set_host_piece(self);
	pass;

##Returns a list of all sockets on this part.
func get_all_female_sockets() -> Array[Socket]:
	autograb_sockets();
	return allSockets;

func register_socket(socket : Socket):
	Utils.append_unique(allSockets, socket);

##Assigns this Piece to a given Socket.
##This essentially places the thing.
func assign_socket(socket:Socket):
	print("Children", get_children())
	socket.add_occupant(self);
	hostRobot.remove_something_from_stash(self);
	hostRobot.reassign_body_collision();
	assignedToSocket = true;
	hurtboxCollisionHolder.set_collision_mask_value(8, false);
	set_selection_mode(selectionModes.NOT_SELECTED);
	pass;

func is_assigned() -> bool:
	return assignedToSocket;

##Removes this piece from its assigned Socket.
func remove_from_socket():
	disconnect_from_host_socket();
	hostSocket = null;
	hostRobot = null;
	assignedToSocket = false;
	if is_instance_valid(get_parent()):
		get_parent().remove_child(self);
	#ping the
	pass;

func get_specific_female_socket(index):
	return femaleSocketHolder.get_child(index);

func disconnect_from_host_socket():
	if is_instance_valid(hostSocket):
		hostSocket.remove_occupant();
	else:
		hostSocket = null;

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

func get_host_robot(forceReturnRobot := false) -> Robot:
	if forceReturnRobot: return hostRobot;
	
	if get_host_socket() == null:
		return null;
	else:
		return hostRobot;

func host_is_player() -> bool:
	return has_robot_host() and hostRobot is Robot_Player;

func has_socket_host():
	return is_instance_valid(get_host_socket());
func is_assigned_to_socket():
	return has_socket_host() and assignedToSocket;
func has_robot_host():
	return is_instance_valid(get_host_robot());
func equipped_by_player():
	return has_robot_host() and (get_host_robot() is Robot_Player);

##Returns true if the part has both a host socket and a host robot.
func has_host(getSocket := true, getRobot := true, getSocketAssigned := true):
	if getSocketAssigned and (not is_assigned_to_socket()):
		return false;
	if getSocket and (not has_socket_host()):
		return false;
	if getRobot and (not has_robot_host()):
		return false;
	return true;

var selectedSocket : Socket;
func assign_selected_socket(socket):
	deselect_all_sockets();
	socket.select();
	selectedSocket = socket;
	##TODO: Hook this into giving that socket a new Piece.

func deselect_all_sockets():
	for socket in get_all_female_sockets():
		socket.select(false);

var allPiecesLoops := 0;

func get_all_pieces() -> Array[Piece]:
	var ret : Array[Piece] = []
	#print("ALL FEMALE SOCKETS: ", get_all_female_sockets())
	for socket in get_all_female_sockets():
		allPiecesLoops += 1;
		#print("ALL PIECES LOOOPS: ", allPiecesLoops);
		var occupant = socket.get_occupant();
		if occupant != null:
			#print("ALL PIECES OCCUPANT :", occupant, " SELF : ", self)
			if occupant != self:
				ret.append(occupant);
	print("ALL PIECES : ", ret)
	return ret;

################# MELEE 
##If the thing is meant to do something upon making contact with another Robot, put what happens in here.
##Empty at base, and isn't called.
func contact_damage(robot: Robot) -> void:
	pass;

####################### ABILITY AND ENERGY MANAGEMENT

@export_category("Ability")
@export var hurtboxAlwaysEnabled := false;

@export var input : InputEvent;
@export var energyDrawPassive := 0.0; ##power drawn each frame, multiplied by time delta. If this is negative, it is instead power being generated each frame.
@export var energyDrawActive := 0.0; ##power drawn when you use any this piece's active abilities, given that it has any.
var energyDrawCurrent := 0.0; ##Recalculated and updated each frame.

var incomingPower := 0.0;
var hasIncomingPower := true;
var transmittingPower := true; ##While false, no power is transmitted from this piece.

##The amount of time needed between uses of this Piece's Active Abilities.
@export var activeCooldownTime := 0.5;
var activeCooldownTimer := 0.0;
func set_cooldown():
	set_deferred("activeCooldownTimer", get_stat("ActiveCooldown"));

func on_cooldown():
	return activeCooldownTimer > 0;

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

func is_transmitting():
	return hasIncomingPower and transmittingPower;

##If this part is plugged into a socket, returns that socket's power.
##If not, then it's probably a robot body or not plugged in, and returns 0.
func get_incoming_energy():
	if get_host_socket() != null:
		var powerTransmitted = get_host_socket().get_energy_transmitted();
		#print_if_true(get_host_socket(), self is Piece_Sawblade)
		if powerTransmitted <= 0.0: 
			hasIncomingPower = false;
		else: 
			hasIncomingPower = true;
		incomingPower = powerTransmitted;
		return incomingPower;
	else:
		if is_instance_valid(hostRobot):
			#print("No host socket, yes power: ", hostRobot.get_available_energy())
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

##Returns true if the actionSlot has an ability assigned and energy draw post-use would not exceed the incoming energy pool.
func can_use_active(actionSlot : int): 
	if get_active_ability(actionSlot) == null:
		return false;
	return (not on_cooldown()) and (( get_current_energy_draw() + get_active_energy_cost() ) <= get_incoming_energy());

##Returns true if energyDrawPassive is 0, or if the power draw would not exceed incoming power.
func can_use_passive():
	if energyDrawPassive == 0.0:
		return true;
	#print( energyDrawPassive, get_current_energy_draw(),  get_passive_energy_cost(), get_incoming_energy())
	return (energyDrawPassive != 0.0) and (( get_current_energy_draw() + get_passive_energy_cost() ) <= get_incoming_energy());

func use_passive():
	if can_use_passive():
		energyDrawCurrent += get_passive_energy_cost();
		return true;
	return false;

var activeAbilities : Dictionary[int, AbilityManager] = {}

## Where any and all register_active_ability() or related calls should go. Runs at _ready().
func ability_registry():
	pass;

func get_next_available_ability_slot():
	var num := 0;
	while activeAbilities.keys().has(num):
		num += 1;
	return num;

## This should be run in ability_registry() only.
## abilityName = name of ability.
## abilityDescription = name of ability.
## functionWhenUsed = the function that gets called when this ability is called for.
## statsUsed = an Array of strings. This should hold any and all stats you want to have displayed on this ability's card.
## slotOverride is if you want to have this ability use a specific numbered slot.
func register_active_ability(abilityName : String = "Active Ability", abilityDescription : String = "No Description Found.", functionWhenUsed : Callable = func(): pass, statsUsed : Array = [], slotOverride = null):
	var newAbility = AbilityManager.new();
	var slot = slotOverride;
	if slot == null: slot = get_next_available_ability_slot();
	newAbility.register(self, slot, abilityName, abilityDescription, functionWhenUsed, statsUsed);
	activeAbilities[slot] = newAbility;
	pass;

func get_active_ability(actionSlot : int) -> AbilityManager:
	if activeAbilities.keys().has(actionSlot):
		return activeAbilities[actionSlot];
	return null;

##Calls the ability in the given slot if it's able to do so.
func use_active(actionSlot : int):
	if can_use_active(actionSlot):
		energyDrawCurrent += get_active_energy_cost();
		set_cooldown();
		var activeAbility = get_active_ability(actionSlot);
		var call = activeAbility.functionWhenUsed;
		call.call();
		return true;
	return false;



####################### INVENTORY STUFF
@export_category("Stash")

## Removes this Piece and any Pieces below it, then adds them to the stash of the robot they're on, if there is one. Calls [method remove_from_socket], then [method Robot.add_something_to_stash], then [method Robot_Player.queue_close_engine].
func remove_and_add_to_robot_stash(botOverride : Robot = get_host_robot(true)):
	deselect();
	##Stash everything below this.
	for subPiece in get_all_pieces():
		print("PIECE IN ALL PIECES: ", subPiece.pieceName)
		subPiece.remove_and_add_to_robot_stash(botOverride);
	
	remove_from_socket();
	var bot = botOverride;
	if is_instance_valid(bot):
		bot.add_something_to_stash(self);
		if bot is Robot_Player:
			bot.queue_close_engine();

@export_category("Engine")
#var pieceBonusOut : Array[PartModifier] = [] ##TODO: MAKE A PIECE BONUS THING

##TODO:
##Copy from the original 2D inventories. 
##Needs ways of transmitting bonus data to the main body.
##Needs ways of storing bonus data in a concise way.

@export var engineSlots := {
	## Row 0
	Vector2i(0,0) : null,
	Vector2i(1,0) : null,
	Vector2i(2,0) : null,
	Vector2i(3,0) : null,
	Vector2i(4,0) : null,
	## Row 1
	Vector2i(0,1) : null,
	Vector2i(1,1) : null,
	Vector2i(2,1) : null,
	Vector2i(3,1) : null,
	Vector2i(4,1) : null,
	## Row 2
	Vector2i(0,2) : null,
	Vector2i(1,2) : null,
	Vector2i(2,2) : null, 
	Vector2i(3,2) : null,
	Vector2i(4,2) : null,
	## Row 3
	Vector2i(0,3) : null,
	Vector2i(1,3) : null,
	Vector2i(2,3) : null,
	Vector2i(3,3) : null,
	Vector2i(4,3) : null,
	## Row 4
	Vector2i(0,4) : null,
	Vector2i(1,4) : null,
	Vector2i(2,4) : null,
	Vector2i(3,4) : null,
	Vector2i(4,4) : null,
}

## Returns a list of all the [Part] inside the [member engineSlots]. Utilizes [method Utils.append_unique] so each [Part] is only added once to the resulting [Array].
func get_all_parts() -> Array[Part]:
	var gatheredParts : Array[Part] = [];
	for slot in engineSlots.keys():
		var slotContents = engineSlots[slot];
		if slotContents != null:
			if slotContents is Part:
				if slotContents.get_engine() == self:
					Utils.append_unique(gatheredParts, slotContents);
	return gatheredParts;

func get_stash_button_name() -> String:
	var ret = pieceName;
	for piece in get_all_pieces():
		ret += "\n   " + piece.pieceName;
	return ret;
