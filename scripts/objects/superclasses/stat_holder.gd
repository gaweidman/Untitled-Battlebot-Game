extends FreezableEntity

##This entity can have stats saved within it.
class_name StatHolder3D

@export_category("Stats")
@export var statCollection : Array[StatTracker] = []

var statIconCooldown = preload("res://graphics/images/HUD/statIcons/cooldownIconStriped.png");
var statIconMagazine = preload("res://graphics/images/HUD/statIcons/magazineIconStriped.png");
var statIconEnergy = preload("res://graphics/images/HUD/statIcons/energyIconStriped.png");
var statIconDamage = preload("res://graphics/images/HUD/statIcons/damageIconStriped.png");

func _ready():
	stat_registry();

##Gets a named stat from the stat collection. Optional rounding mode override.
func get_stat(statName : StringName, roundModeOverride := StatTracker.roundingModes.NoOverride):
	var stat = get_stat_resource(statName);
	if stat != null:
		if roundModeOverride != StatTracker.roundingModes.NoOverride:
			return stat.get_stat(roundModeOverride);
		else:
			return stat.get_stat();
	return null;
	pass;

func get_stat_resource(statName : StringName):
	for stat in statCollection:
		if stat.statName == statName:
			return stat;
	return null;

##Gets a stat from the stat collection.
func set_stat(statName : StringName, newValue : float):
	var stat = get_stat_resource(statName);
	if stat != null:
		var modifiedStat = stat.set_stat(newValue);

##Adds the given value numToAdd to the named stat.
func stat_plus(statName : StringName, numToAdd : float):
	set_stat(statName, get_stat(statName) + numToAdd);

##Subtracts the given value numToSubtract to the named stat by just running stat_plus() in reverse.
func stat_minus(statName : StringName, numToSubtract : float):
	stat_plus(statName, - numToSubtract);

## Registers new stats. Only ever call this from stat_registry().[br]In the getFunction field, you can define a new function that is called and returned when get_stat() is called.[br]In the setFunction field, you can define a new function that is called when set_stat() is called.[br]Both getFunction and setFunction can be set to null to have them use the default get or set.
func register_stat(statName : StringName, baseStat : float, statIcon : Texture2D = null, getFunction : Variant = null, setFunction : Variant = null, roundingMode : StatTracker.roundingModes = StatTracker.roundingModes.None):
	if get_stat_resource(statName) == null: #Check if the stat already exists before adding it again.
		var statTracked = StatTracker.new();
		
		statTracked.statName = statName;
		statTracked.statIcon = statIcon;
		statTracked.baseStat = baseStat;
		statTracked.currentValue = baseStat;
		statTracked.roundingMode = roundingMode;
		if statIcon != null and statIcon is Texture2D:
			statTracked.statIcon = statIcon;
		if getFunction != null and getFunction is Callable:
			statTracked.getFunc = getFunction;
		if setFunction != null and setFunction is Callable:
			statTracked.setFunc = setFunction;
		statTracked.resource_name = statName;
		statTracked.statID = GameState.get_unique_stat_id();
		statCollection.append(statTracked);

func add_multiplier(statName : StringName):
	var stat = get_stat_resource(statName);
	
	pass;

## Where any and all register_stat() or related calls should go. Runs at _ready().
func stat_registry():
	pass;
