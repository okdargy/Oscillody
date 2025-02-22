// This small file (blur.gdshader) is not under the GPL.
// It is not, and should not be licensed, neither copyrightable.
// I can't claim this code. You're free to use the code in this file however you want,
// EXCEPT PARTS THAT HAVE A SPECIFIED COPYRIGHT AND LICENSE. Those are not fully my work,
// and their licenses must be respected.

shader_type canvas_item;

// This shader is used for blurring.

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_strength : hint_range(0, 5);

void fragment() {
	// Blurring using LoD
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, blur_strength);
	COLOR = color;
}
