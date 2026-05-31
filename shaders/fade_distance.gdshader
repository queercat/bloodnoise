shader_type spatial;
render_mode depth_prepass_alpha;
uniform vec3 character_position;
uniform float fade_distance;

varying vec3 world_vertex;

uniform vec4 color: source_color = vec4(0.94, 0.54, 0.15, 1.0);
void vertex() {
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
// Calculate the distance between the fragment and the character
	float character_distance = length(character_position - world_vertex);
    
// Calculate the alpha value based on the distance
	float alpha = smoothstep(0.0, fade_distance, character_distance);
	ALBEDO = vec3(color.r, color.g, color.b);
	ALPHA = alpha;
	NORMAL_MAP = vec3(1. - alpha, 1. - alpha, 1.  - alpha);

	//if (alpha <= 0.0) {
		//discard;
	//}
}