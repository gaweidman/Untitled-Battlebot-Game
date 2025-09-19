shader_type spatial;
// set render mode to unshaded
render_mode unshaded;
// declare variables
// SET SCREEN TEXTURE
uniform sampler2D SCREEN_TEXTURE : source_color, hint_screen_texture, filter_nearest;
uniform sampler2D NORMAL_TEXTURE : source_color, hint_normal_roughness_texture, filter_nearest;
uniform sampler2D depth_texture : source_color, hint_depth_texture, filter_nearest;

vec3 get_orignal(vec2 screen_uv)
{
	return texture(SCREEN_TEXTURE,screen_uv).rgb;
}

vec3 get_normal(vec2 screen_uv)
{
	return texture(NORMAL_TEXTURE, screen_uv).rgb * 2.0 - 1.0;
}
void vertex() {
	// GET OUTLINE 
	POSITION = vec4(VERTEX,1.0);
	
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 original = get_orignal(SCREEN_UV);
	
	// set original
	vec3 normal = get_normal(SCREEN_UV);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
