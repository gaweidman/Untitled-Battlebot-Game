extends Part

class_name PartActive

@export var meshNode : MeshInstance3D;
@export var model : Mesh;
@export var modelMaterial : StandardMaterial3D;
@export var modelOffset = Vector3(0,0,0);
@export var modelScale = Vector3(1,1,1);
@export var energyCost = 1;
@export var positionNode : Node3D; ##This needs to be the thing with the position on it - in thbis case, the Body node
@export var looksAtMouse := true;
@export var rotateWithPlayer := false;
var combatHandler : CombatHandler;
var inputHandler : InputHandler;
var motionHandler : MotionHandler;

@export var fireRate := 0.15;
@export var fireRateTimer := 0.0;

func _ready():
	super();
	meshNode.set_deferred("mesh", model);
	meshNode.set_deferred("surface_material_override/0", modelMaterial);
	meshNode.set_deferred("scale", modelScale);

func _activate():
	if can_fire():
		if combatHandler:
			combatHandler.energy -= energyCost;
		else:
			return
	else:
		return
	##Get Inventory's energy total and subtract energyCost from it
	pass

func _set_fire_rate_timer():
	fireRateTimer = fireRate;

func _physics_process(delta):
	if looksAtMouse: _rotate_to_look_at_mouse(delta)
	if rotateWithPlayer: _rotate_with_player();
	
	if fireRateTimer <= 0:
		pass
	else:
		fireRateTimer -= delta;

func can_fire() -> bool: 
	return fireRateTimer <= 0;
		##Temp condition, can be changed later

func _process(delta):
	#print("why.")
	super(delta)
	if positionNode != null:
		var ply = GameState.get_player()
		#var pos = ply._get_part_offset(1)
		#meshNode.position = positionNode.position + pos;
		#meshNode.position = positionNode.position;
	else:
		print('null')
	if ! is_instance_valid(combatHandler):
		combatHandler = inventoryNode.combatHandler;
	if ! is_instance_valid(thisBot):
		thisBot = inventoryNode.thisBot;
		if ! is_instance_valid(motionHandler):
			motionHandler = inventoryNode.thisBot.motionHandler;
	meshNode.set_deferred("position", modelOffset);

func _rotate_to_look_at_mouse(delta):
	var rot = Vector3.ZERO;
	if thisBot is Player:
		rot = InputHandler.mouseProjectionRotation(positionNode);
	else:
		rot = InputHandler.playerPosRotation(positionNode);
	rot = rot.rotated(Vector3(0,1,0), deg_to_rad(90))
	#print(rot)
	meshNode.look_at(meshNode.global_transform.origin + rot, Vector3.UP)
	meshNode.rotation += positionNode.rotation;
	#rotation = 

func _rotate_with_player():
	var bdy = GameState.get_player_body_mesh()
	meshNode.rotation = bdy.rotation;
