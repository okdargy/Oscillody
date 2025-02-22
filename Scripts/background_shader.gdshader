// Oscillody
// Copyright (C) 2025 Akosmo

// This file is part of Oscillody. Unless specified otherwise, it is under the license below:

// Oscillody is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free Software Foundation,
// either version 3 of the License, or any later version.

// Oscillody is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.

// You should have received a copy of the GNU General Public License along with Oscillody.
// If not, see <https://www.gnu.org/licenses/>.

shader_type canvas_item;

// This shader creates a domain warping background.

uniform bool user_color_mix;
uniform vec4 user_color : source_color;
uniform float user_frequency_factor : hint_range(0.5, 6.0);
uniform float user_amplitude : hint_range(0.01, 0.1);
uniform float user_speed;
uniform int user_octaves : hint_range(1, 6);
uniform float user_frequency_increment : hint_range(1.0, 4.0);
uniform float user_amplitude_decrement : hint_range(0.1, 1.0);

// Hash function from https://www.shadertoy.com/view/MdcfDj
// Return pseudo-random value (.0 to .9999...). This is too complex for me to comment.
// This hash function (called "random" here) is dedicated to the public domain under the Unlicense.
// See [http://unlicense.org/] for more details.
float random(in vec2 seed) {
	uvec2 a = uvec2(seed);
	uint m1 = 1597334677U;
	uint m2 = 3812015801U;

	a *= uvec2(m1, m2);
	uint b = (a.x ^ a.y) * m1;

	return float(b) * (1.0/float(0xffffffffU));
}

// Value Noise function. Cheaper than gradient, but produces blocky patterns.
// Read: https://en.wikipedia.org/wiki/Value_noise
float value_noise(in vec2 uv) {
	vec2 integer_part = floor(uv);
	vec2 fraction_part = fract(uv);

	// Assigning random values to vertices that will compose the final lattice.
	float a = random(integer_part);
	float b = random(integer_part + vec2(1.0, 0.0));
	float c = random(integer_part + vec2(0.0, 1.0));
	float d = random(integer_part + vec2(1.0, 1.0));

	// Hermite interpolation. Weight is the same as the 3rd parameter in smoothstep.
	// This is basically blurring.
	// Read: https://en.wikipedia.org/wiki/Hermite_interpolation
	// Read: https://registry.khronos.org/OpenGL-Refpages/gl4/html/smoothstep.xhtml
	vec2 weight = fraction_part * fraction_part * (3.0 - 2.0 * fraction_part);

	float x1 = mix(a, b, weight.x);
	float x2 = mix(c, d, weight.x);
	return mix(x1, x2, weight.y);
}

// Fractional Brownian Motion: fractal, pseudo-random noise.
// Read: https://en.wikipedia.org/wiki/Fractional_Brownian_motion
// Read: https://thebookofshaders.com/13/
float fbm(in vec2 uv) {
	float waves = 0.0;
	float amplitude = user_amplitude;
	float frequency_factor = user_frequency_factor;

	int octaves = user_octaves; // Amount of noise layers
	for (int i = 0; i < octaves; i++) {
		// Following the equation y = A * sin(x * w) where A is amplitude and w is frequency
		waves += amplitude * value_noise(uv * frequency_factor); // uv is frequency
		uv *= user_frequency_increment;
		amplitude *= user_amplitude_decrement;
	}
	return waves;
}

// Where Domain Warping happens.
void fragment() {
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 uv = FRAGCOORD.xy / resolution; // Same as SCREEN_UV
	uv.y = 1.0 - uv.y; // Invert Y coord
	uv.x *= resolution.x / resolution.y; // Adjust ratio

	//fBm's that are going to warp the base noise.
	vec2 warper1 = vec2(0.0);
	warper1.x = fbm(uv + 2.4); // Random numbers
	warper1.y = fbm(uv * 0.842);

	vec2 warper2 = vec2(0.0);
	warper2.x = fbm(uv + warper1) + user_speed;
	warper2.y = fbm(uv + warper1 * 1.48) + user_speed;

	vec3 color = vec3(0.0);

	if (!user_color_mix) {
		color = vec3(fbm(uv + warper2) * user_color.rgb);
	}
	else {
		float r_channel = fbm(uv + warper2 * 0.82) * user_color.r;
		float g_channel = fbm(uv + warper2 * 1.32) * user_color.g;
		float b_channel = fbm(uv + warper2) * user_color.b;
		color = vec3(r_channel, g_channel, b_channel);
	}

	COLOR = vec4(color, user_color.a);
}
