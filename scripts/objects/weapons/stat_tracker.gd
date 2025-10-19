extends Resource

##A resource used for keeping track of stats on Parts and Pieces.
class_name StatTracker

@export var statFriendlyName : String;
@export var statName : String;
var statID : int;
@export var statIcon : Texture2D = preload("res://graphics/images/HUD/statIcons/magazineIconStriped.png");
var textColor := TextFunc.get_color("lightblue");
@export var baseStat : float;
var currentValue : float;
var bonusAdd : float = 0.0; ##Adds this value to baseStat.
var bonusMult_Flat : float = 0.0; ##Multiplies the total value after baseStat + bonusAdd.
var bonusMult_Mult : float = 1.0; ##Multiplies bonusMult_Flat by this number before multiplying.
enum roundingModes {
	None,
	Floor,
	Round,
	Ceil,
	Floori,
	Roundi,
	Ceili,
	NoOverride,
}
@export var roundingMode := roundingModes.None; ##Keeps track of the current [enum roundingModes] value.[br][br][enum roundingMode.None] means no modifications to the number when getting it; it will remain an unrounded [float]. [br][enum roundingMode.Floor], [enum roundingMode.Round], and [enum roundingMode.Ceil] will perform those mathematic functions on the number, to the appropriate nearest [float].[br][enum roundingMode.Floori], [enum roundingMode.Roundi], and [enum roundingMode.Ceili] will perform those mathematic functions on the number, to the appropriate nearest [int]. [br][enum roundingMode.NoOverride] is used in the StatHolder register_stat() function as a default value; should not be used as the rounding mode, but will behave the same as [enum roundingMode.None].

##This [StatTracker]'s get function.
var getFunc := func (): var stat : float = (currentValue + bonusAdd)  * (((1.0 + bonusMult_Flat) * bonusMult_Mult)); return stat;
##This [StatTracker]'s set function.
var setFunc := func (newValue): return newValue;

var additions = []

##Gets the current rounding mode.
func get_rounding_mode() -> roundingModes:
	return roundingMode;

##Gets the stat by calling its get function (getFunc)
func get_stat(roundingModeOverride : roundingModes = get_rounding_mode()):
	var stat = getFunc.call();
	#currentValue = return_rounded_stat(stat, roundingModeOverride);
	#return currentValue;
	#print("getting ", statName, " ", stat)
	return stat;

##Rounds the stat according to the current rounding mode.
func return_rounded_stat(stat, roundingModeOverride : roundingModes = roundingMode):
	match roundingModeOverride:
		roundingModes.Floor:
			return floorf(stat);
		roundingModes.Round:
			return roundf(stat);
		roundingModes.Ceil:
			return ceilf(stat);
		roundingModes.Floori:
			return floori(stat);
		roundingModes.Roundi:
			return roundi(stat);
		roundingModes.Ceili:
			return ceili(stat);
		roundingModes.None: ##Both None and NoOverride should return just the base value without any rounding.
			return stat;
		roundingModes.NoOverride: ##Both None and NoOverride should return just the base value without any rounding.
			return stat;
	return stat;

##Sets the stat by calling [param setFunc].
func set_stat(newValue):
	#print(is_instance_valid(setFunc))
	if (! is_queued_for_deletion()
	 #and is_instance_valid(setFunc)
	and is_instance_valid(self)
	):
		#prints(get_reference_count())
		#print(setFunc)
		#prints("Stat",statName,"was set properly.")
		currentValue = setFunc.call(newValue);
		
	#print( get_property_list())

func get_stat_path():
	if statID == null:
		statID = GameState.get_unique_stat_id();
	return "user://stats/"+statName+"_"+str(statID)+".res";

func register_bonus():
	pass;
