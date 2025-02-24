extends MakesNoise;

@export var maxSpeed: float;
@export var startingHealth: int;

var body;
var health;
var maxHealth;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = $Body;
	print("BODY ", body)
	maxHealth = startingHealth;
	health = startingHealth;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# gets the direction the player is trying to go
func get_movement_vector():
	var movementVector = Vector2(0, 0);
	if Input.is_action_pressed("MoveLeft"):
		movementVector += Vector2.LEFT;
		
	if Input.is_action_pressed("MoveRight"):
		movementVector += Vector2.RIGHT;
		
	if Input.is_action_pressed("MoveUp"):
		movementVector += Vector2.UP;
		
	if Input.is_action_pressed("MoveDown"):
		movementVector += Vector2.DOWN;
		
	return movementVector
	
# custom physics handling for player movement. regular movement feels flat and boring.
func _physics_process(delta):	
	do_gravity(delta);
		
	clamp_speed();
# make sure the player's speed doesn't go over its max speed
func clamp_speed():
	body.linear_velocity.x = clamp(body.linear_velocity.x, -maxSpeed, maxSpeed)
	body.linear_velocity.z = clamp(body.linear_velocity.z, -maxSpeed, maxSpeed)
	
func do_gravity(delta):
	body.linear_velocity.y -= GameState.GRAVITY * delta;
	
func take_damage(damage):
	health -= damage;
	get_node("../GUI/Health").text = "Health: " + health + "/" + maxHealth;
	if health <= 0:
		die();
		
func die():
	queue_free();
	
func process_collision():
	pass

# if a given number is positive, returns 1. if it's negative, returns -1. if it's
# 0, returns 0.
func get_sign(num):
	if num == 0:
		return 0
	else:
		return num/abs(num);


func _on_sawblade_body_entered(body: Node) -> void:
	print("we're here", body)


func _on_body_body_entered(collider: Node) -> void:
	if collider.is_in_group("Damager"):
		take_damage(1);
