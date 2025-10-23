shader_type canvas_item;

uniform vec2 position = vec2(0, -0.75);
uniform float zoom: hint_range(0, 15) = 0.2;
uniform float ratio = 1;
uniform float tiq = 2.0; // two, "in quotes"... the "²" in "z ↦ z²+c"
uniform int iteration_limit = 64;
uniform sampler2D palette_image;

// gpu reaches 100% around 500, when mandeldude goes big on the screen
// noise stops at high values 42000
//const int iteration_limit = 2666;

vec4 mandelbrot(vec2 c) {
	vec2 z = vec2(0, 0);
	vec2 z2 = vec2(0, 0);
	int i = 0;

	// z ↦ z²+c
	while (z2.x + z2.y <= 4.0 && ++i < iteration_limit) {  // bail outside radius 2
	// while (++i < iteration_limit) { // don't bail
		z = vec2(
			tiq * z.y * z.x + c.x,
			z2.y - z2.x + c.y
		);
		z2 = z * z;
	}

	return vec4(
		z, // xy position
		float(i), // number of iterations
		i == iteration_limit ? 1.0 : 0.0 // true (1.0) if inside the set
	);

}

vec3 palette(vec4 m) {
	int color_count = textureSize(palette_image, 0).x - 1;
	if (abs(m.w - 1.0) < 0.0001) { // if (m.w == 1.0), ignoring floating-point errors < ε
		return texelFetch(palette_image, ivec2(0, 0), 0).rgb;
	}
	vec3 color1 = texelFetch(palette_image, ivec2(1 + int(m.z) % color_count, 0), 0).rgb;
	vec3 color2 = texelFetch(palette_image, ivec2(1 + (int(m.z) + 1) % color_count, 0), 0).rgb;
	return mix(color1, color2, fract(m.z));
}

void fragment() {
	vec2 uv = ((UV - vec2(0.5)) * vec2(ratio, 1)) / exp(zoom - 1.25) + position;
	vec4 result = mandelbrot(uv);
	vec3 color = palette(result);
	COLOR = vec4(color, 1);
}
