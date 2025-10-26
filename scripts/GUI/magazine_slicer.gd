@icon ("res://graphics/images/class_icons/magazine_green.png")
extends HBoxContainer
class_name MagazineSlicer
## Displays a line of [BulletSlice] nodes representing the magazine of a [Piece_Projectile] for use on each [AbilitySlot].

var currentMagSize := -1;
var slices : Array[BulletSlice] = [];
var bulletSliceScene = preload("res://scenes/prefabs/objects/gui/bullet_slice.tscn");
@export var maxSizeX : float = 86.0;
@export var maxSliceSize = 14;
var currentSliceSize = 14;
@export var maxMarginSize = 3;
var currentMarginSize = 1;

func _ready():
	maxSizeX = size.x;
	
	###For Testing.
	#var maxAmt = randi_range(1, 40);
	#var amt = min(maxAmt, randi_range(1, 10));
	#count = amt;
	#update_contents(maxAmt, amt, 0.5, 1);

var count = 0.;
var max = 7.;
var amt = 0.;
func _process(delta):
	###Testing.
	#count += 3 * delta;
	#if count > 1:
		#count -= 1;
		#amt += 1;
		#if amt > max:
			#amt = 0;
	#update_contents(max, amt, count, 1);
	pass;

## Updates the magazine.[br]Evaluates [param currentAmount] and [param cooldownTimeCurrent], then passes them into [method update_contents_percent] as a valid percentage.
func update_contents(magSize:int, currentAmount:int, cooldownTimeCurrent:float, cooldownTimeStart:float):
	if magSize != currentMagSize:
		currentMagSize = magSize;
		fill_to_mag_size();
	
	var percent = (cooldownTimeStart - cooldownTimeCurrent) / cooldownTimeStart;
	update_contents_percent(magSize, currentAmount, percent);
	pass;

## Updates the magazine.[br]All bullets represented are either full or empty, except for the singular bullet directly after the last available one in the magazine, which gets its percentage filled by the bullet refresh cooldown that's been plugged in.
func update_contents_percent(magSize:int, currentAmount:int, cooldownPercent):
	if magSize != currentMagSize:
		currentMagSize = magSize;
		fill_to_mag_size();
	
	var pool = 0.0;
	pool += currentAmount;
	pool += cooldownPercent;
	
	for slice in get_children():
		if slice is BulletSlice:
			var amt = max(0, min(int(1), pool))
			slice.update_percent(amt,1.0, amt == 1)
			pool -= 1.0;
	pass;

## Updates the amount of child [BulletSlice] nodes to represent [member currentMagSize]. Also updates [member size] to match.[br][i]Kinda pricey![/i] Only runs in [method update_contents] and [method update_contents_percent] if the new magazine size does not match the present one.
func fill_to_mag_size():
	## loop over children. If any go over the max, delete.
	var count = 0;
	for child in get_children():
		count += 1;
		if count > currentMagSize:
			child.queue_free();
		else:
			child.size.x = maxSliceSize;
	## Loop over the difference between the previous child count and the current magazine size to add any missing slices.
	var dif = currentMagSize - count;
	for num in dif:
		var newSlice = bulletSliceScene.instantiate();
		newSlice.size.x = maxSliceSize;
		add_child(newSlice);
		pass;
	
	## Add all the slices to the array.
	slices.clear();
	slices.append_array(get_children());
	
	#print (get_widths_of_all_children(currentSliceSize))
	#print("a")
	
	currentSliceSize = maxSliceSize;
	currentMarginSize = maxMarginSize;
	var done = false;
	var currentSize = 0.0;
	var useBar = false;
	while not done:
		var checkSize = get_widths_of_all_children(currentSliceSize + currentMarginSize)
		#prints("Check size...",checkSize)
		if checkSize <= maxSizeX:
			done = true;
			currentSize = checkSize;
		else:
			var minMarginSIze = 1;
			
			if currentSliceSize < 4:
				minMarginSIze = 0;
			
			if currentSliceSize > 2:
				#print("reducing slice");
				if currentMarginSize > minMarginSIze:
					#print("reducing margin");
					currentMarginSize -= 1;
				else:
					currentMarginSize = maxMarginSize;
					currentSliceSize -= 1;
			else:
				if currentMarginSize > 0:
					#print("reducing margin");
					currentMarginSize -= 1;
				else:
					done = true;
			#print(checkSize);
	
	set("theme_override_constants/separation", currentMarginSize);
	size.x = min(currentSize, maxSizeX);

## Returns the potential width of all child [BulletSlice]s, given [param currentSize] is the width each child would be.
func get_widths_of_all_children(currentSize):
	var w = 0;
	for num in currentMagSize:
		var num2 = num + 1;
		w += currentSize;
		#print(num2);
	return w;
