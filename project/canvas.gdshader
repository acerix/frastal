shader_type canvas_item;

uniform vec2 position = vec2(0, -0.75);
uniform float zoom = 0.2;
uniform float viewport_aspect_ratio = 1.0;
uniform float two_in_quotes = 2.0; // the variable "²" in "z ↦ z²+c"
uniform int iteration_limit = 128;
uniform int palette_offset = 0;
uniform sampler2D palette_image;

vec4 mandelbrot(vec2 c) {
	vec2 z = vec2(0, 0);
	vec2 z2 = vec2(0, 0);
	int i = 0;

	// z ↦ z²+c
	while (z2.x + z2.y <= 4.0 && ++i < iteration_limit) { // bail outside radius 2
		z = vec2(
			two_in_quotes * z.y * z.x + c.x,
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
	if (abs(m.w - 1.0) < 0.0001) { // if (m.w == 1.0), but ignore floating-point errors < ε
		return texelFetch(palette_image, ivec2(0, 0), 0).rgb;
	}
	int mz = int(m.z) + palette_offset;
	vec3 color1 = texelFetch(palette_image, ivec2(1 + mz % color_count, 0), 0).rgb;
	vec3 color2 = texelFetch(palette_image, ivec2(1 + (mz + 1) % color_count, 0), 0).rgb;
	return mix(color1, color2, fract(m.z));
}

void fragment() {
	vec2 uv = (UV - vec2(0.5)) * vec2(viewport_aspect_ratio, 1) / zoom + position;
	vec4 result = mandelbrot(uv);
	vec3 color = palette(result);
	COLOR = vec4(color, 1);
}
