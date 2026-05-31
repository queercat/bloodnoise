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

uniform float pulse_width = 2.0;
uniform vec4 color : source_color = vec4(1.0);
uniform vec4 sphere_data[16];

// Access the screen and depth buffers
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

// Necessary for rebuilding the world coordinates
varying mat4 CAMERA;

// Function from Inigo Quilez https://iquilezles.org/articles/distfunctions/
float sdSphere( vec3 p, float s ) {
	return length(p)-s;
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

float calculate_for_sphere(vec4 sphere_datum, vec3 world_position) {
	// Use the provided start transform and shift the world position to match
	// for the SDF to work as expected.
	float dist = sdSphere(sphere_datum.xyz - world_position, sphere_datum.w);
	
	// Extra calculations to get the correct gradient direction.
	// Using calculation functions in place of if statements.
	float mix_ratio = 0.0;
	float check = when_lt(dist, 0.0) * when_gt(dist, -pulse_width);
	float percentage = abs(dist) / abs(pulse_width);
	mix_ratio = 1.0 * check - percentage;
	mix_ratio = clamp(mix_ratio, 0.0, 1.0);
	
	return mix_ratio;
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
	
	for (int idx = 0; idx <= 32; ++idx) {
		float mix_ratio = calculate_for_sphere(sphere_data[idx], world_position);
		output = mix(output, color.rgb, mix_ratio);
	}
	
	// Set the albedo to the mix between the original screen and the added
	// pulse color.

	ALBEDO = output;

	//ALBEDO = vec3(map_range(linear_depth, 0., 100., 0., 1.));
}