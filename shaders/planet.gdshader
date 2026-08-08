shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.45, 0.30, 0.55, 1.0);
uniform vec4 shade_color : source_color = vec4(0.05, 0.03, 0.09, 1.0);
uniform vec4 rim_color : source_color = vec4(0.55, 0.80, 1.0, 1.0);
uniform vec2 light_dir = vec2(-0.6, -0.5);
uniform float band_count : hint_range(1.0, 20.0) = 7.0;
uniform float band_strength : hint_range(0.0, 0.6) = 0.18;
uniform float rim_strength : hint_range(0.0, 2.0) = 0.7;
uniform float spin_speed : hint_range(0.0, 0.1) = 0.01;

void fragment() {
	// map the rect to a -1..1 square; anything outside radius 1 is transparent
	vec2 p = (UV - 0.5) * 2.0;
	float r = length(p);

	// fake a sphere: solve for the z of a unit sphere at this x,y
	float z = sqrt(max(0.0, 1.0 - r * r));
	vec3 n = vec3(p, z);

	// day/night terminator
	vec3 l = normalize(vec3(light_dir, 0.6));
	float lambert = clamp(dot(n, l), 0.0, 1.0);
	vec3 col = mix(shade_color.rgb, base_color.rgb, lambert);

	// latitude bands, drifting slowly
	float band = sin((n.y + TIME * spin_speed) * band_count * 3.14159);
	col *= 1.0 + band * band_strength;

	// atmospheric rim light around the edge
	float rim = pow(1.0 - z, 3.0) * rim_strength;
	col += rim_color.rgb * rim * clamp(lambert + 0.25, 0.0, 1.0);

	// soft antialiased circle edge
	float edge = smoothstep(1.0, 0.985, r);
	COLOR = vec4(col, edge);
}