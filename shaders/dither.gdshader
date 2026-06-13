shader_type spatial;
render_mode unshaded;

uniform sampler2D u_dither_tex : repeat_enable, filter_nearest;
uniform sampler2D u_color_tex : filter_nearest;

uniform int u_bit_depth;
uniform float u_contrast;
uniform float u_offset;
uniform int u_dither_size;
uniform float grayscale: hint_range(0.0, 1.0, 0.01);
uniform float hue_shift: hint_range(0.0, 360, 0.01);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture;

// Necessary for rebuilding the world coordinates
varying mat4 CAMERA;

vec3 hueShift( vec3 color, float hueAdjust ){

    const vec3  kRGBToYPrime = vec3 (0.299, 0.587, 0.114);
    const vec3  kRGBToI      = vec3 (0.596, -0.275, -0.321);
    const vec3  kRGBToQ      = vec3 (0.212, -0.523, 0.311);

    const vec3  kYIQToR     = vec3 (1.0, 0.956, 0.621);
    const vec3  kYIQToG     = vec3 (1.0, -0.272, -0.647);
    const vec3  kYIQToB     = vec3 (1.0, -1.107, 1.704);

    float   YPrime  = dot (color, kRGBToYPrime);
    float   I       = dot (color, kRGBToI);
    float   Q       = dot (color, kRGBToQ);
    float   hue     = atan (Q, I);
    float   chroma  = sqrt (I * I + Q * Q);

    hue += hueAdjust;

    Q = chroma * sin (hue);
    I = chroma * cos (hue);

    vec3    yIQ   = vec3 (YPrime, I, Q);

    return vec3( dot (yIQ, kYIQToR), dot (yIQ, kYIQToG), dot (yIQ, kYIQToB) );
}

float map_range(float value, float from_min, float from_max, float to_min, float to_max) {
	float r = from_max - from_min;
	float a = (clamp(value, from_min, from_max) - from_min) / r;
	float b = (to_max - to_min) * a + to_min;
	
	return b; 
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
	
	CAMERA = INV_VIEW_MATRIX;
}

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

vec3 dither(vec3 output, vec2 uv) {
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
    vec2 noise_uv = uv * inv_noise_size * vec2(float(screen_size.x), float(screen_size.y));
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
	
	return final_col;
}

void fragment() {
	vec4 original = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	float depth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;

	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	
	vec3 output = dither(original.rgb, UV);
	
	vec3 gray = mix(vec3((output.r + output.g + output.b) / 3.0),  vec3(0.299 * output.r + 0.587 * output.g + 0.114 * output.b), float(grayscale));
	output = mix(output, gray, float(grayscale));
	
	ALBEDO = hueShift(output, hue_shift);
}