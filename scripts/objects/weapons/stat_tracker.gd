extends Resource

##A resource used for keeping track of stats on Parts and Pieces.
class_name StatTracker

@export var statName : String;
@export var statIcon : Texture2D = preload("res://graphics/images/HUD/statIcons/magazineIconStriped.png");
@export var baseStat : float = 0.0;
var currentValue : float = baseStat;
var bonusAdd : float = 0.0; ##Adds this value to baseStat.
var bonusMult_Flat : float = 0.0; ##Multiplies the total value after baseStat + bonusAdd.
var bonusMult_Mult : float = 1.0; ##Multiplies bonusMult_Flat by this number before multiplying.
enum roundingModes {
	None,
	Floor,
	Round,
	Ceil,
	NoOverride,
}
@export var roundingMode := roundingModes.None; ## Float means no modifications to the number when getting. Floor, Round, and Ceil will perform those mathematic functions on the number. NoOverride is used in the StatHolder register_stat() function as a default value; should not be used as the rounding mode.

##This StatTracker's get function.
var getFunc := func (): var stat = (baseStat + bonusAdd)  * (((1 + bonusMult_Flat) * bonusMult_Mult)); return stat;
##This StatTracker's set function.
var setFunc := func (newValue): return newValue;

##Gets the stat by calling its get function (getFunc)
func get_stat(roundingModeOverride : roundingModes = roundingMode):
	var stat = getFunc.call();
	currentValue = return_rounded_stat(stat, roundingModeOverride);
	return currentValue;

##Rounds the stat according to the current rounding mode.
func return_rounded_stat(stat, roundingModeOverride : roundingModes = roundingMode):
	match roundingModeOverride:
		roundingModes.Floor:
			return floori(stat);
		roundingModes.Round:
			return roundi(stat);
		roundingModes.Ceil:
			return ceili(stat);
		roundingModes.None: ##Both None and NoOverride should return just the base value without any rounding.
			return stat;
		roundingModes.NoOverride: ##Both None and NoOverride should return just the base value without any rounding.
			return stat;

##Sets the stat by calling its set function (setFunc).
func set_stat(newValue):
	set_deferred("currentValue", setFunc.call(newValue));
