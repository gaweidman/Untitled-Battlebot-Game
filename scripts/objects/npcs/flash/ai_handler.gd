extends Node3D
var lockonPath;
var chargeCooldown = 0;

func ready():
	pass
	
func get_movement_vector():
	var ply = GameState.get_player();
	
	if ply && Time.get_ticks_msec() > chargeCooldown:
		var this = self.get_parent()
		var playerPos = ply.get_position();
		var selfPos = this.get_position();
		var posDiff = selfPos - playerPos
		
		if posDiff.length() > this.chargeDistance:
			var normalized = posDiff.normalized();
			return Vector2(normalized.x, normalized.z) * this.regularSpeed;
		else:
			if !lockonPath:
				var normalized = posDiff.normalized();
				lockonPath = Vector2(normalized.x, normalized.z);
			
			return lockonPath * this.chargeSpeed;
			
func _on_collision(other):
	var this = self.get_parent()
	if other.is_in_group("WorldWall"):
		lockonPath = null;
		chargeCooldown = Time.get_ticks_msec() + this.chargeCooldown * 1000;
	
