shader_type spatial;
varying vec3 world_vertex;

render_mode depth_prepass_alpha;

uniform float uv_scale = 1.;

uniform vec3 character_position;
uniform float fade_distance;

uniform sampler2D albedo: source_color;
uniform sampler2D roughness: source_color;
uniform sampler2D normal: source_color;
uniform sampler2D fall_off_gradient: repeat_disable;

float map_range(float value, float from_min, float from_max, float to_min, float to_max) {
	float r = from_max - from_min;
	float a = (clamp(value, from_min, from_max) - from_min) / r;
	float b = (to_max - to_min) * a + to_min;
	
	return b; 
}

void vertex() {
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float character_distance = length(character_position - world_vertex);
	float alpha_a = map_range(character_distance, 0., fade_distance, 0., 1.);
	float alpha = 1. - texture(fall_off_gradient, vec2(alpha_a, 0.)).x;
	vec2 offset_uv = UV * uv_scale;
	ALBEDO = texture(albedo, offset_uv).rgb;
	// ALBEDO = vec3(alpha, alpha, alpha);
	METALLIC = 1.;
	ROUGHNESS = 1.;
	NORMAL_MAP = texture(normal, offset_uv).rgb;
	ALPHA = alpha;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
