shader_type canvas_item;

uniform vec4 hull_white : source_color = vec4(0.94, 0.95, 0.97, 1.0);
uniform vec4 hull_light : source_color = vec4(0.74, 0.77, 0.83, 1.0);
uniform vec4 hull_grey  : source_color = vec4(0.42, 0.45, 0.53, 1.0);
uniform vec4 hull_black : source_color = vec4(0.07, 0.07, 0.12, 1.0);
uniform vec4 flame_core : source_color = vec4(1.00, 0.98, 0.82, 1.0);
uniform vec4 flame_mid  : source_color = vec4(1.00, 0.72, 0.18, 1.0);
uniform vec4 flame_edge : source_color = vec4(0.93, 0.34, 0.05, 1.0);
uniform float pixels : hint_range(24.0, 160.0) = 48.0;
uniform float flicker_speed : hint_range(1.0, 30.0) = 12.0;
uniform float plume_length : hint_range(0.05, 0.6) = 0.34;

float hash1(float x) {
	return fract(sin(x * 78.233) * 43758.5453123);
}

void fragment() {
	vec2 puv = (floor(UV * pixels) + 0.5) / pixels;
	vec2 p = (puv - 0.5) * 2.0;
	float ax = abs(p.x);

	// ---------- silhouette: wide span, short body ----------
	float wt = clamp((p.y + 0.14) / 0.54, 0.0, 1.0);
	float wing_hw = mix(0.40, 0.97, pow(wt, 1.2));
	float wing = step(ax, wing_hw) * step(-0.14, p.y) * step(p.y, 0.40);

	float ft = clamp((p.y + 0.70) / 1.14, 0.0, 1.0);
	float fus_hw = mix(0.16, 0.34, pow(ft, 0.7));
	float fus = step(ax, fus_hw) * step(-0.70, p.y) * step(p.y, 0.44);

	float nt = clamp((p.y + 0.72) / 0.62, 0.0, 1.0);
	float fin_hw = mix(0.05, 0.13, nt);
	float fin = step(ax, fin_hw) * step(-0.72, p.y) * step(p.y, -0.10);

	// fat OMS pods bulging past the wing root
	float pods = step(distance(vec2(ax, p.y), vec2(0.40, -0.04)), 0.14);

	float body = max(max(wing, fus), max(fin, pods));

	// ---------- panelling ----------
	vec3 col = hull_white.rgb;

	float wr = ax / max(wing_hw, 0.001);
	col = mix(col, hull_light.rgb, step(0.50, wr) * wing);
	col = mix(col, hull_grey.rgb,  step(0.76, wr) * wing);
	col = mix(col, hull_black.rgb, step(0.92, wr) * wing);

	col = mix(col, hull_black.rgb, step(0.28, p.y) * step(p.y, 0.44));
	col = mix(col, hull_light.rgb,
		step(-0.20, p.y) * step(p.y, 0.28) * step(ax, 0.14));
	col = mix(col, hull_black.rgb,
		fin * step(-0.68, p.y) * step(p.y, -0.24) * step(ax, 0.05));
	col = mix(col, hull_grey.rgb, pods * 0.85);

	float alpha = body;

	// ---------- engines, spread wide ----------
	float flick = 0.75 + 0.25 * sin(TIME * flicker_speed)
		+ 0.10 * sin(TIME * flicker_speed * 2.3);

	vec2 n0 = vec2(0.00, 0.16);
	vec2 n1 = vec2(-0.30, 0.30);
	vec2 n2 = vec2(0.30, 0.30);

	float noz = 0.0;
	noz = max(noz, step(distance(p, n0), 0.17));
	noz = max(noz, step(distance(p, n1), 0.17));
	noz = max(noz, step(distance(p, n2), 0.17));
	col = mix(col, hull_black.rgb, noz);
	alpha = max(alpha, noz);

	float d = min(distance(p, n0), min(distance(p, n1), distance(p, n2)));
	float fl = floor(clamp(1.0 - d / 0.12, 0.0, 1.0) * flick * 4.0) / 4.0;
	if (fl > 0.0) {
		vec3 fire = flame_edge.rgb;
		if (fl > 0.25) { fire = flame_mid.rgb; }
		if (fl > 0.60) { fire = flame_core.rgb; }
		col = fire;
		alpha = 1.0;
	}

	// ---------- broad exhaust plume ----------
	float row = floor(puv.y * pixels);
	float wobble = hash1(row + floor(TIME * 14.0));
	float pt = clamp((p.y - 0.46) / plume_length, 0.0, 1.0);
	float pw = mix(0.44, 0.06, pt) * (0.75 + 0.5 * wobble);
	if (p.y > 0.46 && ax < pw) {
		float heat = (1.0 - pt) * flick;
		vec3 fire = flame_edge.rgb;
		if (heat > 0.35) { fire = flame_mid.rgb; }
		if (heat > 0.70) { fire = flame_core.rgb; }
		col = fire;
		alpha = 1.0;
	}

	COLOR = vec4(col, alpha);
}