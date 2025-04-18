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
