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

# This script handles the background shader nodes (shaders are in gdshader files).

#region NODES ##################################

@onready var bg_shader_rect: ColorRect = $BGShaderRect
@onready var blur: ColorRect = $Blur

#endregion ##################################

#region SHADER VARIABLES ##################################

# Variable used to increment shader "frames". Used along with shader speed set by the user.
var custom_time: float = 0.0

var reduce_strength: float
var current_speed_on_shader: float
var new_user_speed: float

#endregion ##################################

func _ready() -> void:
	MainUtils.update_visualizer.connect(update_bg_shader_canvas)
	update_bg_shader_canvas()

func _process(_delta: float) -> void:
	if GlobalVariables.background_type == "Shader":
		custom_time = custom_time + 0.002 * GlobalVariables.background_shader_speed
		bg_shader_rect.get_material().set_shader_parameter("user_speed", custom_time)

func update_bg_shader_canvas() -> void:
	if GlobalVariables.background_type == "Shader":
		visible = true
		bg_shader_rect.get_material().set_shader_parameter(
			"user_color_mix", GlobalVariables.background_shader_color_mix
			)
		bg_shader_rect.get_material().set_shader_parameter(
			"user_color", GlobalVariables.background_shader_color
			)
		bg_shader_rect.get_material().set_shader_parameter(
			"user_frequency_factor", GlobalVariables.background_shader_frequency_factor
			)
		bg_shader_rect.get_material().set_shader_parameter(
			"user_amplitude", GlobalVariables.background_shader_amplitude * 0.1
			)
		bg_shader_rect.get_material().set_shader_parameter(
			"user_octaves", GlobalVariables.background_shader_octaves
			)
		bg_shader_rect.get_material().set_shader_parameter(
			"user_frequency_increment",
			GlobalVariables.background_shader_frequency_increment
			)
		bg_shader_rect.get_material().set_shader_parameter(
			"user_amplitude_decrement",
			(10.0 - GlobalVariables.background_shader_amplitude_decrement + 1.0) * 0.1
			)
		if GlobalVariables.background_shader_blur > 0:
			blur.visible = true
			blur.get_material().set_shader_parameter("blur_strength",
			lerpf(0.0, 5.0, GlobalVariables.background_shader_blur * 0.01)
			)
		else:
			blur.visible = false
	else:
		visible = false

func shader_reaction(mag: float, strength: float) -> void:
	if MainUtils.audio_playing:
		reduce_strength = lerpf(0.004, 0.08, GlobalVariables.background_shader_speed * 0.1)
		
		current_speed_on_shader = bg_shader_rect.get_material().get_shader_parameter("user_speed")
		new_user_speed = (current_speed_on_shader + mag * reduce_strength * strength)
		
		custom_time = new_user_speed
	else:
		custom_time = custom_time + 0.002 * GlobalVariables.background_shader_speed
		bg_shader_rect.get_material().set_shader_parameter("user_speed", custom_time)
