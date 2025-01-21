shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

uniform float curvature: hint_range(0.0, 10.0) = 5.0;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;
uniform float crt_brightness: hint_range(0.1, 0.5) = 0.337;
uniform float crt_ghost: hint_range(0.0, 10.0) = 1.5;

void fragment() {
	vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
	vec2 uv_offset = centered_uv.yx / curvature;
	vec2 warped_uv = centered_uv + centered_uv * uv_offset * uv_offset;
	vec2 uncentered_uv =  (warped_uv + 1.0) / 2.0;
	vec3 screen_color = textureLod(SCREEN_TEXTURE, uncentered_uv, 0.2).rgb;
	vec2 ghost_image = vec2(SCREEN_PIXEL_SIZE.x * crt_ghost);
	
	//screen_color += textureLod(SCREEN_TEXTURE, uncentered_uv + ghost_image, 1.0).rgb * crt_brightness;
	//screen_color += textureLod(SCREEN_TEXTURE, uncentered_uv - ghost_image, 1.0).rgb * crt_brightness;
	screen_color += texture(SCREEN_TEXTURE, uncentered_uv - vec2(SCREEN_PIXEL_SIZE.x * crt_ghost), 0.0).rgb * crt_brightness;
	screen_color += texture(SCREEN_TEXTURE, uncentered_uv + vec2(SCREEN_PIXEL_SIZE.x * crt_ghost), 0.0).rgb * crt_brightness;

	//screen_color += crt_brightness;
	
	//screen_color -= vignette * vignette_multiplier;
	
	COLOR = vec4(screen_color, 1.0);
}