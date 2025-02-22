// This small file (vignette.gdshader) is not under the GPL.
// It is not, and should not be licensed, neither copyrightable.
// I can't claim this code. You're free to use the code in this file however you want,
// EXCEPT PARTS THAT HAVE A SPECIFIED COPYRIGHT AND LICENSE. Those are not fully my work,
// and their licenses must be respected.

shader_type canvas_item;

// This shader is used for a vignette effect.

uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform float vignette_size : hint_range(0.0, 2.0) = 1.2;
uniform float vignette_sharpness : hint_range(0.0, 20.0) = 12.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	uv.y = 1.0 - uv.y;

	uv = 1.0 - (1.0 - uv) * uv;
	float vignette_mono = clamp(uv.x * uv.y * vignette_size, 0.0, 1.0);
	vignette_mono = pow(vignette_mono, vignette_sharpness);
	vec4 vignette = vec4(vignette_mono * vignette_color);

	COLOR = vec4(vignette);
}
