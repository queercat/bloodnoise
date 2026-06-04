shader_type spatial;
render_mode depth_prepass_alpha;

varying vec3 world_vertex;
uniform float reveal_distance: hint_range(0.0, 10.0, 10.0);
uniform int sphere_data_length;
uniform vec4 sphere_data[64];
uniform vec4 sphere_attributes_data[64];

void vertex() {
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

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

void fragment() {
	float alpha = 0.;
	
	float rand_value = random(SCREEN_UV);
	float factor = 0.;
	
	for (int idx = 0; idx < sphere_data_length; idx++) {
		vec4 sphere_datum = sphere_data[idx];
		vec4 sphere_attribute_datum = sphere_attributes_data[idx];
		
		float dist = length(sphere_datum.xyz - world_vertex);
	 	factor += map_range(sphere_datum.w, dist, sphere_attribute_datum.w, 0., 1.);
		
		
		dist += rand_value;
		alpha += dist <= sphere_datum.w && dist >= sphere_datum.w - reveal_distance ? 1. - factor : 0.;
	}
	
	factor = clamp(factor, 0., 1.);

	// sampling some noise instead of 0.5 may look better
	if (alpha < .1 + (factor * rand_value)) {
		discard;
	}
	
	ALBEDO = vec3(1., 1., 1.);
}