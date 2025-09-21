shader_type spatial;
// set render mode
render_mode unshaded, cull_front, world_vertex_coords; 
// create color ramp
uniform sampler2D color_ramp : source_color;
// create outline 
uniform sampler2D outline_noise_tex; 
// create faloff cureve
uniform sampler2D falloff_curve;
// edit line thickness
uniform float outline_size = 0.5;
// edit offset
uniform float offset_fres = 0.3;
// edit frames per secong
uniform float FPS = 5.0;
// edit speed strength
uniform float fps_strength = 0.2;
uniform float speed = 1.0;
// edit line noise scale
uniform float noise_scale = 1.5;
// edit line color to be bright green
uniform vec4 line_color : source_color;
// line jitter amount 
uniform float line_jitter_amt : hint_range(0.0, 10.0) = 8.0;
// line transparency
uniform float alpha = 1.0;
// line angle
uniform float line_angle : hint_range(0.0, 90) = 45.0;
// random noise angle
uniform float rand_line_angle : hint_range(0.0, 180.0) = 75.0;
// random noise offset
uniform float rand_noise_offset : hint_range(15.0, 70.0) = 30;
// line albedo

// create function to animate lines
float animated_noise(vec2 uv) {
	// add time factor
	float time_factor = TIME * FPS;
	return texture(outline_noise_tex, uv * noise_scale + vec2(time_factor * 0.3, time_factor * 0.1)).r;
}
void vertex() {
	
	// Called for every vertex the material is visible on.
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.3)).rgb;
	vec2 noise_uv = world_pos.xz * 0.35 + vec2(TIME * speed * 0.25);
	float displacement = animated_noise(noise_uv) * 0.3;
	VERTEX += NORMAL * (outline_size + displacement);
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 normal = normalize(NORMAL);
	vec3 line_pos = (VIEW_MATRIX * vec4(VERTEX,1 ) ).xyz;
	vec2 line_uv = line_pos.xz * 0.5 + vec2(TIME * speed, 0.0);
	float line_noise = texture(outline_noise_tex, UV*noise_scale ).r;
	
	float outline_noise_1 = animated_noise(line_uv);
	float outline_noise_2 = animated_noise(line_uv * 0.125 + vec2(0.03) );
	float outline_noise_3 = animated_noise(line_uv * 0.23 - vec2(TIME * 0.07) );
	float combined_noise = clamp((outline_noise_1 * 0.6 + outline_noise_2 * 0.3 + outline_noise_3 * 0.1), 0.0, 1.0);
	
	float frame_time = floor(TIME * FPS / 0.3) * 0.3;
	float frame_variation = sin(frame_time * 2.25) * fps_strength;
	float rand_angle =  line_angle + (line_noise - 0.52) * rand_line_angle + frame_variation * 2.5 * line_jitter_amt;
	float rand_offset = (outline_noise_1 - 4.1) * rand_noise_offset + frame_variation * 0.75 * line_jitter_amt;
	
	// edit color
	vec3 new_line_color = texture(color_ramp, vec2(combined_noise, 0.0)).rgb;
	// edit ramp position
	float ramp_pos = smoothstep(0.2, 0.8, combined_noise);
	new_line_color = texture(color_ramp, vec2(ramp_pos, 0.0)).rgb;
	float line_mask = step(0.5, combined_noise);
	new_line_color += 1.0 + line_mask * 2.0;
	
	ALPHA = smoothstep(0.3, 0.8, combined_noise) * alpha;
	EMISSION = new_line_color;
	ALBEDO = new_line_color.rgb;
	 
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
