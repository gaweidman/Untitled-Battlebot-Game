extends Node


func format_stat(num:float, decimals:int=2) -> String:
	if decimals <= 0:
		return str(int(round_to_dec(num, 0)));
	else:
		return str(round_to_dec(num, decimals));

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)


# Colors for text.
const textColors = {
	"white" : Color("ffffff"),
	"grey" : Color("e0dede"),
	"utility" : Color("aae05b"),
	"ranged" : Color("789be9"),
	"melee" : Color("ff6e49"),
	"scrap" : Color("f2ec6b"),
	"red" : Color("cf2121"),
	"unaffordable" : Color("ff0000"),
	"inaffordable" : Color("ff0000"),
	"outline" : Color("240e0e"),
}

## Recolors a Label or RichTextLabel or TextEdit or anythign else of the sort with [method Label.theme_override_colors/font_color].
static func set_text_color(node, color):
	if is_instance_valid(node) and node.has_method("theme_override_colors/font_color"):
		color = get_color(color);
		if node.get("theme_override_colors/font_color") != color:
			node.set_deferred("theme_override_colors/font_color", color);

## Returns a predefined color from [member textColors] if given a String key, or returns a given Color input as-is. Returns Color.WHITE if the input is not a String or Color.
static func get_color(color) -> Color:
	if color is Color:
		return color;
	if color is String:
		var newCol := Color(textColors["white"]);
		if color in textColors:
			newCol = Color(textColors[color]);
		else:
			newCol = Color(color);
		return newCol;
	return Color.WHITE;

## Returns a string to be used for stats.
func format_stat_num(_inNum, decimals : int = 2) -> String:
	var factor = 10^decimals;
	var inNum = (floor(_inNum*factor))/factor
	
	var outString = ""
	if inNum >= 10:
		outString = str(inNum);
	else:
		outString = " " + str(inNum);
	
	if outString.length() < 5:
		outString += "0";
	return outString;

func format_time(_time:float):
	var minutes = 0;
	var seconds = floori(_time)
	while seconds > 60:
		seconds -= 60;
		minutes += 1;
	minutes = min(99,minutes);
	seconds = min(60,max(0,seconds));
	var minuteString = "00"
	if minutes < 10 && minutes > 0:
		minuteString = "0" + str(minutes)
	elif minutes >= 10:
		minuteString = str(minutes)
	
	var secondString = "00"
	if seconds < 10 && seconds > 0:
		secondString = "0" + str(seconds)
	elif seconds >= 10:
		secondString = str(seconds)
	
	return minuteString + ":" + secondString;

func flyaway(textToDisplay, globalPosition : Vector3, color, color_outline := textColors["outline"]):
	var brd = GameState.get_game_board();
	if is_instance_valid(brd):
		color = get_color(color);
		color_outline = get_color(color_outline);
		var newFly = Flyaway.new();
		newFly.text = str(textToDisplay);
		newFly.modulate = color;
		newFly.outline_modulate = color_outline;
		brd.add_child(newFly);
		newFly.global_position = globalPosition;
		newFly.initPosY = globalPosition.y;
		newFly.show();
