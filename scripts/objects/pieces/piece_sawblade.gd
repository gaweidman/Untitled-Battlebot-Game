extends Piece_Weapon

class_name Piece_Sawblade

@export var baseRotationSpeed := 270.0;
var rotationSpeed := baseRotationSpeed;
var rotationDeg := 0.0;
@export var sawSoundPlayer : AudioStreamPlayer3D;
var sawSoundVolume := 0.0;
var sawSoundPitch := 1.0;
var snd : SND;

@export var blade : MeshInstance3D;


func stat_registry():
	super();

func add_rotation(deg):
	rotationDeg += deg;
	if deg >= 360:
		deg -= 360;

func ability_registry():
	register_active_ability("Deflect", "Spin the sawblade with extreme speed, causing it to deflect projectiles and deal extra damage.", func (): pass)

func phys_process_abilities(delta):
	super(delta);
	#print(can_use_passive())
	if can_use_passive():
		rotationSpeed = lerp(rotationSpeed, baseRotationSpeed, delta * 4);
		pass;
	else:
		rotationSpeed = lerp(rotationSpeed, 0.0, delta * 4);
		pass;
	add_rotation(rotationSpeed * delta);

func process_draw(delta):
	super(delta);
	blade.rotation.y = deg_to_rad(rotationDeg);

func contact_damage(robot : Robot):
	if can_use_passive():
		robot.take_damage(get_damage());
		robot.take_knockback(get_knockback(robot.position));
	pass;

func deflect():
	pass;
