extends Node
var player;
var body;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = GameState.get_player();
	body = player.get_node("Body");
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# custom physics handling for player movement. regular movement feels flat and boring.
func _physics_process(delta):	
	if is_node_ready():
		do_gravity(delta);
		clamp_speed();
		
# make sure the player's speed doesn't go over its max speed
func clamp_speed():
	body.linear_velocity.x = clamp(body.linear_velocity.x, -player.maxSpeed, player.maxSpeed);
	body.linear_velocity.z = clamp(body.linear_velocity.z, -player.maxSpeed, player.maxSpeed);
	
func do_gravity(delta):
	body.linear_velocity.y -= GameState.GRAVITY * delta;
