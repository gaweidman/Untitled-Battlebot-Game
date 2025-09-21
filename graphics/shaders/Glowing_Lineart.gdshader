// references : https://godotshaders.com/shader/animated-outline-fireacid/, https://godotshaders.com/shader/clean-pixel-perfect-outline-via-material-3/,https://godotshaders.com/shader/hatching-shader/
shader_type spatial; 
render_mode cull_front, world_vertex_coords, unshaded;
// DECLARE VARIABLES
// declare textures
uniform sampler2D overall_noise_texture : source_color;
uniform sampler2D char_noise : source_color, repeat_enable;
uniform sampler2D color_ramp : source_color, repeat_enable, filter_linear_mipmap;
// edit line color

// declare attributes
// edit line thickness
uniform float char_thickness = 0.4;
// edit line speed
uniform float speed = 0.01;
// edit line noise
uniform float noise_scale = 2.0;
// edit line transparency
uniform float alpha = 1.0;
// edit line angel
uniform float char_angle : hint_range(0,270.0) = 90.0;
// edit line fade
uniform float char_fade : hint_range(0.0, 0.2) = 0.15;
// EDIT RANDOM LINE ATTRIBUTES
// random line thickness
uniform float rand_char_thickness : hint_range(0.2, 2) = 1.75;
// random line offset 
uniform float rand_char_offset : hint_range(0,15) = 12;
// change random line noise scale
uniform float rand_line_scale : hint_range(1,100) = 50;
// change random noise angle
uniform float rand_noise_angle : hint_range(90, 450) = 360;
// EDIT ANIMATED LINES
uniform float fps_speed_strength : hint_range(0.0, 0.5) = 0.45;
uniform float fps_speed : hint_range(0.1, 5) = 0.2;
uniform float char_jitter_amount : hint_range(0.0, 2.5) = 1.6;
uniform float overall_noise_scale : hint_range(0.0, 100) = 75.0;

// animate the noise 
float animated_noise(vec2 uv) {
	float time_factor = TIME * fps_speed;
	return texture(char_noise, uv * noise_scale + vec2(time_factor * 0.6, time_factor * 0.0)).r;
}

void vertex(){
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec2 noise_uv = world_pos.xz * 0.5 + vec2(TIME * speed * 0.2);
    float displacement = animated_noise(noise_uv) * 0.1;
    
    VERTEX += NORMAL * (char_thickness + displacement);
}

void fragment(){
	vec3 normal = normalize(NORMAL);
	
	vec3 char_pos = (VIEW_MATRIX * vec4(VERTEX,1)).xyz;
	vec2 char_uv = char_pos.xz * 0.25 + vec2(TIME * speed, 0.0);

	float char_noise_1 = animated_noise(char_uv);
	float char_noise_2 = animated_noise(char_uv * 2.0+ vec2(0.2));
	float char_noise_3 = animated_noise(char_uv * 0.5 - vec2(TIME * 0.5));
	float combined_noise = clamp((char_noise_1 * 0.6 + char_noise_2 * 0.3 + char_noise_3 * 0.1), 0.0, 1.0);
	
	
	vec3 char_color = texture(color_ramp, vec2(combined_noise, 0.0)).rgb;
	float ramp_pos = smoothstep(0.1, 0.6, combined_noise);
	char_color = texture(color_ramp, vec2(ramp_pos, 0.0)).rgb;
	float char_mask = step(0.5, combined_noise);
	char_color *= 1.0 + char_mask *1.9;
	
	ALPHA = smoothstep(0.2, 0.8, combined_noise) * alpha;
	
	EMISSION = char_color * (1.0 + sin(TIME * 5.0) * 0.24);
	ALBEDO = char_color;

}