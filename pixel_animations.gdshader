shader_type canvas_item;

uniform float effect_intensity = 0.0;
uniform float time = 0.0;
uniform int effect_type = 0;
uniform float wave_amp = 0.02;
uniform float glitch_intensity = 0.05;

void fragment() {
	vec2 uv = UV;
	
	// 应用不同的效果
	if (effect_intensity > 0.0) {
		if (effect_type == 0) { // 扫描线效果
			float scanline = sin(uv.y * 800.0 + time * 10.0);
			scanline = smoothstep(0.5, 1.0, scanline);
			COLOR = texture(TEXTURE, uv) * vec4(1.0, 1.0, 1.0, mix(1.0, 0.7 + scanline * 0.3, effect_intensity));
		}
		else if (effect_type == 1) { // 波浪扭曲
			float wave = sin(uv.x * 20.0 + time * 5.0) * wave_amp;
			uv.y += wave;
			COLOR = texture(TEXTURE, uv);
		}
		else if (effect_type == 2) { // 溶解效果
			float noise = fract(sin(uv.x * 100.0 + uv.y * 50.0 + time * 3.0) * 43758.5453);
			float threshold = sin(time) * 0.5 + 0.5;
			if (noise > threshold) {
				COLOR = texture(TEXTURE, uv);
			} else {
				COLOR = vec4(0.0);
			}
		}
		else if (effect_type == 3) { // 像素故障
			float pixel_size = 64.0;
			uv = floor(uv * pixel_size) / pixel_size;
			
			// 添加随机偏移
			float offset_x = sin(time * 10.0 + uv.y * 20.0) * glitch_intensity;
			float offset_y = cos(time * 8.0 + uv.x * 15.0) * glitch_intensity * 0.5;
			
			// 分离RGB通道
			vec2 r_uv = uv + vec2(offset_x * 0.02, offset_y * 0.01);
			vec2 g_uv = uv + vec2(offset_x * -0.01, offset_y * -0.02);
			vec2 b_uv = uv + vec2(offset_x * 0.03, offset_y * -0.01);
			
			float r = texture(TEXTURE, r_uv).r;
			float g = texture(TEXTURE, g_uv).g;
			float b = texture(TEXTURE, b_uv).b;
			
			COLOR = vec4(r, g, b, 1.0);
		}
		else if (effect_type == 4) { // 闪烁效果
			float flicker = sin(time * 20.0) * 0.5 + 0.5;
			COLOR = texture(TEXTURE, uv) * vec4(1.0, 1.0, 1.0, mix(1.0, flicker, effect_intensity));
		}
		else if (effect_type == 5) { // 颜色循环
			vec4 tex_color = texture(TEXTURE, uv);
			float hue_shift = time;
			
			// RGB转HSV
			float max_val = max(tex_color.r, max(tex_color.g, tex_color.b));
			float min_val = min(tex_color.r, min(tex_color.g, tex_color.b));
			float delta = max_val - min_val;
			
			float hue = 0.0;
			if (delta > 0.0) {
				if (max_val == tex_color.r) {
					hue = (tex_color.g - tex_color.b) / delta;
				} else if (max_val == tex_color.g) {
					hue = 2.0 + (tex_color.b - tex_color.r) / delta;
				} else {
					hue = 4.0 + (tex_color.r - tex_color.g) / delta;
				}
				hue = fract((hue / 6.0 + hue_shift) * effect_intensity);
			}
			
			// HSV转RGB
			float h_i = floor(hue * 6.0);
			float f = hue * 6.0 - h_i;
			float p = max_val * (1.0 - effect_intensity * 0.5);
			float q = max_val * (1.0 - f * effect_intensity * 0.5);
			float t = max_val * (1.0 - (1.0 - f) * effect_intensity * 0.5);
			
			vec3 rgb;
			if (h_i == 0.0) rgb = vec3(max_val, t, p);
			else if (h_i == 1.0) rgb = vec3(q, max_val, p);
			else if (h_i == 2.0) rgb = vec3(p, max_val, t);
			else if (h_i == 3.0) rgb = vec3(p, q, max_val);
			else if (h_i == 4.0) rgb = vec3(t, p, max_val);
			else rgb = vec3(max_val, p, q);
			
			COLOR = vec4(mix(tex_color.rgb, rgb, effect_intensity), tex_color.a);
		}
	} else {
		COLOR = texture(TEXTURE, uv);
	}
	
	// 添加像素风效果
	vec2 pixel_size = vec2(1.0) / vec2(textureSize(TEXTURE, 0));
	vec2 pixel_uv = floor(uv / pixel_size) * pixel_size;
	COLOR = texture(TEXTURE, pixel_uv);
}