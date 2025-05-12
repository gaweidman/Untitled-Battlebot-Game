extends CombatHandler

class_name CombatHandlerEnemy

@export var scrap_worth := 1;
var DIEFX = preload("res://scenes/prefabs/particle-fx/BoltsHit.tscn")

func _on_collision(collider):
	super(collider);
	var parent = collider.get_parent();
	if parent and parent.is_in_group("Projectile"):
		if parent.get_attacker() != self:
			pass;
			#take_damage(1);

func use_active(index):
	super(index);
	#print(can_fire(0))

func die():
	var inv = GameState.get_inventory();
	if is_instance_valid(inv):
		inv.add_scrap(scrap_worth, "Kill");
		
	ParticleFX.play("NutsBolts", GameState.get_game_board(), body.global_position);
	if GameState.get_in_state_of_play():
		SND.play_sound_at("Combatant.Die", body.global_position);
	super();
