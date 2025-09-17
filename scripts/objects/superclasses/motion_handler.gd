extends Node3D

class_name MotionHandler;

var raycasts;
var body;
var botBodyMesh;
var bodyRotationAngle = Vector2.ZERO;
var thisBot : Combatant;
var underbelly : UnderbellyContactPoints;
var airtime := 0.0;
var airCheckTimer = 0.0;
var inAir := false;


@export var maxSpeed: float;

func _ready() -> void:
	grab_references();

func _process(delta: float) -> void:
	return;
	if !thisBot:
		grab_references();
	else:
		airCheckTimer -= delta;
		if underbelly:
			if inAir:
				if airCheckTimer <= 0.0:
					if underbelly.is_on_floor():
						print_rich("[color=cyan]Airtime: "+str(airtime));
						#Hooks.OnLand(thisBot, airtime);
						inAir = false;
						airtime = 0.0;
					airCheckTimer = 0.05;
				else:
					airtime += delta;
			else:
				if airCheckTimer <= 0.0:
					if underbelly.is_on_floor():
						pass;
					else:
						inAir = true;
						airtime += delta;
					airCheckTimer = 0.05;
		else:
			grab_references();

func _physics_process(delta):
	if body:
		var downVec = -body.global_transform.basis.y;
	grab_references();

func grab_references():
	if ! is_instance_valid(thisBot):
		thisBot = get_node("../");
	if thisBot:
		body = thisBot.get_node("Body");
		botBodyMesh = body.get_node("BotBody");
		underbelly = botBodyMesh.get_node("UnderbellyRaycasts");
	pass;

static func look_at_safe(node, target):
	if node.get_parent().get_parent() != GameState.get_player(): 
		#print("IS EQUAL APPROX ", node.global_transform.origin.is_equal_approx(target))
		#print(node.global_transform.origin, " ", target)
		pass
	if node.global_transform.origin.is_equal_approx(target): return;
	node.look_at(target);

# make sure the bot's speed doesn't go over its max speed
func clamp_speed():
	body.linear_velocity.x = clamp(body.linear_velocity.x, -maxSpeed, maxSpeed);
	body.linear_velocity.z = clamp(body.linear_velocity.z, -maxSpeed, maxSpeed);

func _on_collision(collider: PhysicsBody3D, thisComponent: PhysicsBody3D = %Body):
	# if we've assigned a material to it, it can make a sound on collision, so this is how we check
	# whether or not this collision can play a sound
	#if (collider.is_in_group("Concrete") || collider.is_in_group("Metal") || collider.is_in_group("Plastic")) && (thisComponent.is_in_group("Concrete") || thisComponent.is_in_group("Metal") || thisComponent.is_in_group("Plastic")):
		#SND.play_collision_sound(thisComponent, collider)
		#thisBot.play_sound(SND.get_proper_sound(collider, thisComponent))
	SND.play_collision_sound(thisComponent, collider, Vector3.ZERO, 0.45)
	Hooks.OnCollision(thisComponent, collider);
	if collider.is_in_group("World"):
		airtime = 0.0;
