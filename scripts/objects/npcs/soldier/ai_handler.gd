extends AIHandlerBase

class_name AIHandlerSoldier

var REGULARSPEED = 15000;
var CHARGESPEED = 15000;
var KITESPEED = 6000;
var CHARGEDIST = 8.5;
var RUNDIST = 7.5;
var CHARGECOOLDOWN = 2.5;
var CHARGETIME = 2.0;
var kitingDir = 90.0;

func ready():
	pass

func get_movement_vector():
	var ply = GameState.get_player();
	
	var curTime = Time.get_ticks_msec();
	
	#print(curTime)
	
	
	if ply:
		var this = self.get_parent()
		var playerPos = ply.get_global_body_position();
		var selfPos = this.get_node("Body").get_global_position();
		var posDiff = playerPos - selfPos;
		var normalized = posDiff.normalized();
		
		if posDiff.length() > CHARGEDIST:
			return Vector2(normalized.x, normalized.z) * CHARGESPEED;
		elif posDiff.length() < RUNDIST:
			return Vector2(normalized.x, normalized.z) * -REGULARSPEED;
		else: 
			return Vector2(normalized.x, normalized.z).rotated(deg_to_rad(kitingDir)) * KITESPEED;
	return Vector2(0, 0);

func reverse_kiting():
	kitingDir *= -1;

func _on_collision(this, other):
	#var this = self.get_parent()
	reverse_kiting();
	#if !other.is_in_group("WorldFloor"):
