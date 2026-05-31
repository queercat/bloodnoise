/* 
Basic sci-fi pulse post-processing effect.
Required to be put on a quad mesh that is rendered in the scene.
Required associated script to increase the radius over time.
Video tutorial on YouTube: https://youtu.be/x1dIJdz8Uj8
Written by Michael Watt

Thanks to Inigo Quilez for the SDF (https://iquilezles.org/articles/distfunctions/)
Thanks to nonunknown for the conditional statement replacements (https://godotshaders.com/shader/optimize-your-shaders/)
*/

shader_type spatial;
render_mode unshaded;

uniform float pulse_width = 2.;
uniform vec4 sphere_data[16];
uniform vec4 sphere_attributes_data[16];

uniform int sphere_data_length;

uniform float fog_height : hint_range(0.0, 1000., 100.);
uniform float fog_basis = 0;
uniform vec4 fog_color : source_color = vec4(1.0);
uniform sampler2D fog_gradient: repeat_disable;

// Access the screen and depth buffers
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

// Necessary for rebuilding the world coordinates
varying mat4 CAMERA;

// Function from Inigo Quilez https://iquilezles.org/articles/distfunctions/
float sdSphere( vec3 p, float s ) {
	return length(p)-s;
}

float map_range(float value, float from_min, float from_max, float to_min, float to_max) {
	float r = from_max - from_min;
	float a = (clamp(value, from_min, from_max) - from_min) / r;
	float b = (to_max - to_min) * a + to_min;
	
	return b; 
}

// Replacements for < and > because math on GPU is fast. They return 1 or 0
float when_lt(float left_side, float right_side) {
	return max(sign(right_side - left_side), 0.0);
}
float when_gt(float left_side, float right_side) {
	return max(sign(left_side - right_side), 0.0);
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
	
	CAMERA = INV_VIEW_MATRIX;
}

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	// Get the original screen rendered texture at the screen uv coordinates.
	vec4 original = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	
	// Get the depth value form the depth buffer.
	float depth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;

	//Unecessary for this effect, but to get the linear depth value,
	//use the following code.
	//vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	//view.xyz /= view.w;
	//float linear_depth = -view.z;
	
	// Calculate the fragment's world position
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	
	vec3 output = original.rgb;
	float fog_weight = map_range(world_position.y, fog_basis, fog_height, 0., 1.);
	float fog_intensity = texture(fog_gradient, vec2(fog_weight, 0.)).r;
	
	float rand_value = random(SCREEN_UV);
	
	vec3 noise_rings = vec3(0.);
	
	for (int idx = 0; idx < sphere_data_length; ++idx) {
		vec4 sphere_datum = sphere_data[idx];
		vec4 sphere_attribute_datum = sphere_attributes_data[idx];
		
		float dist = sdSphere(sphere_datum.xyz - world_position, sphere_datum.w);
		float ease_out = map_range(sphere_datum.w, sphere_attribute_datum.w * .8, sphere_attribute_datum.w, 0., 1.);
		float fade_out_color = map_range(sphere_datum.w, 0., sphere_attribute_datum.w, 0., 1.);
		dist += rand_value;
		
		// Extra calculations to get the correct gradient direction.
		// Using calculation functions in place of if statements.
		float mix_ratio = 0.0;
		float check = when_lt(dist, 0.0) * when_gt(dist, -pulse_width);
		float percentage = abs(dist) / abs(pulse_width);
		mix_ratio = 1.0 * check - percentage;
		mix_ratio = clamp(mix_ratio, 0.0, 1.0);
		
		noise_rings = mix(noise_rings, sphere_attribute_datum.rgb - fade_out_color, mix_ratio);
		fog_intensity = length(sphere_datum.xyz - world_position) <= sphere_datum.w - pulse_width ? ease_out : fog_intensity;
	}
	// Set the albedo to the mix between the original screen and the added
	// pulse color.

	fog_intensity = clamp(fog_intensity, 0., 1.);
	
	output += noise_rings;
	output = mix(output, fog_color.rgb, fog_intensity);
	ALBEDO = output;
}