shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

const float curvature = 5.0;
uniform float vignette_multiplier: hint_range(0.0, 1.0) = 0.3;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform float crt_brightness: hint_range(0.0, 5.0) = 1.0;
uniform float crt_ghost: hint_range(0.0, 10.0) = 1.5;

void fragment() {
	vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
	vec2 uv_offset = centered_uv.yx / curvature;
	vec2 warped_uv = centered_uv + centered_uv * uv_offset * uv_offset;
	vec3 cutoff = vec3(step(abs(warped_uv.x), 1.0) * step(abs(warped_uv.y), 1.0));
	vec3 scanlines = vec3(sin(2.0 * warped_uv.y * 180.0) * 0.1 + 0.9);
	vec3 vignette = vec3(length(pow(abs(centered_uv), vec2(4.0)) / 3.0));
	
	vec3 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb * (1.0 - crt_brightness * 0.5);
	screen_color += texture(SCREEN_TEXTURE, SCREEN_UV - vec2(SCREEN_PIXEL_SIZE.x * crt_ghost), 0.0).rgb;
	screen_color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE.x * crt_ghost), 0.0).rgb;
	screen_color *= crt_brightness;
	
	screen_color *= textureLod(screen_texture, (warped_uv + 1.0) / 2.0, 0.2).rgb * cutoff * scanlines;
	screen_color -= vignette * vignette_multiplier;
	
	COLOR = vec4(screen_color, 1.0);
}