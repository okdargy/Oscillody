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

# This script handles the player control part of the app.

#region NODES ##################################

@onready var play_pause_button: Button = %PlayPauseButton
@onready var stop_button: Button = %StopButton
@onready var loop_button: Button = %LoopButton
@onready var vol_slider: HSlider = %VolSlider
@onready var vol_val_display: Label = %VolValDisplay
@onready var seek_slider: HSlider = %SeekSlider
@onready var seek_time_display: Label = %SeekTimeDisplay
@onready var audio_pos_hint: Label = %AudioPosHint

#endregion ##################################

#region PLAYER CONTROL VARIABLES ##################################

var user_seeking: bool = false
var mouse_x_pos: String
var audio_pos_mouse: float

var pos_mins: String
var pos_secs: String

var dur_mins: String
var dur_secs: String

#endregion ##################################

func _ready() -> void:
	MainUtils.update_visualizer.connect(update_player_control)
	MainUtils.audio_stopped.connect(audio_stopped)
	MainUtils.audio_finished.connect(audio_finished)
	MainUtils.audio_file_selected.connect(reset_player)
	update_player_control()

func _process(_delta: float) -> void:
	seek_slider.max_value = MainUtils.audio_duration
	if not user_seeking:
		seek_slider.set_value_no_signal(MainUtils.audio_position)
	
	vol_val_display.text = str(MainUtils.new_volume_display) + "%"
	
	pos_mins = str(floori(MainUtils.audio_position / 60.0))
	pos_secs = str(int(fmod(MainUtils.audio_position, 60.0))).pad_zeros(2)
	
	dur_mins = str(floori(MainUtils.audio_duration / 60.0))
	dur_secs = str(int(fmod(MainUtils.audio_duration, 60.0))).pad_zeros(2)
	
	seek_time_display.text = "{pm}:{ps} | {dm}:{ds}".format(
		{"pm": pos_mins, "ps": pos_secs,
		"dm": dur_mins, "ds": dur_secs}
		)
	
	if Input.is_action_just_pressed("play_pause") and MainUtils.can_pause_with_spacebar:
		play_pause_button.pressed.emit()

func update_player_control() -> void:
	vol_slider.custom_minimum_size.x = lerp(
		float(MainUtils.window_size.x / 80), float(MainUtils.window_size.x / 8),
		float(MainUtils.window_size.x) / float(DisplayServer.screen_get_size().x)
		)
	seek_slider.custom_minimum_size.x = lerp(
		float(MainUtils.window_size.x / 80), float(MainUtils.window_size.x / 2),
		float(MainUtils.window_size.x) / float(DisplayServer.screen_get_size().x)
		)

func audio_stopped() -> void:
	play_pause_button.text = "Play"

func audio_finished() -> void:
	if not MainUtils.loop_enabled:
		play_pause_button.text = "Play"

func reset_player() -> void:
	play_pause_button.text = "Play"

#region PLAYER CONTROL BUILT-IN SIGNAL FUNCTIONS ##################################

func _on_play_pause_button_pressed() -> void:
	if GlobalVariables.master_audio_path != "":
		if MainUtils.audio_playing:
			play_pause_button.text = "Play"
			MainUtils.audio_paused.emit()
		else:
			play_pause_button.text = "Pause"
			MainUtils.audio_played.emit()

func _on_stop_button_pressed() -> void:
	if GlobalVariables.master_audio_path != "":
		MainUtils.audio_stopped.emit()

func _on_loop_button_toggled(toggled_on: bool) -> void:
	MainUtils.loop_enabled = toggled_on

func _on_vol_slider_value_changed(value: float) -> void:
	MainUtils.new_volume_display = roundi(value * 100.0)
	MainUtils.new_volume_in_db = linear_to_db(value)

func _on_seek_slider_gui_input(event: InputEvent) -> void:
	# Get audio position to show on a label based on where the mouse is.
	if GlobalVariables.master_audio_path != "":
		if "position=" in str(event):
			var slice_idx: int = 0
			var event_array: PackedStringArray = str(event).split(", ")
			for slice: String in event_array:
				if slice.contains("position"):
					break
				else:
					slice_idx += 1
			mouse_x_pos = str(event).get_slice(", ", slice_idx).replace("position=((", "")
			audio_pos_mouse = lerp(
				0,
				int(seek_slider.max_value),
				clamp(mouse_x_pos.to_float(), 0, seek_slider.custom_minimum_size.x) / seek_slider.custom_minimum_size.x
				)
			
		var pos_mins_mouse: String = str(floori(audio_pos_mouse / 60.0))
		var pos_secs_mouse: String = str(int(fmod(audio_pos_mouse, 60.0))).pad_zeros(2)
		audio_pos_hint.text = pos_mins_mouse + ":" + pos_secs_mouse
		
		audio_pos_hint.position.x = lerp(
			seek_slider.position.x,
			seek_slider.position.x + seek_slider.custom_minimum_size.x,
			clamp(mouse_x_pos.to_float(), 0, seek_slider.custom_minimum_size.x) / seek_slider.custom_minimum_size.x
			) - 6

func _on_seek_slider_drag_ended(_value_changed: bool) -> void:
	user_seeking = false
	if GlobalVariables.master_audio_path != "":
		MainUtils.audio_pos_changed.emit()

func _on_seek_slider_value_changed(value: float) -> void:
	user_seeking = true
	MainUtils.new_audio_pos_from_seek = value

func _on_seek_slider_mouse_entered() -> void:
	audio_pos_hint.visible = true

func _on_seek_slider_mouse_exited() -> void:
	audio_pos_hint.visible = false

func _on_panel_container_gui_input(event: InputEvent) -> void:
	if "pressed=true" in str(event):
		get_viewport().gui_release_focus()

#endregion ##################################
