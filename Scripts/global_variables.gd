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

extends Node

# This script is a singleton (autoload) and holds properties mostly related to how the visualizer looks.

#region JSON, PRESETS, AND PATHS ##################################

var presets_in_selector: PackedStringArray = []
var preset_name: String = "Default"

var master_audio_path: String:
	set(new_path):
		master_audio_path = new_path
		MainUtils.audio_file_selected.emit()
		MainUtils.new_audio_master_selected.emit()
var stem_1_audio_path: String:
	set(new_path):
		stem_1_audio_path = new_path
		if not new_path == "":
			MainUtils.audio_file_selected.emit()
var stem_2_audio_path: String:
	set(new_path):
		stem_2_audio_path = new_path
		if not new_path == "":
			MainUtils.audio_file_selected.emit()
var stem_3_audio_path: String:
	set(new_path):
		stem_3_audio_path = new_path
		if not new_path == "":
			MainUtils.audio_file_selected.emit()
var stem_4_audio_path: String:
	set(new_path):
		stem_4_audio_path = new_path
		if not new_path == "":
			MainUtils.audio_file_selected.emit()

var presets_path: String = OS.get_executable_path().get_base_dir() + "/Presets/"
var render_info_path: String = OS.get_executable_path().get_base_dir() + "/Render Info/"
var assets_path: String = OS.get_executable_path().get_base_dir() + "/Assets/"
var audio_for_render: String = "audio_for_render"
var render_preset_filename: String = "render_preset"

#endregion ##################################

#region THEME ##################################

var number_of_stems: int = 1
var vertical_layout: bool = false

var title: String = ""
var title_fonts_in_selector: PackedStringArray = OS.get_system_fonts()
var title_font: String = "Calibri"
var title_font_bold: bool = false
var title_font_italic: bool = false
var title_pos: Vector2i = Vector2i(50, 96)
var title_color: Color = Color.WHITE
var title_size: int = 50
var title_shadow_color: Color = Color.BLACK
var title_shadow_pos: Vector2i = Vector2i(-4, 4)
var title_outline_color: Color = Color.BLACK
var title_outline_size: int = 0

var background_types_in_selector: Array = ["Solid Colors", "Image", "Shader"]
var background_type: String = background_types_in_selector[0]
var background_colors: Array = [
	Color(0.061, 0.045, 0.18),
	Color(0.061, 0.045, 0.18),
	Color(0.061, 0.045, 0.18),
	Color(0.061, 0.045, 0.18)
	]
var image_path: String:
	set(new_path):
		image_path = new_path
		MainUtils.image_file_selected.emit()
var image_size: int = 1
var image_opacity: int = 100
var image_blur: int = 0
var background_shader_color_mix: bool = false
var background_shader_color: Color = Color(0.0, 0.0, 1.0, 1.0)
var background_shader_frequency_factor: float = 2.0
var background_shader_blur: int = 0
var background_shader_amplitude: float = 5.0
var background_shader_speed: float = 2.0
var background_shader_octaves: int = 6
var background_shader_frequency_increment: float = 2.0
var background_shader_amplitude_decrement: float = 5.0

var divider_colors: Array = [Color.WHITE, Color.WHITE]
var divider_thickness: int = 2

var icon_enabled: bool = false
var icon_path: String:
	set(new_path):
		icon_path = new_path
		MainUtils.icon_file_selected.emit()
var icon_color: Color = Color.WHITE
var icon_size: int = 3

var post_processing_types_in_selector: Array = [
	"Bloom",
	"Chromatic Aberration",
	"Vignette",
	"Grain"
	]
var post_processing_type: String = post_processing_types_in_selector[0]
var bloom_amount: float = 0.0
var bloom_reaction: bool = false
var chromatic_aberration_strength: float = 0.0
var chromatic_aberration_reaction: bool = false
var vignette_color: Color = Color(0.0, 0.0, 0.0, 0.0)
var vignette_size: float = 1.2
var vignette_sharpness: float = 12.0
var vignette_reaction: bool = false
var grain_static: bool = false
var grain_opacity: int = 0

var audio_reaction_enabled: bool = false
var audio_reaction_targets: Dictionary = {
	"Title": false,
	"Background": false,
	"Icon": false,
	"Post-Processing": false
	}
var min_db_level: int = -50
var reaction_strength: int = 4
var smoothing_amount: int = 3

#endregion ##################################

#region WAVEFORM VARIABLES ##################################

var waveform_colors: Array = [Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE]
var waveform_thickness: int = 2
var waveform_height: float = 4.0
var max_waveform_height: float = float(waveform_height)

# Waveform number, X spacing, Y position, color, thickness
var waveform_configs: Array = [
	[1, 0.0, 0, waveform_colors[0], waveform_thickness],
	[2, 0.0, 0, waveform_colors[1], waveform_thickness],
	[3, 0.0, 0, waveform_colors[2], waveform_thickness],
	[4, 0.0, 0, waveform_colors[3], waveform_thickness]
]

#endregion ##################################

func _init() -> void:
	if OS.has_feature("movie"):
		ProjectSettings.set_setting("display/window/stretch/mode", "viewport")
		ProjectSettings.set_setting("display/window/size/viewport_width", 2560)
		ProjectSettings.set_setting("display/window/size/viewport_height", 1440)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)

func _ready() -> void:
	if title_fonts_in_selector.is_empty():
		MainUtils.logger("Could not load system fonts.", true, true)
	title_fonts_in_selector.sort()
	
	if OS.has_feature("editor"):
		presets_path = "user://PresetsDebug/"
		render_info_path = "user://RenderInfoDebug/"
		assets_path = "user://Assets/"
	
	var preset_arr: Array = DirAccess.get_files_at(presets_path)
	# Better sorting. Array element 'a' is compared to 'b' and put behind if less than 0 (returns a 'true')
	preset_arr.sort_custom(func(a: String, b: String) -> bool: return a.naturalnocasecmp_to(b) < 0)
	for file: String in preset_arr:
		if file.ends_with(".json") and file != "render_preset.json":
			var preset_to_add: String = file.replace(".json", "")
			presets_in_selector.append(preset_to_add)
		else:
			continue
	
	check_for_dirs()

func check_for_dirs() -> Error:
	if not DirAccess.dir_exists_absolute(presets_path):
		var err: Error = DirAccess.make_dir_absolute(presets_path)
		if err:
			MainUtils.logger("Could not recreate Presets folder. Error: " + error_string(err), true, true)
			return FAILED
	
	if not DirAccess.dir_exists_absolute(render_info_path):
		var err: Error = DirAccess.make_dir_absolute(render_info_path)
		if err:
			MainUtils.logger("Could not recreate Presets folder. Error: " + error_string(err), true, true)
			return FAILED
	return OK

func save_audio(path: String = render_info_path) -> void:
	check_for_dirs()
	var save_data: Dictionary = {
		"master_audio_path": master_audio_path,
		"stem_1_audio_path": stem_1_audio_path,
		"stem_2_audio_path": stem_2_audio_path,
		"stem_3_audio_path": stem_3_audio_path,
		"stem_4_audio_path": stem_4_audio_path
		}
	var formatted_path: String = path + audio_for_render + ".json"
	var save_json: FileAccess = FileAccess.open(formatted_path, FileAccess.WRITE)
	if save_json == null:
		MainUtils.logger("Could not save audio. Error: " + error_string(FileAccess.get_open_error()), true, true)
		return
	save_json.store_line(JSON.stringify(save_data, "\t"))
	save_json.close()
	
	MainUtils.logger("Audio saved.")

func load_audio(audio_files_to_use: String = audio_for_render) -> void:
	check_for_dirs()
	var path: String = render_info_path + audio_files_to_use + ".json"
	if FileAccess.file_exists(path):
		var json_text: String = FileAccess.get_file_as_string(path)
		if json_text.is_empty():
			MainUtils.logger("Render audio file is empty. Close the render window.", true, true)
			return
		var save_data: Variant = JSON.parse_string(json_text)
		if save_data == null:
			MainUtils.logger("Could not parse render audio file. Close the render window.", true, true)
			return
		master_audio_path = save_data["master_audio_path"]
		stem_1_audio_path = save_data["stem_1_audio_path"]
		stem_2_audio_path = save_data["stem_2_audio_path"]
		stem_3_audio_path = save_data["stem_3_audio_path"]
		stem_4_audio_path = save_data["stem_4_audio_path"]
		MainUtils.logger("Audio loaded.")
	else:
		MainUtils.logger(
			"Audio-related JSON file does not exist in " + render_info_path + ". Close the render window.",
			true,
			true
			)

func save_preset(save_preset_name: String, path: String = presets_path) -> void:
	check_for_dirs()
	var save_data: Dictionary = {
		"number_of_stems": number_of_stems,
		"vertical_layout": vertical_layout,
		"title": title,
		"title_font": title_font,
		"title_font_bold": title_font_bold,
		"title_font_italic": title_font_italic,
		"title_pos": title_pos,
		"title_color": title_color,
		"title_size": title_size,
		"title_shadow_color": title_shadow_color,
		"title_shadow_pos": title_shadow_pos,
		"title_outline_color": title_outline_color,
		"title_outline_size": title_outline_size,
		"background_type": background_type,
		"background_colors_1": background_colors[0],
		"background_colors_2": background_colors[1],
		"background_colors_3": background_colors[2],
		"background_colors_4": background_colors[3],
		"image_path": image_path,
		"image_size": image_size,
		"image_opacity": image_opacity,
		"image_blur": image_blur,
		"background_shader_color_mix": background_shader_color_mix,
		"background_shader_color": background_shader_color,
		"background_shader_frequency_factor": background_shader_frequency_factor,
		"background_shader_blur": background_shader_blur,
		"background_shader_amplitude": background_shader_amplitude,
		"background_shader_speed": background_shader_speed,
		"background_shader_octaves": background_shader_octaves,
		"background_shader_frequency_increment": background_shader_frequency_increment,
		"background_shader_amplitude_decrement": background_shader_amplitude_decrement,
		"divider_colors_1": divider_colors[0],
		"divider_colors_2": divider_colors[1],
		"divider_thickness": divider_thickness,
		"icon_enabled": icon_enabled,
		"icon_path": icon_path,
		"icon_color": icon_color,
		"icon_size": icon_size,
		"bloom_amount": bloom_amount,
		"bloom_reaction": bloom_reaction,
		"chromatic_aberration_strength": chromatic_aberration_strength,
		"chromatic_aberration_reaction": chromatic_aberration_reaction,
		"vignette_color": vignette_color,
		"vignette_size": vignette_size,
		"vignette_sharpness": vignette_sharpness,
		"vignette_reaction": vignette_reaction,
		"grain_static": grain_static,
		"grain_opacity": grain_opacity,
		"audio_reaction_enabled": audio_reaction_enabled,
		"audio_reaction_targets": audio_reaction_targets,
		"min_db_level": min_db_level,
		"reaction_strength": reaction_strength,
		"smoothing_amount": smoothing_amount,
		"waveform_colors_1": waveform_colors[0],
		"waveform_colors_2": waveform_colors[1],
		"waveform_colors_3": waveform_colors[2],
		"waveform_colors_4": waveform_colors[3],
		"waveform_thickness": waveform_thickness,
		"waveform_height": waveform_height
	}
	var formatted_path: String
	formatted_path = path + save_preset_name + ".json"
	var save_json: FileAccess = FileAccess.open(formatted_path, FileAccess.WRITE)
	if save_json == null:
		MainUtils.logger("Could not save preset. Error: " + error_string(FileAccess.get_open_error()), true, true)
		return
	save_json.store_line(JSON.stringify(save_data, "\t"))
	save_json.close()
	
	MainUtils.logger("Preset succesfully saved: " + formatted_path)

func str_to_vec(vector_as_str: String) -> Variant:
	var vec_arr: Array = vector_as_str.replace("(", "").replace(")", "").split(", ")
	if vec_arr.size() == 2:
		return Vector2i(int(vec_arr[0]), int(vec_arr[1]))
	elif vec_arr.size() == 4:
		return Color(float(vec_arr[0]), float(vec_arr[1]), float(vec_arr[2]), float(vec_arr[3]))
	else:
		return

func load_preset(preset: String) -> void:
	var err: Error = check_for_dirs()
	if err:
		MainUtils.logger("Could not find preset folder.", true, true)
	if ".json" in preset:
		preset = preset.replace(".json", "")
	var path: String
	if preset == "render_preset":
		path = render_info_path + preset + ".json"
	else:
		path = presets_path + preset + ".json"
	if FileAccess.file_exists(path):
		var json_text: String = FileAccess.get_file_as_string(path)
		if json_text.is_empty():
			MainUtils.logger("Preset file is empty.", true)
			return
		var save_data: Variant = JSON.parse_string(json_text)
		if save_data == null:
			MainUtils.logger("Could not parse preset.", true, true)
			return
		number_of_stems = save_data["number_of_stems"]
		vertical_layout = save_data["vertical_layout"]
		title = save_data["title"]
		title_font = save_data["title_font"]
		title_font_bold = save_data["title_font_bold"]
		title_font_italic = save_data["title_font_italic"]
		title_pos = str_to_vec(save_data["title_pos"])
		title_color = str_to_vec(save_data["title_color"])
		title_size = save_data["title_size"]
		title_shadow_color = str_to_vec(save_data["title_shadow_color"])
		title_shadow_pos = str_to_vec(save_data["title_shadow_pos"])
		title_outline_color = str_to_vec(save_data["title_outline_color"])
		title_outline_size = save_data["title_outline_size"]
		background_type = save_data["background_type"]
		background_colors[0] = str_to_vec(save_data["background_colors_1"])
		background_colors[1] = str_to_vec(save_data["background_colors_2"])
		background_colors[2] = str_to_vec(save_data["background_colors_3"])
		background_colors[3] = str_to_vec(save_data["background_colors_4"])
		image_path = save_data["image_path"]
		image_size = save_data["image_size"]
		image_opacity = save_data["image_opacity"]
		image_blur = save_data["image_blur"]
		background_shader_color_mix = save_data["background_shader_color_mix"]
		background_shader_color = str_to_vec(save_data["background_shader_color"])
		background_shader_frequency_factor = save_data["background_shader_frequency_factor"]
		background_shader_blur = save_data["background_shader_blur"]
		background_shader_amplitude = save_data["background_shader_amplitude"]
		background_shader_speed = save_data["background_shader_speed"]
		background_shader_octaves = save_data["background_shader_octaves"]
		background_shader_frequency_increment = save_data["background_shader_frequency_increment"]
		background_shader_amplitude_decrement = save_data["background_shader_amplitude_decrement"]
		divider_colors[0] = str_to_vec(save_data["divider_colors_1"])
		divider_colors[1] = str_to_vec(save_data["divider_colors_2"])
		divider_thickness = save_data["divider_thickness"]
		icon_enabled = save_data["icon_enabled"]
		icon_path = save_data["icon_path"]
		icon_color = str_to_vec(save_data["icon_color"])
		icon_size = save_data["icon_size"]
		bloom_amount = save_data["bloom_amount"]
		bloom_reaction = save_data["bloom_reaction"]
		chromatic_aberration_strength = save_data["chromatic_aberration_strength"]
		chromatic_aberration_reaction = save_data["chromatic_aberration_reaction"]
		vignette_color = str_to_vec(save_data["vignette_color"])
		vignette_size = save_data["vignette_size"]
		vignette_sharpness = save_data["vignette_sharpness"]
		vignette_reaction = save_data["vignette_reaction"]
		grain_static = save_data["grain_static"]
		grain_opacity = save_data["grain_opacity"]
		audio_reaction_enabled = save_data["audio_reaction_enabled"]
		audio_reaction_targets = save_data["audio_reaction_targets"]
		min_db_level = save_data["min_db_level"]
		reaction_strength = save_data["reaction_strength"]
		smoothing_amount = save_data["smoothing_amount"]
		waveform_colors[0] = str_to_vec(save_data["waveform_colors_1"])
		waveform_colors[1] = str_to_vec(save_data["waveform_colors_2"])
		waveform_colors[2] = str_to_vec(save_data["waveform_colors_3"])
		waveform_colors[3] = str_to_vec(save_data["waveform_colors_4"])
		waveform_thickness = save_data["waveform_thickness"]
		waveform_height = save_data["waveform_height"]
		MainUtils.logger("Preset loaded: " + preset)
	else:
		MainUtils.logger("Preset \"" + preset + "\" does not exist in " + presets_path + ".", true)
