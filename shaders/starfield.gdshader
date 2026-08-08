shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.01, 0.01, 0.06, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.09, 0.03, 0.18, 1.0);
uniform float aspect = 1.777;
uniform float star_density : hint_range(10.0, 120.0) = 40.0;
uniform float star_size : hint_range(0.05, 0.35) = 0.3;
uniform float star_falloff : hint_range(1.0, 16.0) = 6.0;
uniform float twinkle_speed : hint_range(0.0, 5.0) = 1.5;
uniform float drift_speed : hint_range(0.0, 0.1) = 0.005;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
	vec3 col = mix(top_color.rgb, bottom_color.rgb, UV.y);

	vec2 uv = vec2(UV.x * aspect, UV.y);
	uv.y -= TIME * drift_speed;

	for (int i = 0; i < 3; i++) {
		float layer = float(i);
		float density = star_density * (1.0 + layer * 0.8);
		vec2 grid = uv * density;
		vec2 cell = floor(grid);
		vec2 f = fract(grid);

		float h = hash(cell + layer * 37.0);
		if (h > 0.982) {
			// keep stars away from cell edges so the glow never gets clipped
			vec2 star_pos = vec2(
				0.3 + 0.4 * hash(cell + 1.3 + layer),
				0.3 + 0.4 * hash(cell + 4.7 + layer)
			);
			float d = distance(f, star_pos);
			float phase = hash(cell + 9.1 + layer) * 6.2831853;
			float rate = 0.5 + 1.5 * hash(cell + 12.7 + layer);
			float twinkle = 0.55 + 0.45 * sin(TIME * twinkle_speed * rate + phase);
			// bright core with a soft halo, instead of a sub-pixel dot
			float falloff = clamp(1.0 - d / star_size, 0.0, 1.0);
			float brightness = pow(falloff, star_falloff) * twinkle;
			col += vec3(brightness) * (1.0 - layer * 0.28);
		}
	}

	COLOR = vec4(col, 1.0);
}