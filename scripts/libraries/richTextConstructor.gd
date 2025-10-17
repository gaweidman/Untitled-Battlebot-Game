extends Resource

class_name RichTextConstructor

@export_multiline var string : String = ""; ##The set of characters this will append.
@export var color : TextFunc.textColorsEnum = TextFunc.textColorsEnum.grey; ##The color of the font for this set of characters.
@export var newline : bool = false; ##Adds a newline before this string.
@export var endingSpace : bool = false; ##Adds a space to the end of the string if there isn't already one.
@export var startingSpace : bool = true; ##Adds a space to the start of the string if there isn't already one, and only if the first character is alphanumeric.
