extends Node3D
var lockonPath;
var chargeCooldownTimer = 0;

var REGULARSPEED = 250;
var CHARGESPEED = 1500;
var CHARGEDIST = 7.5;
var CHARGECOOLDOWN = 2.5;

func ready():
	pass
	
func get_movement_vector():
	var ply = GameState.get_player();
	
	var curTime = Time.get_ticks_msec();
	
	#print(curTime)

	# this is a hotfix becasue for some reason the timer isn't always reset
	
	if ply:
		var this = self.get_parent()
		var playerPos = ply.get_global_body_position();
		var selfPos = this.get_node("Body").get_global_position();
		var posDiff = playerPos - selfPos;
		
		#print(posDiff.length())
		
		#print("PLAYERPOS ", playerPos);
		
		if posDiff.length() > CHARGEDIST:
			var normalized = posDiff.normalized();
			return Vector2(normalized.x, normalized.z) * REGULARSPEED;
		elif curTime > chargeCooldownTimer:
			if !lockonPath:
				var normalized = posDiff.normalized();
				lockonPath = Vector2(normalized.x, normalized.z);
				
			return lockonPath * CHARGESPEED;
			
		else:
			return Vector2(0, 0);
			
	return Vector2(0, 0);
		
func _on_collision(other):
	var this = self.get_parent()
	if !other.is_in_group("WorldFloor"):
		lockonPath = null;
		chargeCooldownTimer = Time.get_ticks_msec() + CHARGECOOLDOWN * 1000;
	
