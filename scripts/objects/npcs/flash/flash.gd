extends EnemyBase

@export var regularSpeed : float;
@export var chargeSpeed : float;
@export var chargeDistance : float;
@export var chargeCooldown : float;

var aiHandler;

func _ready():
	aiHandler = super.get_node("AIHandler");

func _on_body_body_entered(other): 
	aiHandler._on_collision(other);

func _process(delta):
	super(delta);
	if is_instance_valid(inventory):
		inventory.add_part_from_scene(0,0,"res://scenes/prefabs/objects/parts/playerParts/part_sawblade.tscn",0);
