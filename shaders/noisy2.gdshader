shader_type spatial;

uniform sampler2D noise_texture: repeat_enable;
uniform sampler2D CANVAS_TEXTURE: hint_screen_texture;
uniform sampler2D logo: repeat_disable;

//void vertex() {
	//float sampled_time = mod(TIME, 5.);
	//float dog = texture(noise_texture, vec2(TIME)).x * 5.;
	//VERTEX.xz += dog;
//}

void fragment() {
	vec2 uv = UV;
	float dog = texture(noise_texture, vec2(UV.x)).x;
	float sampled_time = cos(mod(TIME, 2.*PI)) / 10. + dog / 100.;
	//uv.x *= (sampled_time) + 1.1;
	//uv.y += dog / 100.;
	//uv.y += sampled_time / 100.;
		
	float data = texture(noise_texture, vec2(uv.x + TIME, uv.y)).x;
	
	vec4 color = texture(logo, uv);;
	
	if (data > .5) {
		discard;
	}
	
	vec3 grayscale = mix(vec3((color.r + color.g + color.b) / 3.0),  vec3(0.299 * color.r + 0.587 * color.g + 0.114 * color.b), float(true));
	color.rgb = mix(color.rgb, grayscale, data + dog);
	color.rgb *= 2. - dog * 2.;
	ALBEDO.rgb = color.rgb;
	}