shader_type canvas_item;

uniform vec4 ocean_deep : source_color = vec4(0.18, 0.05, 0.26, 1.0);
uniform vec4 ocean_shallow : source_color = vec4(0.42, 0.14, 0.50, 1.0);
uniform vec4 land_low : source_color = vec4(0.15, 0.42, 0.38, 1.0);
uniform vec4 land_high : source_color = vec4(0.62, 0.75, 0.30, 1.0);
uniform vec4 ice_color : source_color = vec4(0.85, 0.95, 0.92, 1.0);
uniform vec4 cloud_color : source_color = vec4(0.95, 0.85, 1.0, 1.0);
uniform vec4 night_color : source_color = vec4(0.03, 0.01, 0.06, 1.0);
uniform vec4 atmo_color : source_color = vec4(0.75, 0.40, 1.0, 1.0);
uniform vec4 ring_color : source_color = vec4(0.85, 0.72, 0.95, 1.0);
uniform vec2 light_dir = vec2(-0.6, -0.5);
uniform float planet_scale : hint_range(0.2, 0.9) = 0.42;
uniform float noise_scale : hint_range(1.0, 12.0) = 4.5;
uniform float sea_level : hint_range(0.0, 1.0) = 0.52;
uniform float ice_extent : hint_range(0.5, 1.0) = 0.82;
uniform float cloud_amount : hint_range(0.0, 1.0) = 0.35;
uniform float cloud_opacity : hint_range(0.0, 1.0) = 0.6;
uniform float spin_speed : hint_range(0.0, 0.2) = 0.02;
uniform float cloud_spin_speed : hint_range(0.0, 0.2) = 0.03;
uniform float atmo_strength : hint_range(0.0, 2.0) = 0.9;
uniform float ring_inner : hint_range(1.0, 3.0) = 1.35;
uniform float ring_outer : hint_range(1.0, 3.0) = 2.15;
uniform float ring_tilt : hint_range(0.05, 0.6) = 0.26;
uniform float ring_lean : hint_range(-0.8, 0.8) = 0.22;
uniform float ring_opacity : hint_range(0.0, 1.0) = 0.85;
uniform float ring_detail : hint_range(1.0, 60.0) = 26.0;
uniform float shadow_strength : hint_range(0.0, 1.0) = 0.55;

float hash3(vec3 p) {
	return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123);
}

float value_noise3(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float x00 = mix(hash3(i), hash3(i + vec3(1.0, 0.0, 0.0)), f.x);
	float x10 = mix(hash3(i + vec3(0.0, 1.0, 0.0)), hash3(i + vec3(1.0, 1.0, 0.0)), f.x);
	float x01 = mix(hash3(i + vec3(0.0, 0.0, 1.0)), hash3(i + vec3(1.0, 0.0, 1.0)), f.x);
	float x11 = mix(hash3(i + vec3(0.0, 1.0, 1.0)), hash3(i + vec3(1.0, 1.0, 1.0)), f.x);
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

float hash1(float x) {
	return fract(sin(x * 78.233) * 43758.5453123);
}

// returns rgb + coverage for the ring at this pixel
vec4 sample_ring(vec2 q) {
	// un-lean, then un-squash to turn the ellipse back into a circle
	float s = sin(-ring_lean);
	float c = cos(-ring_lean);
	vec2 rot = vec2(c * q.x - s * q.y, s * q.x + c * q.y);
	vec2 flat_q = vec2(rot.x, rot.y / ring_tilt);
	float rd = length(flat_q);

	float band = smoothstep(ring_inner, ring_inner + 0.06, rd)
		* (1.0 - smoothstep(ring_outer - 0.10, ring_outer, rd));
	if (band <= 0.001) {
		return vec4(0.0);
	}

	// concentric gaps of varying darkness
	float t = (rd - ring_inner) / max(0.001, ring_outer - ring_inner);
	float g = hash1(floor(t * ring_detail));
	float gap = smoothstep(0.30, 0.55, g);
	float density = band * gap;

	vec3 col = ring_color.rgb * (0.65 + 0.5 * hash1(floor(t * ring_detail) + 5.0));
	return vec4(col, density * ring_opacity);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;

	// planet occupies the middle; rings extend into the rest of the rect
	vec2 pp = p / planet_scale;
	float r = length(pp);
	float z = sqrt(max(0.0, 1.0 - r * r));
	vec3 n = vec3(pp.x, pp.y, z);

	vec3 l = normalize(vec3(light_dir, 0.6));
	vec4 ring = sample_ring(pp);

	// which side of the ring plane the pixel is on decides draw order
	float s = sin(-ring_lean);
	float c = cos(-ring_lean);
	float ring_y = s * pp.x + c * pp.y;
	float ring_in_front = step(0.0, ring_y);

	vec3 col = vec3(0.0);
	float alpha = 0.0;

	// --- back half of the ring ---
	if (ring.a > 0.0 && ring_in_front < 0.5) {
		col = ring.rgb;
		alpha = ring.a;
	}

	// --- the planet ---
	if (r <= 1.0) {
		vec3 sp = rotate_y(n, TIME * spin_speed);
		float h = fbm3(sp * noise_scale);

		vec3 ocean = mix(ocean_deep.rgb, ocean_shallow.rgb,
			smoothstep(sea_level - 0.15, sea_level, h));
		vec3 land = mix(land_low.rgb, land_high.rgb,
			smoothstep(sea_level, sea_level + 0.18, h));
		float coast = smoothstep(sea_level - 0.015, sea_level + 0.015, h);
		vec3 surface = mix(ocean, land, coast);

		float polar = smoothstep(ice_extent, ice_extent + 0.12, abs(n.y));
		surface = mix(surface, ice_color.rgb, polar);

		vec3 cp = rotate_y(n, TIME * cloud_spin_speed);
		float cloud = fbm3(cp * (noise_scale * 1.6) + vec3(21.7));
		float cmask = smoothstep(1.0 - cloud_amount,
			1.0 - cloud_amount + 0.15, cloud) * cloud_opacity;
		surface = mix(surface, cloud_color.rgb, cmask);

		float lambert = clamp(dot(n, l), 0.0, 1.0);
		float day = smoothstep(0.0, 0.35, lambert);
		vec3 planet = mix(night_color.rgb, surface, day);

		float rim = pow(1.0 - z, 3.0) * atmo_strength;
		planet += atmo_color.rgb * rim * clamp(lambert + 0.3, 0.0, 1.0);

		float edge = smoothstep(1.0, 0.975, r);
		col = mix(col, planet, edge);
		alpha = max(alpha, edge);
	}

	// --- front half of the ring, shadowed where the planet blocks the sun ---
	if (ring.a > 0.0 && ring_in_front >= 0.5) {
		float shade = 1.0;
		vec2 to_light = normalize(l.xy);
		float along = dot(pp, to_light);
		float across = length(pp - to_light * along);
		if (along < 0.0 && across < 1.0) {
			shade = 1.0 - shadow_strength * (1.0 - smoothstep(0.6, 1.0, across));
		}
		col = mix(col, ring.rgb * shade, ring.a);
		alpha = max(alpha, ring.a);
	}

	COLOR = vec4(col, alpha);
}