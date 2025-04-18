shader_type canvas_item;

//Taken from this tutorial: 
//https://www.youtube.com/watch?v=dMzXXqO8kWw&ab_channel=yokcos

uniform sampler2D mask;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	
	vec2 muv = UV;
	//muv.y = 1.0 - muv.y;
	
	COLOR.a = texture(mask, muv).r;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
