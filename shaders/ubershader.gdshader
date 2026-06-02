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

uniform sampler2D u_dither_tex : repeat_enable, filter_nearest;
uniform sampler2D u_color_tex : filter_nearest;

uniform int u_bit_depth;
uniform float u_contrast;
uniform float u_offset;
uniform int u_dither_size;

uniform float pulse_width = 2.;

uniform int sphere_data_length;
uniform vec4 sphere_data[16];
uniform vec4 sphere_attributes_data[16];

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
		dist += rand_value;
		
		// Extra calculations to get the correct gradient direction.
		// Using calculation functions in place of if statements.
		float mix_ratio = 0.0;
		float check = when_lt(dist, 0.0) * when_gt(dist, -pulse_width);
		float percentage = abs(dist) / abs(pulse_width);
		mix_ratio = 1.0 * check - percentage;
		mix_ratio = clamp(mix_ratio, 0.0, 1.0);
		
		noise_rings = mix(noise_rings, sphere_attribute_datum.rgb, mix_ratio);
		fog_intensity = length(sphere_datum.xyz - world_position) <= sphere_datum.w - pulse_width ? 0.0 : fog_intensity;
	}
	// Set the albedo to the mix between the original screen and the added
	// pulse color.

	fog_intensity = clamp(fog_intensity, 0., .75);
	//
	output += noise_rings;
	output = mix(output, fog_color.rgb, fog_intensity);

	vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 0)) / float(u_dither_size);
	
    // calculate pixel luminosity (https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color)
    float lum = (output.r * 0.299) + (output.g * 0.587) + (output.b * 0.114);

    // adjust with contrast and offset parameters
    float contrast = u_contrast;
    lum = (lum - 0.5 + u_offset) * contrast + 0.5;
    lum = clamp(lum, 0.0, 1.0);

    // reduce luminosity bit depth to give a more banded visual if desired
    float bits = float(u_bit_depth);
    lum = floor(lum * bits) / bits;

    // to support multicolour palettes, we want to dither between the two colours on the palette
    // which are adjacent to the current pixel luminosity.
    // to do this, we need to determine which 'band' lum falls into, calculate the upper and lower
    // bound of that band, then later we will use the dither texture to pick either the upper or 
    // lower colour.

    // get the palette texture size mapped so it is 1px high (so the x value however many colour bands there are)
    ivec2 col_size = textureSize(u_color_tex, 0);
    col_size /= col_size.y;

    float col_x = float(col_size.x) - 1.0; // colour boundaries is 1 less than the number of colour bands
    float col_texel_size = 1.0 / col_x; // the size of one colour boundary

    lum = max(lum - 0.00001, 0.0); // makes sure our floor calculation below behaves when lum == 1.0
    float lum_lower = floor(lum * col_x) * col_texel_size;
    float lum_upper = (floor(lum * col_x) + 1.0) * col_texel_size;
    float lum_scaled = lum * col_x - floor(lum * col_x); // calculates where lum lies between the upper and lower bound

    // map the dither texture onto the screen. there are better ways of doing this that makes the dither pattern 'stick'
    // with objects in the 3D world, instead of being mapped onto the screen. see lucas pope's details posts on how he 
    // achieved this in Obra Dinn: https://forums.tigsource.com/index.php?topic=40832.msg1363742#msg1363742
    ivec2 noise_size = textureSize(u_dither_tex, 0);
    vec2 inv_noise_size = vec2(1.0 / float(noise_size.x), 1.0 / float(noise_size.y));
    vec2 noise_uv = UV * inv_noise_size * vec2(float(screen_size.x), float(screen_size.y));
    float threshold = texture(u_dither_tex, noise_uv).r;

    // adjust the dither slightly so min and max aren't quite at 0.0 and 1.0
    // otherwise we wouldn't get fullly dark and fully light dither patterns at lum 0.0 and 1.0
    threshold = threshold * 0.99 + 0.005;

    // the lower lum_scaled is, the fewer pixels will be below the dither threshold, and thus will use the lower bound colour,
    // and vice-versa
    float ramp_val = lum_scaled < threshold ? 0.0f : 1.0f;
    // sample at the lower bound colour if ramp_val is 0.0, upper bound colour if 1.0
    float col_sample = mix(lum_lower, lum_upper, ramp_val);
    vec3 final_col = texture(u_color_tex, vec2(col_sample, 0.5)).rgb;

    // return the final colour!
    output.rgb = final_col;
	
	ALBEDO = output;
}