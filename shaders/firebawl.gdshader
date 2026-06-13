shader_type spatial;
render_mode unshaded;

uniform sampler2D noise_texture;
uniform sampler2D ramp;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	float noise = texture(noise_texture, vec2(UV.x + TIME / 10. , 0.)).x;
	
	if (UV.y <= .5 + noise / 5.) {
		discard;
	}

	if (mod((UV.y + noise / 100.) * 10., 1.) <= .5 + noise / 5.) {
		discard;
	}

	vec3 color = texture(ramp, vec2(UV.y, 0.)).xyz;
	ALBEDO.rgb = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
