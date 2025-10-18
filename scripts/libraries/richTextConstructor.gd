extends Resource

class_name RichTextConstructor

@export_multiline var string : String = ""; ##The set of characters this will append.
@export_subgroup("Options")
@export var color : TextFunc.textColorsEnum = TextFunc.textColorsEnum.grey; ##The color of the font for this set of characters.
@export var newline : bool = false; ##Adds a newline before this string.
@export var endingSpace : bool = false; ##Adds a space to the end of the string if there isn't already one.
@export var startingSpace : bool = true; ##Adds a space to the start of the string if the first character of this string and the last character of the current string are both alphanumeric.[br]This effectively prevents spaces being added before punctuation or if there's already a space after the last string.[b]For example, this prevents a space being added before a RichTextConstructor containing a single "." just with a different font color.
