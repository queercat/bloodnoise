shader_type spatial;
render_mode depth_prepass_alpha;

varying vec3 world_vertex;

uniform int sphere_data_length;
uniform vec4 sphere_data[64];
uniform vec4 sphere_attributes_data[64];

void vertex() {
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float alpha = 0.;
	
	for (int idx = 0; idx < sphere_data_length; idx++) {
		vec4 sphere_datum = sphere_data[idx];
		vec4 sphere_attribute_datum = sphere_attributes_data[idx];
		
		float dist = length(sphere_datum.xyz - world_vertex);
		
		alpha += dist <= sphere_datum.w ? 1. : 0.;
	}

	// sampling some noise instead of 0.5 may look better
	if (alpha < 0.5) {
		discard;
	}
	
	ALBEDO = vec3(1., 1., 1.);
}