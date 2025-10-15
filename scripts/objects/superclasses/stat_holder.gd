extends FreezableEntity

##This entity can have stats saved within it.
class_name StatHolder3D

@export_category("Stats")
#@export var statCollection : Array[StatTracker] = []
@export var statCollection : Dictionary[String,StatTracker] = {}

var statIconCooldown = preload("res://graphics/images/HUD/statIcons/cooldownIconStriped.png");
var statIconMagazine = preload("res://graphics/images/HUD/statIcons/magazineIconStriped.png");
var statIconEnergy = preload("res://graphics/images/HUD/statIcons/energyIconStriped.png");
var statIconDamage = preload("res://graphics/images/HUD/statIcons/damageIconStriped.png");
var statIconWeight = preload("res://graphics/images/HUD/statIcons/weightIconStriped.png");

@export var filepathForThisEntity : String;
var statHolderID := -1;

func _ready():
	super();
	clear_stats();
	stat_registry();

func clear_stats():
	if statCollection.size() > 0:
		print_rich("[color=red]Stat collection is NOT empty at start.")
		print_all_stats();
	statCollection.clear();
	nonexistentStats.clear();

func regenerate_stats():
	clear_stats();
	stat_registry();

##Gets a named stat from the stat collection. Optional rounding mode override.
func get_stat(statName : String, roundModeOverride := StatTracker.roundingModes.NoOverride):
	var stat = get_stat_resource(statName);
	if stat != null:
		if roundModeOverride != StatTracker.roundingModes.NoOverride:
			return stat.get_stat(roundModeOverride);
		else:
			return stat.get_stat();
	return 0.0;
	pass;

var nonexistentStats = []

## Returns the stat's StatTracker resource.[br]
## If the stat given doesn't exist, and it's trying to get that stat, then 
func get_stat_resource(statName : StringName, ignoreNonexistent := false) -> StatTracker:
	if (not ignoreNonexistent) and nonexistentStats.has(stat_name_with_id(statName)):
		return null;
	if statCollection.has(stat_name_with_id(statName)):
		return statCollection[stat_name_with_id(statName)];
	print_rich("[color=orange]Stat ",stat_name_with_id(statName),"does not exist.")
	if (not ignoreNonexistent):
		print_rich("[color=red]Stat ",stat_name_with_id(statName),"being added to the nonexistant list.")
		nonexistentStats.append(stat_name_with_id(statName))
	return null;

func print_all_stats():
	for statName in statCollection.keys():
		var stat = statCollection[statName]
		if stat is StatTracker:
			print("Stat exists:", stat.statName);
	
	pass;

##Gets a stat from the stat collection, then changes its value directly.
func set_stat(statName : String, newValue : float):
	var stat = get_stat_resource(statName);
	if stat != null:
		var modifiedStat = stat.set_stat(newValue);

##Adds the given value numToAdd to the named stat.
func stat_plus(statName : String, numToAdd : float):
	set_stat(statName, get_stat(statName) + numToAdd);

##Subtracts the given value numToSubtract to the named stat by just running stat_plus() in reverse.
func stat_minus(statName : String, numToSubtract : float):
	stat_plus(statName, - numToSubtract);

## Registers new stats. Only ever call this from stat_registry().[br]In the getFunction field, you can define a new function that is called and returned when get_stat() is called.[br]In the setFunction field, you can define a new function that is called when set_stat() is called.[br]Both getFunction and setFunction can be set to null to have them use the default get or set.
func register_stat(statName : String, baseStat : float, statIcon : Texture2D = null, getFunction : Variant = null, setFunction : Variant = null, roundingMode : StatTracker.roundingModes = StatTracker.roundingModes.None):
	print_rich("[color=blue]Creating stat "+stat_name_with_id(statName)+" with value "+str(baseStat)+"[/color]")
	if get_stat_resource(statName, true) == null: #Check if the stat already exists before adding it again.
		var statTracked = StatTracker.new();
		
		
		statTracked.statFriendlyName = statName.capitalize();
		statTracked.statName = stat_name_with_id(statName);
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
		statTracked.resource_name = stat_name_with_id(statName);
		statTracked.statID = GameState.get_unique_stat_id();
		statCollection[stat_name_with_id(statName)] = statTracked;
	else:
		print_rich("[color=red]stat"+statName+"already exists...")
		pass

func add_multiplier(statName : StringName):
	var stat = get_stat_resource(statName);
	
	pass;

## Where any and all register_stat() or related calls should go. Runs at _ready().
func stat_registry():
	pass;

func set_stat_holder_id():
	statHolderID = GameState.get_unique_stat_holder_id();
	pass

func get_stat_holder_id():
	if statHolderID == -1:
		set_stat_holder_id();
	return statHolderID;

func stat_name_with_id(statName):
	return statName + str(get_stat_holder_id());
