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

# This is the main utility script, used for getting audio sample, modify data for waveform display,
# logging events, advanced settings, and more. It is also a singleton (autoload).

#region SIGNALS ##################################

signal audio_paused
signal audio_played
signal audio_stopped
signal audio_finished
signal audio_pos_changed

signal audio_file_selected
signal new_audio_master_selected
signal icon_file_selected
signal image_file_selected

signal new_preset_saved

# Checking for the render window via Windows' Process ID.
signal pid_opened
signal pid_closed

signal close_requested

signal update_visualizer # Emitted almost every time there's a change (window size, UI, etc)

#endregion ##################################

#region PATHS AND VIDEO SETTINGS ##################################

var log_path: String = OS.get_executable_path().get_base_dir() + "/Log/"
var log_file: String = "log"
var log_access: FileAccess

var settings_path: String = OS.get_executable_path().get_base_dir() + "/Settings/"
var settings_file: String = "settings"

var video_filename: String = ""
var video_output_full_path: String

var ffmpeg_path: String = ""

var temp_path: String = OS.get_executable_path().get_base_dir() + "/Temp/"

#endregion ##################################

#region WAVEFORM VARIABLES ##################################

# Should be changed to 800 or slightly more if there are noticeable stutters. Change buffer length accordingly.
const SAMPLE_AMOUNT_FIXED: int = 1024
# Used if user's FPS is often and/or severely under 60.
@onready var sample_amount_variable: int

var sample_amount: int = SAMPLE_AMOUNT_FIXED:
	set(new_sample_amount):
		sample_amount = new_sample_amount
		update_visualizer.emit()

var low_specs_mode: bool = false
var load_low_specs_mode: bool = false

var buffer_queue_size: int = 4
var new_buffer_queue_size: int = 4

var buffer_queue_list: Array = [[], [], [], [], []]
var audio_frame_buffers: Array = [[], [], [], [], []] # Master One Stem is last

#endregion ##################################

#region SPECTRUM VARIABLES ##################################

var audio_spectrum_inst: AudioEffectSpectrumAnalyzerInstance
var energy: float
var cur_mag: float
var prev_mag: float

#endregion ##################################

#region WINDOW ##################################

@onready var window_size: Vector2i:
	set(new_value):
		if new_value != window_size:
			window_size = new_value
			update_visualizer.emit()

#endregion ##################################

#region PLAYER CONTROLS ##################################

var audio_playing: bool = false
var new_volume_display: int = 100
var new_volume_in_db: float = 1.0
var audio_duration: float = 0.0
var audio_position: float = 0.0
var audio_was_stopped: bool = false
var loop_enabled: bool = false
var new_audio_pos_from_seek: float

#endregion ##################################

#region GUI VARIABLES ##################################

var can_pause_with_spacebar: bool

#endregion ##################################

#region PID ##################################

# Windows' Process ID.
var process_id: int:
	set(new_pid):
		process_id = new_pid
		logger("New PID: " + str(new_pid))
		pid_opened.emit()

#endregion ##################################

#region COPYING VARIABLES ##################################

var number_of_stems: int = GlobalVariables.number_of_stems
var waveform_configs: Array = GlobalVariables.waveform_configs
var waveform_colors: Array = GlobalVariables.waveform_colors
var waveform_thickness: int = GlobalVariables.waveform_thickness
var vertical_layout: bool = GlobalVariables.vertical_layout

#endregion ##################################

func _ready() -> void:
	if window_size == null:
		window_size = Vector2i.ZERO
	else:
		if not OS.has_feature("movie"):
			window_size = DisplayServer.window_get_size()
		else:
			window_size = Vector2i(2560, 1440)
	
	if OS.has_feature("editor"):
		log_path = "user://LogDebug/"
		settings_path = "user://SettingsDebug/"
		temp_path = "user://Temp/"
	
	if OS.has_feature("movie"):
		logger("Session started (render process).")
	else:
		logger("Session started (main process).")
	
	load_settings()
	
	update_visualizer.connect(update_utils)
	
	if buffer_queue_size != new_buffer_queue_size:
		buffer_queue_size = new_buffer_queue_size
	
	if load_low_specs_mode and not OS.has_feature("movie"):
		low_specs_mode = true
	
	if not DirAccess.dir_exists_absolute(MainUtils.temp_path):
		var err: Error = DirAccess.make_dir_absolute(MainUtils.temp_path)
		if err:
			MainUtils.logger("Could not recreate Temp folder. Error: " + error_string(err), true, true)
	
	logger(
		"Launch settings: Buffer Queue Size = " + str(buffer_queue_size) + \
		" - Low Specs Mode = " + str(low_specs_mode) + " (must be false on render sessions)"
		)
	
	if not FileAccess.file_exists(ffmpeg_path) and ffmpeg_path != "":
		logger("FFmpeg path is now invalid. Select the FFmpeg executable again.", true)
	
	sample_amount_variable = roundi(AudioServer.get_mix_rate() / Engine.get_frames_per_second())
	
	cur_mag = 0.0
	prev_mag = float(cur_mag)
	audio_spectrum_inst = AudioServer.get_bus_effect_instance(6, 0)
	
	update_utils()

func _process(_delta: float) -> void:
	update_copies()
	
	if DisplayServer.window_get_size() != null or DisplayServer.window_get_size() != Vector2i(0, 0):
		if not OS.has_feature("movie"):
			window_size = DisplayServer.window_get_size()
		else:
			window_size = Vector2i(2560, 1440)
	
	if low_specs_mode:
		sample_amount_variable = roundi(AudioServer.get_mix_rate() / Engine.get_frames_per_second())
		sample_amount = sample_amount_variable
	else:
		sample_amount = SAMPLE_AMOUNT_FIXED
	
	load_buffers()
	
	if audio_playing:
		spectrum()

func update_copies() -> void:
	number_of_stems = GlobalVariables.number_of_stems
	waveform_configs = GlobalVariables.waveform_configs
	waveform_colors = GlobalVariables.waveform_colors
	waveform_thickness = GlobalVariables.waveform_thickness
	vertical_layout = GlobalVariables.vertical_layout

func load_buffers() -> void:
	for buffer_idx in number_of_stems:
		if number_of_stems > 1:
			buffer_idx += 1
		else:
			buffer_idx = 5
		var audio_capture: AudioEffectCapture = AudioServer.get_bus_effect(buffer_idx, 0)
		
		if audio_capture.can_get_buffer(sample_amount):
			var temp_buffer: PackedVector2Array = audio_capture.get_buffer(sample_amount)
			var audio_frame_buffer_averaged: Array
			match buffer_idx:
				1:
					audio_frame_buffers[buffer_idx - 1] = add_to_queue(
						buffer_idx,
						temp_buffer,
						audio_frame_buffer_averaged
						)
				2:
					audio_frame_buffers[buffer_idx - 1] = add_to_queue(
						buffer_idx,
						temp_buffer,
						audio_frame_buffer_averaged
						)
				3:
					audio_frame_buffers[buffer_idx - 1] = add_to_queue(
						buffer_idx,
						temp_buffer,
						audio_frame_buffer_averaged
						)
				4:
					audio_frame_buffers[buffer_idx - 1] = add_to_queue(
						buffer_idx,
						temp_buffer,
						audio_frame_buffer_averaged
						)
				5:
					audio_frame_buffers[buffer_idx - 1] = add_to_queue(
						buffer_idx,
						temp_buffer,
						audio_frame_buffer_averaged
						)

# Adds audio samples to a queue, so that sample history is shown on the waveform.
# The higher the buffer queue size, the longer the history stays on screen.
func add_to_queue(buffer_idx: int, temporary_buffer: PackedVector2Array, averaged: Array) -> Array:
	buffer_idx -= 1
	for frame in temporary_buffer:
		var avg_frame: float = (frame.x + frame.y) / 2.0
		averaged.append(avg_frame)
	buffer_queue_list[buffer_idx].append_array([averaged.duplicate()])
	averaged.clear()
	if buffer_queue_list[buffer_idx].size() > buffer_queue_size:
		buffer_queue_list[buffer_idx].remove_at(0)
	return buffer_queue_list[buffer_idx]

# Converts audio file into playable object, using the file's bytes.
func convert_to_playable(audio_path: String) -> AudioStreamMP3:
	var stream: AudioStreamMP3 = AudioStreamMP3.new()
	if audio_path != "":
		var file: FileAccess = FileAccess.open(audio_path, FileAccess.READ)
		if file == null:
			logger("Audio file is null: " + audio_path + ". Error: " + error_string(FileAccess.get_open_error()), true)
			return
		var bytes: PackedByteArray = file.get_buffer(file.get_length())
		if bytes.is_empty():
			logger("Audio file returned no bytes.", true)
			return
		stream = AudioStreamMP3.new()
		stream.data = bytes
		file.close()
		logger("Audio file converted to playable object: " + audio_path)
		return stream
	else:
		logger("Audio path is empty.", true, true)
		return

func update_utils() -> void:
	update_copies()
	for waveform in number_of_stems:
		waveform_configs[waveform][1] = find_x_spacing(waveform)
		waveform_configs[waveform][2] = find_y_position(waveform)
		waveform_configs[waveform][3] = waveform_colors[waveform]
		waveform_configs[waveform][4] = waveform_thickness

# Finds x origin for each waveform,
# and how far apart the points of each waveform line has to be to fit the screen.
func find_x_spacing(waveform: int) -> float:
	var window_width: float = window_size.x / float(sample_amount * buffer_queue_size - 1)
	var half_window_width: float = (window_size.x / 2.0) / float(sample_amount * buffer_queue_size - 1)
	
	if not vertical_layout:
		if number_of_stems <= 2:
			return window_width
		elif number_of_stems == 3 and waveform == 2:
			return window_width
		else:
			return half_window_width
	else:
		return window_width

func find_y_position(waveform: int) -> int:
	var top_of_screen: int = window_size.y / 4
	var bottom_of_screen: int = window_size.y / 4 * 3
	var screen_divs: int = int(window_size.y / float(number_of_stems))
	var y_pos_per_waveform: int = screen_divs * (waveform + 1) - (screen_divs / 2)
	
	if not vertical_layout:
		if number_of_stems <= 2:
			return y_pos_per_waveform
		else:
			if waveform <= 1:
				return top_of_screen
			else:
				return bottom_of_screen
	else:
		return y_pos_per_waveform

# Gets magnitude within a specific frequency range.
func spectrum() -> void:
	var min_db: float = float(GlobalVariables.min_db_level * -1.0)
	var smoothing_factor: float = (6.0 - GlobalVariables.smoothing_amount + 1.0) * 0.01
	
	var begin_range: int = 20
	var end_range: int = 80
	
	# This method has a known issue of returning jittered values. https://github.com/godotengine/godot/issues/67650
	# Also read: https://github.com/godotengine/godot/issues/38215
	var magnitude_vec2: Vector2 = audio_spectrum_inst.get_magnitude_for_frequency_range(
		begin_range, end_range, AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_MAX
		)
	var magnitude: float = float(magnitude_vec2.x + magnitude_vec2.y) / 2.0
	# Makes energy have values above 0 if magnitude (in dB) + minimum dB is lesser than min dB.
	# Example: 10 (calculated as positive here) + -29.999999 (0.001 linear) = -19.999999 -> / 10 = < 0.0
	# 90 + -29.999999 = 60.00001 -> / 90 = > 0.0
	energy = clampf(float((min_db + linear_to_db(magnitude))) / min_db, 0.0, 1.0)
	cur_mag = energy
	
	# Applying smoothing (fixed decay over time).
	if cur_mag < prev_mag:
		cur_mag = prev_mag - smoothing_factor
	
	prev_mag = float(cur_mag)

func logger(event: String, is_error: bool = false, restart_needed: bool = false) -> void:
	var formatted_log_path: String = log_path + log_file + ".log"
	if not DirAccess.dir_exists_absolute(log_path):
		var err: Error = DirAccess.make_dir_absolute(log_path)
		if err:
			printerr(error_string(err))
	if not FileAccess.file_exists(formatted_log_path):
		log_access = FileAccess.open(formatted_log_path, FileAccess.WRITE)
		if log_access == null:
			printerr(error_string(FileAccess.get_open_error()))
		log_access.close()
	log_access = FileAccess.open(formatted_log_path, FileAccess.READ_WRITE)
	var event_history: String = log_access.get_as_text()
	if is_error:
		log_access.store_string(
			event_history + "ERROR! " + Time.get_datetime_string_from_system(false, true) + " - " + event + "\n"
			)
		if restart_needed:
			OS.alert(
				event + \
				"\nYou may have to restart the app, otherwise it might have unexpected behaviors. \
If you think this is a bug, please report it.",
				"An error has occurred."
				)
		else:
			OS.alert(event + " If you think this is a bug, please report it.", "An error has occurred.")
		printerr("ERROR! " + event)
	else:
		log_access.store_string(
			event_history + Time.get_datetime_string_from_system(false, true) + " - " + event + "\n"
			)
		print(event)
	log_access.flush()

func save_settings(path: String = settings_path) -> void:
	if not DirAccess.dir_exists_absolute(settings_path):
		var err: Error = DirAccess.make_dir_absolute(settings_path)
		if err:
			logger("Could not recreate Settings folder. Error: " + error_string(err), true, true)
	var save_data: Dictionary = {
		"new_buffer_queue_size": new_buffer_queue_size,
		"load_low_specs_mode": load_low_specs_mode,
		"ffmpeg_path": ffmpeg_path
	}
	var formatted_path: String = path + settings_file + ".json"
	var save_json: FileAccess = FileAccess.open(formatted_path, FileAccess.WRITE)
	if save_json == null:
		logger(
			"Settings file in " + path + " is null. Not saved. Error: " + error_string(FileAccess.get_open_error())
			, true
			)
		return
	save_json.store_line(JSON.stringify(save_data, "\t"))
	save_json.close()
	logger("Settings saved.")

func load_settings(settings: String = settings_file) -> void:
	if not DirAccess.dir_exists_absolute(settings_path):
		var err: Error = DirAccess.make_dir_absolute(settings_path)
		if err:
			logger("Could not recreate Settings folder. Error: " + error_string(err), true, true)
		return
	if ".json" in settings:
		settings = settings.replace(".json", "")
	var path: String = settings_path + settings + ".json"
	if FileAccess.file_exists(path):
		var json_text: String = FileAccess.get_file_as_string(path)
		if json_text.is_empty():
			logger("Settings file is empty.", true, true)
			return
		var save_data: Variant = JSON.parse_string(json_text)
		if save_data == null:
			logger("Could not parse settings file.", true, true)
			return
		new_buffer_queue_size = save_data["new_buffer_queue_size"]
		ffmpeg_path = save_data["ffmpeg_path"]
		if not OS.has_feature("movie"):
			load_low_specs_mode = save_data["load_low_specs_mode"]
		logger("Settings loaded.")
	else:
		logger("Settings file in " + settings_path + " does not exist.", true, true)

#region MAIN UTILS BUILT-IN SIGNAL FUNCTIONS ##################################

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		close_requested.emit()

#endregion ##################################
