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

extends ScrollContainer

# This script handles audio file importing and video exporting.

#region NODES ##################################

@onready var master_file_dialog: FileDialog = %MasterFileDialog
@onready var stem_1_file_dialog: FileDialog = %Stem1FileDialog
@onready var stem_2_file_dialog: FileDialog = %Stem2FileDialog
@onready var stem_3_file_dialog: FileDialog = %Stem3FileDialog
@onready var stem_4_file_dialog: FileDialog = %Stem4FileDialog

@onready var ffmpeg_file_dialog: FileDialog = %FFmpegFileDialog
@onready var export_file_dialog: FileDialog = %ExportFileDialog

@onready var filenames: Label = %Filenames

@onready var ui_anim_player: AnimationPlayer = %UIAnimPlayer

#endregion ##################################

const EXPORT_SCENE = "res://Scenes/visualizer_screen.tscn"

#region PATHS ##################################

var master_filename: String = "NOT SELECTED"
var stem_1_filename: String = "NOT SELECTED"
var stem_2_filename: String = "NOT SELECTED"
var stem_3_filename: String = "NOT SELECTED"
var stem_4_filename: String = "NOT SELECTED"

#endregion ##################################

func _ready() -> void:
	master_file_dialog.set_filters(PackedStringArray(["*.mp3 ; MP3 Files"]))
	stem_1_file_dialog.set_filters(PackedStringArray(["*.mp3 ; MP3 Files"]))
	stem_2_file_dialog.set_filters(PackedStringArray(["*.mp3 ; MP3 Files"]))
	stem_3_file_dialog.set_filters(PackedStringArray(["*.mp3 ; MP3 Files"]))
	stem_4_file_dialog.set_filters(PackedStringArray(["*.mp3 ; MP3 Files"]))
	ffmpeg_file_dialog.set_filters(PackedStringArray(["*.exe ; EXE Files"]))
	export_file_dialog.set_filters(PackedStringArray(["*.mp4 ; MP4 Video"]))
	
	display_filenames()

func display_filenames() -> void:
	filenames.text = "Master: {mf}\nStem 1: {s1f}\nStem 2: {s2f}\nStem 3: {s3f}\nStem 4: {s4f}".format(
		{"mf": master_filename,
		"s1f": stem_1_filename,
		"s2f": stem_2_filename,
		"s3f": stem_3_filename,
		"s4f": stem_4_filename
		}
	)

#region FILES BUILT-IN SIGNAL FUNCTIONS ##################################

func _on_import_m_value_pressed() -> void:
	master_file_dialog.popup()

func _on_master_file_dialog_file_selected(path: String) -> void:
	GlobalVariables.master_audio_path = path
	master_filename = path.get_file().replace(".mp3", "")
	display_filenames()

func _on_import_s_1_value_pressed() -> void:
	stem_1_file_dialog.popup()

func _on_stem_1_file_dialog_file_selected(path: String) -> void:
	GlobalVariables.stem_1_audio_path = path
	stem_1_filename = path.get_file().replace(".mp3", "")
	display_filenames()

func _on_import_s_2_value_pressed() -> void:
	stem_2_file_dialog.popup()

func _on_stem_2_file_dialog_file_selected(path: String) -> void:
	GlobalVariables.stem_2_audio_path = path
	stem_2_filename = path.get_file().replace(".mp3", "")
	display_filenames()

func _on_import_s_3_value_pressed() -> void:
	stem_3_file_dialog.popup()

func _on_stem_3_file_dialog_file_selected(path: String) -> void:
	GlobalVariables.stem_3_audio_path = path
	stem_3_filename = path.get_file().replace(".mp3", "")
	display_filenames()

func _on_import_s_4_value_pressed() -> void:
	stem_4_file_dialog.popup()

func _on_stem_4_file_dialog_file_selected(path: String) -> void:
	GlobalVariables.stem_4_audio_path = path
	stem_4_filename = path.get_file().replace(".mp3", "")
	display_filenames()

func _on_ffmpeg_value_pressed() -> void:
	ffmpeg_file_dialog.popup()

func _on_ffmpeg_file_dialog_file_selected(path: String) -> void:
	if not path.get_file().contains("ffmpeg"):
		MainUtils.logger("Selected FFmpeg executable is not valid. Make sure you've selected the right file.", true)
		return
	MainUtils.ffmpeg_path = path

func _on_export_value_pressed() -> void:
	export_file_dialog.popup()

func _on_export_file_dialog_file_selected(path: String) -> void:
	if MainUtils.ffmpeg_path == "":
		MainUtils.logger("The FFmpeg executable must be selected in order to export your video.", true)
		return
	
	if GlobalVariables.master_audio_path == "":
		MainUtils.logger("Attempted to render without a master track.", true, true)
		return
	
	var check_space: DirAccess = DirAccess.open(MainUtils.temp_path)
	if check_space == null:
			MainUtils.logger("Could not open " \
			+ MainUtils.temp_path + ". Error: " + error_string(DirAccess.get_open_error()), true, true)
			return
	
	var png_filename: String = path.get_file()
	MainUtils.video_filename = png_filename
	MainUtils.video_output_full_path = path.get_base_dir() + "/" + MainUtils.video_filename
	if ".mp4" in png_filename or ".png" in png_filename:
		png_filename = png_filename.replace(".mp4", "")
		png_filename = png_filename.replace(".png", "")
	
	var contents_in_temp: PackedStringArray = DirAccess.get_directories_at(MainUtils.temp_path)
	for folder in contents_in_temp:
		var err: Error = DirAccess.remove_absolute(MainUtils.temp_path + folder)
		if err:
			MainUtils.logger("Could not clear the Temp folder. Error: " + error_string(err), true, true)
			break
		else:
			continue
	MainUtils.logger("Temp folder should be clear, unless error occurred.")
	
	var frame_save_dir: String = MainUtils.temp_path + png_filename
	if not DirAccess.dir_exists_absolute(frame_save_dir):
		var err: Error = DirAccess.make_dir_absolute(frame_save_dir)
		if err:
			MainUtils.logger("Could not make folder for PNGs. Error: " + error_string(err), true, true)
			return
	else:
		var err_1: Error = DirAccess.remove_absolute(frame_save_dir)
		if err_1:
			MainUtils.logger("Could not remove (" + frame_save_dir + "). Error: " + error_string(err_1), true, true)
			return
		var err_2: Error = DirAccess.make_dir_absolute(frame_save_dir)
		if err_2:
			MainUtils.logger("Could not make (" + frame_save_dir + "). Error: " + error_string(err_2), true, true)
			return
	
	GlobalVariables.save_preset("render_preset", GlobalVariables.render_info_path)
	GlobalVariables.save_audio()
	
	MainUtils.process_id = OS.create_process(OS.get_executable_path(),
		[EXPORT_SCENE,
		"--path", frame_save_dir,
		"--write-movie", png_filename + ".png",
		"--resolution", "1280x720",
		"--fixed-fps", "60",
		"--",
		"--load_preset=" + GlobalVariables.render_preset_filename
		])
	
#endregion ##################################
