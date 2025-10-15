extends Piece

class_name Piece_Sawblade

@export var baseRotationSpeed := 270.0;
var rotationSpeed := baseRotationSpeed;
var rotationDeg := 0.0;
@export var sawSoundPlayer : AudioStreamPlayer3D;
var sawSoundVolume := 0.0;
var sawSoundPitch := 1.0;
var snd : SND;
var bladeScaleOffset := 1.0;

@export var blade : MeshInstance3D;

func stat_registry():
	super();

func add_rotation(deg):
	rotationDeg += deg;
	if deg >= 360:
		deg -= 360;

func ability_registry():
	register_active_ability("Deflect", "Spin the sawblade with extreme speed, causing it to deflect projectiles and deal extra damage.", func (): deflect())

func phys_process_timers(delta):
	super(delta);
	bladeScaleOffset = lerp(bladeScaleOffset, 1.0, delta * 12) 

func phys_process_collision(delta):
	super(delta);
	#if get_cooldown_active() > 0:
		##var maxCooldown = get_stat("CooldownActive");
		##var curCooldown = get_cooldown_active();
		##var ratio = curCooldown / maxCooldown;
		##hitboxCollisionHolder.scale
	hitboxCollisionHolder.scale = Vector3.ONE * bladeScaleOffset;
	#else:
		#hitboxCollisionHolder.scale = Vector3.ONE;

func phys_process_abilities(delta):
	super(delta);
	#print(can_use_passive())
	if can_use_passive() and not on_cooldown():
		rotationSpeed = lerp(rotationSpeed, baseRotationSpeed, delta * 4);
		pass;
	else:
		rotationSpeed = lerp(rotationSpeed, 0.0, delta * 4);
		pass;
	add_rotation(rotationSpeed * delta);

func process_draw(delta):
	super(delta);
	blade.rotation.y = deg_to_rad(rotationDeg);
	blade.scale = Vector3.ONE * bladeScaleOffset;

func contact_damage(otherPiece : Piece, otherPieceCollider : PieceCollisionBox, thisPieceCollider : PieceCollisionBox):
	if can_use_passive() and not on_cooldown():
		if super(otherPiece, otherPieceCollider, thisPieceCollider):
			set_cooldown_passive();
			bladeScaleOffset /= 1.5;
	pass;

func cooldown_behavior_active(onCooldown : bool = on_cooldown_active()):
	hitboxCollisionHolder.scale.lerp(Vector3.ONE * bladeScaleOffset, get_physics_process_delta_time() * 12)
	pass;

func cooldown_behavior(onCooldown : bool = on_cooldown()):
	pass;

func deflect():
	bladeScaleOffset *= 2;
	rotationSpeed *= 3;
	#$ShapeCast3D.enabled = true;
	#$Timer.start();
	damageModifier *= 3;
	sawSoundPitch = 0.9;
	sawSoundVolume = 1.0;
	get_host_robot().set_invincibility(0.25);
	pass;
