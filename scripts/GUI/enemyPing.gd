extends Control

class_name EnemyPing;

@export var combatHandler : CombatHandler;
@export var thisBotBody : RigidBody3D;
var updateTimer := 0.05;
var targetPos := Vector2(0,0);
var playerInRange := false;
var viewportRect : Rect2;
var initialized := false;
var pingHidden:= false;

func _ready():
	$Texture.modulate.a = 0.0;
	$Label.modulate.a = 0.0;

func _process(delta):
	if is_instance_valid(thisBotBody):
		updateTimer -= delta;
		var health = (floor(combatHandler.health * 100)) / int(100)
		$Label.text = str(health);
		if combatHandler.invincible:
			TextFunc.set_text_color($Label, "ff6e49");
		else:
			TextFunc.set_text_color($Label, "grey");
		if initialized:
			if updateTimer > 0:
				pass;
			else:
				update();
			position = lerp(position, targetPos, delta * 20)
			position.x = clamp(position.x, 16, viewportRect.size.x - 32)
			position.y = clamp(position.y, 16, viewportRect.size.y - 32)
			if not pingHidden:
				if playerInRange:
					$Texture.modulate.a = move_toward($Texture.modulate.a, 0.0, delta * 10);
					$Label.modulate.a = move_toward($Label.modulate.a, 0.75, delta * 10);
				else:
					$Texture.modulate.a = move_toward($Texture.modulate.a, 1.0, delta * 10);
					$Label.modulate.a = move_toward($Label.modulate.a, 0.0, delta * 10);
			else:
				$Texture.modulate.a = move_toward($Texture.modulate.a, 0.0, delta * 10);
				$Label.modulate.a = move_toward($Label.modulate.a, 0.0, delta * 10);
		else:
			update();
			position = targetPos;
			position.x = clamp(position.x, 16, viewportRect.size.x - 32)
			position.y = clamp(position.y, 16, viewportRect.size.y - 32)
			initialized = true;
	else:
		thisBotBody = get_parent().body;

func update():
	viewportRect = get_viewport_rect()
	if viewportRect:
		var pos = thisBotBody.global_position
		if ! GameState.is_player_in_range(pos, 10):
			playerInRange = false;
		else:
			playerInRange = true;
		updateTimer += 0.05;
		var cam = GameState.get_camera();
		if cam.is_position_in_frustum(pos):
			pingHidden = false;
			var camPos = GameState.cam_unproject_position(pos)
			if camPos.x < 0:
				camPos.x = 0;
			targetPos = camPos + Vector2(-8, -32);
		else:
			pingHidden = true;
