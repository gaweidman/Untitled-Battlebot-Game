extends Node


func format_stat(num:float, decimals:int=2, addSpaces := true) -> String:
	var s = str(int(num))
	var sLength = s.length();
	var targetLength = sLength + decimals + 1; ## The amount of numbers without the decimals, then the amount of decimals, then the literal decimal "." .
	if decimals <= 0:
		return str(int(round_to_dec(num, 0)));
	else:
		s = str(round_to_dec(num, decimals))
		if addSpaces:
			while s.length() < targetLength:
				s += " ";
		return s;

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

# Colors for text.
enum textColorsEnum {
	white,
	grey,
	utility,
	lightgreen,
	ranged,
	lightblue,
	melee,
	lightred,
	scrap,
	red,
	unaffordable,
	inaffordable,
	outline
}
const textColors = {
	"white" : Color("ffffff"),
	"grey" : Color("e0dede"),
	"utility" : Color("aae05b"),
	"lightgreen" : Color("aae05b"),
	"ranged" : Color("789be9"),
	"lightblue" : Color("789be9"),
	"melee" : Color("ff6e49"),
	"lightred" : Color("ff6e49"),
	"scrap" : Color("f2ec6b"),
	"red" : Color("cf2121"),
	"unaffordable" : Color("ff0000"),
	"inaffordable" : Color("ff0000"),
	"outline" : Color("240e0e"),
}

## Recolors a Label or RichTextLabel or TextEdit or anythign else of the sort with [method Label.theme_override_colors/font_color].
func set_text_color(node, _color):
	if is_instance_valid(node) and "theme_override_colors/font_color" in node:
		#print("Thing in thing")
		var color = get_color(_color);
		if node.get("theme_override_colors/font_color") != color:
			print("color for ",node, " being set from: ", node.get("theme_override_colors/font_color"), "to: ",color);
			node.set_deferred("theme_override_colors/font_color", color);

## Returns a predefined color from [member textColors] if given a String key, or returns a given Color input as-is. Returns Color.WHITE if the input is not a String or Color.
func get_color(_color) -> Color:
	if _color is textColorsEnum: ##Get the string from the enum name.
		_color = textColorsEnum.keys()[_color];
	if _color is Color:
		return _color;
	if _color is String:
		var newCol := Color(textColors["white"]);
		if _color in textColors:
			newCol = Color(textColors[_color]);
		else:
			newCol = Color(_color);
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


const alphanumericCharacters = [
	"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"
]
func last_char_is_alphanumeric(base : String):
	if base.length() == 0: return false;
	var last_char = base[base.length() - 1];
	return last_char in alphanumericCharacters or last_char.capitalize() in alphanumericCharacters;
func first_char_is_alphanumeric(base : String):
	if base.length() == 0: return false;
	var first_char = base[0];
	return first_char in alphanumericCharacters or first_char.capitalize() in alphanumericCharacters;

#### STRING CONSTRUCTOR

func parse_text_constructor_array(input : Array[RichTextConstructor]):
	var count = 0;
	var string;
	for constructor in input:
		count += 1;
		string = parse_text_constructor(constructor, count == 1, count == input.size());
	if string is String:
		#print_rich("FINAL STRING: "+string)
		return string;
	else:
		#print_rich("FINAL STRING DID NOT GO THROUGH")
		return "[color=red]ERROR!"

func parse_text_constructor(constructor : RichTextConstructor, start : bool, end : bool):
	#print("STRING IS STARTING: "+str(start))
	var base = get_stored_rich_string();
	## Newline. Adds a newline character before the appending string, if it is not the first line.
	if base.length() > 0:
		if constructor.newline: add_to_rich_string(false,"\n", null);
	##Starting space. Only runs if the last character of the constructed string, and the first character of the upcoming string, are both alphanumerical.
	if first_char_is_alphanumeric(constructor.string) and last_char_is_alphanumeric(base) and constructor.startingSpace:
		add_to_rich_string(false," ", null);
	add_to_rich_string(start, constructor.string, constructor.color);
	var new = get_stored_rich_string();
	##End space. Only if the last character is not already a space.
	if base.length() > 0:
		var last_char = base[base.length() - 1];
		if last_char != " ":
			if constructor.endingSpace: add_to_rich_string(false," ", null);
	## Return the result at the end of the array.
	if end: return get_stored_rich_string();

var storedString := "";

func get_stored_rich_string() -> String:
	return storedString;

func add_to_rich_string(start := false, append : String = "", _colorGet = get_color("white")):
	if start: 
		clear_rich_string_construction();
	var baseString = get_stored_rich_string();
	var color = get_color(_colorGet);
	var newString = "";
	if _colorGet != null:
		newString = "[color=" + color.to_html() + "]"
	newString += append;
	var endString = baseString + newString
	#print_rich("CONTRUCTED STRING THUS FAR: "+endString)
	storedString = endString;
	return endString;

func clear_rich_string_construction():
	storedString = "";

func get_final_rich_string():
	var ret = get_stored_rich_string();
	clear_rich_string_construction();
	#print_rich("FINAL STRING:" + ret)
	return ret;
