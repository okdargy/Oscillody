# Oscillody
# Copyright (C) 2025 Akosmo

# This file is part of Oscillody. Unless specified otherwise, it is under the license below:

# Oscillody is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free Software Foundation,
# either version 3 of the License, or any later version.

# Oscillody is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with Oscillody.
# If not, see <https://www.gnu.org/licenses/>.

extends CanvasLayer

# This script handles post-processing (except bloom) (shaders are in gdshader files).

#region NODES ##################################

@onready var chromatic_aberration: ColorRect = $ChromaticAberrationCanvas/ChromaticAberration
@onready var vignette: ColorRect = $VignetteCanvas/Vignette
@onready var grain: ColorRect = $GrainCanvas/Grain
@onready var grain_texture: TextureRect = $GrainTexture

#endregion ##################################

#region POST-PROCESSING VARIABLES ##################################

var reduce_strength_ca: float = 0.001
var reduce_strength_v: float = 0.1

#endregion ##################################

func _ready() -> void:
	MainUtils.update_visualizer.connect(update_post_processing)
	update_post_processing()

func update_post_processing() -> void:
	if GlobalVariables.chromatic_aberration_strength > 0.0:
		chromatic_aberration.visible = true
		chromatic_aberration.get_material().set_shader_parameter("strength",
			lerpf(0.0005, 0.005, GlobalVariables.chromatic_aberration_strength * 0.1)
			)
	else:
		chromatic_aberration.visible = false
	
	if GlobalVariables.vignette_color.a > 0.0:
		vignette.visible = true
		vignette.get_material().set_shader_parameter("vignette_color", GlobalVariables.vignette_color)
		vignette.get_material().set_shader_parameter("vignette_size", GlobalVariables.vignette_size)
		vignette.get_material().set_shader_parameter("vignette_sharpness",
			GlobalVariables.vignette_sharpness
			)
	else:
		vignette.visible = false
	
	if GlobalVariables.grain_opacity > 0:
		if not GlobalVariables.grain_static:
			grain.visible = true
			grain_texture.visible = false
			grain.get_material().set_shader_parameter("opacity", GlobalVariables.grain_opacity * 0.01)
		else:
			grain_texture.visible = true
			grain.visible = false
			grain_texture.get_material().set_shader_parameter("opacity", GlobalVariables.grain_opacity * 0.01)
	else:
		grain.visible = false
		grain_texture.visible = false

func post_processing_reaction(mag: float, strength: float) -> void:
	if GlobalVariables.chromatic_aberration_reaction:
		chromatic_aberration.get_material().set_shader_parameter("strength",
			lerpf(0.0005, 0.005, GlobalVariables.chromatic_aberration_strength * 0.1) + mag * reduce_strength_ca \
			* strength
			)
		if not MainUtils.audio_playing:
			chromatic_aberration.get_material().set_shader_parameter("strength",
				lerpf(0.0005, 0.005, GlobalVariables.chromatic_aberration_strength * 0.1)
				)
	
	if GlobalVariables.vignette_reaction:
		vignette.get_material().set_shader_parameter("vignette_size",
			GlobalVariables.vignette_size - mag * reduce_strength_v * strength
			)
		if not MainUtils.audio_playing:
			vignette.get_material().set_shader_parameter("vignette_size",GlobalVariables.vignette_size)
