shader_type canvas_item;

uniform vec4 ocean_deep : source_color = vec4(0.02, 0.09, 0.28, 1.0);
uniform vec4 ocean_shallow : source_color = vec4(0.06, 0.32, 0.56, 1.0);
uniform vec4 land_low : source_color = vec4(0.13, 0.34, 0.16, 1.0);
uniform vec4 land_high : source_color = vec4(0.45, 0.39, 0.22, 1.0);
uniform vec4 ice_color : source_color = vec4(0.92, 0.96, 1.0, 1.0);
uniform vec4 cloud_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 night_color : source_color = vec4(0.02, 0.02, 0.07, 1.0);
uniform vec4 atmo_color : source_color = vec4(0.35, 0.65, 1.0, 1.0);
uniform vec2 light_dir = vec2(-0.6, -0.5);
uniform float noise_scale : hint_range(1.0, 12.0) = 4.0;
uniform float sea_level : hint_range(0.0, 1.0) = 0.54;
uniform float ice_extent : hint_range(0.5, 1.0) = 0.80;
uniform float cloud_amount : hint_range(0.0, 1.0) = 0.45;
uniform float cloud_opacity : hint_range(0.0, 1.0) = 0.7;
uniform float spin_speed : hint_range(0.0, 0.2) = 0.02;
uniform float cloud_spin_speed : hint_range(0.0, 0.2) = 0.03;
uniform float atmo_strength : hint_range(0.0, 2.0) = 0.9;

float hash3(vec3 p) {
	return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123);
}

float value_noise3(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float n000 = hash3(i + vec3(0.0, 0.0, 0.0));
	float n100 = hash3(i + vec3(1.0, 0.0, 0.0));
	float n010 = hash3(i + vec3(0.0, 1.0, 0.0));
	float n110 = hash3(i + vec3(1.0, 1.0, 0.0));
	float n001 = hash3(i + vec3(0.0, 0.0, 1.0));
	float n101 = hash3(i + vec3(1.0, 0.0, 1.0));
	float n011 = hash3(i + vec3(0.0, 1.0, 1.0));
	float n111 = hash3(i + vec3(1.0, 1.0, 1.0));
	float x00 = mix(n000, n100, f.x);
	float x10 = mix(n010, n110, f.x);
	float x01 = mix(n001, n101, f.x);
	float x11 = mix(n011, n111, f.x);
	return mix(mix(x00, x10, f.y), mix(x01, x11, f.y), f.z);
}

float fbm3(vec3 p) {
	float total = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 5; i++) {
		total += value_noise3(p) * amp;
		p *= 2.03;
		amp *= 0.5;
	}
	return total;
}

vec3 rotate_y(vec3 v, float a) {
	float s = sin(a);
	float c = cos(a);
	return vec3(c * v.x + s * v.z, v.y, -s * v.x + c * v.z);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float r = length(p);
	float z = sqrt(max(0.0, 1.0 - r * r));
	vec3 n = vec3(p.x, p.y, z);

	// rotate the sample point instead of the sprite, so the globe spins
	vec3 sp = rotate_y(n, TIME * spin_speed);
	float h = fbm3(sp * noise_scale);

	vec3 ocean = mix(ocean_deep.rgb, ocean_shallow.rgb,
		smoothstep(sea_level - 0.15, sea_level, h));
	vec3 land = mix(land_low.rgb, land_high.rgb,
		smoothstep(sea_level, sea_level + 0.18, h));
	float coast = smoothstep(sea_level - 0.015, sea_level + 0.015, h);
	vec3 surface = mix(ocean, land, coast);

	// polar ice caps
	float polar = smoothstep(ice_extent, ice_extent + 0.12, abs(n.y));
	surface = mix(surface, ice_color.rgb, polar);

	// cloud deck, spinning slightly faster than the surface
	vec3 cp = rotate_y(n, TIME * cloud_spin_speed);
	float cloud = fbm3(cp * (noise_scale * 1.6) + vec3(21.7));
	float cloud_mask = smoothstep(1.0 - cloud_amount,
		1.0 - cloud_amount + 0.15, cloud) * cloud_opacity;
	surface = mix(surface, cloud_color.rgb, cloud_mask);

	// day/night
	vec3 l = normalize(vec3(light_dir, 0.6));
	float lambert = clamp(dot(n, l), 0.0, 1.0);
	float day = smoothstep(0.0, 0.35, lambert);
	vec3 col = mix(night_color.rgb, surface, day);

	// atmospheric halo
	float rim = pow(1.0 - z, 3.0) * atmo_strength;
	col += atmo_color.rgb * rim * clamp(lambert + 0.3, 0.0, 1.0);

	float edge = smoothstep(1.0, 0.985, r);
	COLOR = vec4(col, edge);
}