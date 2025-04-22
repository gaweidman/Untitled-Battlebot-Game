extends Node3D

class_name AIHandlerFlash

var lockonPath;
var chargeCooldownTimer := 0.25;
var chargeTimeTimer := 0.0;

var REGULARSPEED = 40000;
var CHARGESPEED = 150000;
var CHARGEDIST = 7.5;
var RUNDIST = 7.0;
var CHARGECOOLDOWN = 2.5;
var CHARGETIME = 2.0;

func ready():
	pass

func _process(delta):
	if chargeCooldownTimer > 0:
		chargeCooldownTimer -= delta;
	if chargeTimeTimer > 0:
		chargeTimeTimer -= delta;
	else:
		if lockonPath != null:
			stop_charge();

func get_movement_vector():
	var ply = GameState.get_player();
	
	var curTime = Time.get_ticks_msec();
	
	#print(curTime)
	
	
	if ply:
		var this = self.get_parent()
		var playerPos = ply.get_global_body_position();
		var selfPos = this.get_node("Body").get_global_position();
		var posDiff = playerPos - selfPos;
		
		#print(posDiff.length())
		
		#print("PLAYERPOS ", playerPos);
		if chargeCooldownTimer <= 0 and not self.get_parent().is_asleep():
			if !lockonPath:
				var normalized = posDiff.normalized();
				lockonPath = Vector2(normalized.x, normalized.z);
				chargeTimeTimer = CHARGETIME;
				pass;
			else:
				return lockonPath * CHARGESPEED;
		
		
		if posDiff.length() > CHARGEDIST:
			var normalized = posDiff.normalized();
			return Vector2(normalized.x, normalized.z) * REGULARSPEED;
		elif posDiff.length() < RUNDIST:
			var normalized = posDiff.normalized();
			return Vector2(normalized.x, normalized.z) * -REGULARSPEED;
			
	return Vector2(0, 0);

func _on_collision(this, other):
	#var this = self.get_parent()
	if !other.is_in_group("WorldFloor"):
		stop_charge();

func stop_charge():
	lockonPath = null;
	chargeCooldownTimer = CHARGECOOLDOWN;
