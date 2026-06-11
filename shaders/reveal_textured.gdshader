shader_type spatial;
varying vec3 world_vertex;
render_mode depth_prepass_alpha;

uniform bool is_enabled = false;
uniform float reveal_band: hint_range(0., 40., 10.);

uniform sampler2D albedo: source_color;
uniform sampler2D normal: source_color;
uniform sampler2D roughness: source_color;

uniform int sphere_data_length;
uniform vec4 sphere_data[64];
uniform vec4 sphere_attributes_data[64];

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

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
	if (is_enabled) {
		float rand_value = random(SCREEN_UV);
		float max_alpha = 0.;
		
		for (int idx = 0; idx < sphere_data_length; idx++) {
			vec4 sphere_datum = sphere_data[idx];
			vec4 sphere_attribute_datum = sphere_attributes_data[idx];
			
			float dist = length(sphere_datum.xyz - world_vertex) - sphere_datum.w;
			float w = map_range(sphere_datum.w, 0., sphere_attribute_datum.w, 0., 1.);
			float wp = map_range(w, .8, 1., 0., 1.);
			dist += rand_value;
			float alpha = dist <= 0. && dist >= -reveal_band * 1. - wp ? 1. : 0.;
			max_alpha = max(alpha, max_alpha);
		}

		// sampling some noise instead of 0.5 may look better
		if (1. - max_alpha < 0.5) {
			discard;
		}
	}
	
	ALBEDO = texture(albedo, UV).rgb;
	NORMAL_MAP = texture(normal, UV).rgb;
	ROUGHNESS = texture(roughness, UV).a;
}