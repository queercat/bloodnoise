shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled, unshaded;

uniform vec4 color: source_color = vec4(1.0, 1.0, 1.0, 0.25098);
uniform sampler2D noise_texture: hint_default_black;
uniform float noise_scale = 4.0;
uniform vec2 noise_speed = vec2(0.05, 0.0);
uniform float softness: hint_range(0, 10) = 3.0;
uniform float fade_in: hint_range(0, 1) = 0.1;
uniform float fade_out: hint_range(0, 1) = 0.9;
uniform float near_fade = 3.0;
uniform float far_fade = 50.0;
uniform float phase: hint_range(0, 1) = 0.45;
uniform float scale_factor = 1.0;
uniform vec2 random_offset = vec2(0.21, 0.67);
uniform bool billboard = true;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture;

uniform sampler2D DEPTH_TEX :
		hint_depth_texture,
		repeat_disable,
		filter_linear_mipmap;

varying float PHASE;
varying float SCALE;
varying vec2 RANDOM;

float linearize(float depth, vec2 screen_uv, mat4 inv_proj_mat) {
	vec3 ndc = vec3(screen_uv, depth) * 2.0 - 1.0;
	vec4 view = inv_proj_mat * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}

void fragment() {
	ALPHA = 1.;
	ALBEDO = vec3(1., 1., 1.);
	ALPHA = 1.;
}