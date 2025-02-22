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

extends Control

# This script handles the text the user can input on the visualizer.

#region NODES ##################################

@onready var title: Label = $Title

#endregion ##################################

#region TITLE CONTROL VARIABLES ##################################

var default_title_pos: Vector2
var default_weight: int = 400
var bold_weight: int = 700
var max_pos_in_ui: float = 100.0
var title_reaction_enabled: bool = false
var max_resolution: Vector2
var compare_length: Vector2

var mag_compensation: float = 6.0
var title_shake_energy: Vector2

@onready var title_settings: LabelSettings = title.get_label_settings()
@onready var font_type: SystemFont = title_settings.get_font()

#endregion ##################################

func _ready() -> void:
	MainUtils.update_visualizer.connect(update_title)
	update_title()

func update_title() -> void:
	if GlobalVariables.title != "":
		visible = true
	else:
		visible = false
	
	font_type.set_font_names(GlobalVariables.title_fonts_in_selector)
	font_type.font_names[0] = GlobalVariables.title_font
	
	title_settings.set_font_color(GlobalVariables.title_color)
	title_settings.set_shadow_color(GlobalVariables.title_shadow_color)
	title_settings.set_shadow_offset(GlobalVariables.title_shadow_pos)
	title_settings.set_outline_color(GlobalVariables.title_outline_color)
	title_settings.set_outline_size(GlobalVariables.title_outline_size)

func _process(_delta: float) -> void:
	if OS.has_feature("movie"):
		title.size = Vector2i(2560, 1440) * 2
	else:
		title.size = MainUtils.window_size * 2
	
	title.text = GlobalVariables.title
	
	if GlobalVariables.title_font_bold:
		font_type.set_font_weight(bold_weight)
	else:
		font_type.set_font_weight(default_weight)
	
	font_type.set_font_italic(GlobalVariables.title_font_italic)
	
	title_settings.set_font_size(GlobalVariables.title_size)
	
	default_title_pos = Vector2(
		float(MainUtils.window_size.x) * (float(GlobalVariables.title_pos.x) / max_pos_in_ui) - title.size.x / 2.0,
		float(MainUtils.window_size.y) * ((max_pos_in_ui - float(GlobalVariables.title_pos.y)) / max_pos_in_ui) \
		- title.size.y / 2.0 - 0.5
		)
	
	if OS.has_feature("movie"):
		max_resolution = Vector2(2560.0, 1440.0)
	else:
		max_resolution = DisplayServer.screen_get_size()
	compare_length = Vector2(MainUtils.window_size) / max_resolution
	if compare_length.x >= compare_length.y:
		title.scale = Vector2(compare_length.y, compare_length.y)
	else:
		title.scale = Vector2(compare_length.x, compare_length.x)
	
	title.pivot_offset = title.size / 2.0
	
	if not title_reaction_enabled:
		title.set_position(default_title_pos)

func title_reaction(mag: float, strength: float) -> void:
	if title_reaction_enabled:
		title.set_position(default_title_pos)
	
	title_shake_energy = Vector2(randf_range(
		-mag * mag_compensation, mag * mag_compensation
		) * strength,
		randf_range(
		-mag * mag_compensation, mag * mag_compensation
		) * strength)
	
	if MainUtils.audio_playing:
		title.position += title_shake_energy
	else:
		title.set_position(default_title_pos)
