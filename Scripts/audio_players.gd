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

# This script handles audio players.

#region NODES ##################################

@onready var master_player: AudioStreamPlayer = $MasterPlayer
@onready var stem_player_one: AudioStreamPlayer = $StemPlayerOne
@onready var stem_player_two: AudioStreamPlayer = $StemPlayerTwo
@onready var stem_player_three: AudioStreamPlayer = $StemPlayerThree
@onready var stem_player_four: AudioStreamPlayer = $StemPlayerFour
@onready var master_one_stem: AudioStreamPlayer = $MasterOneStem
@onready var spectrum_data: AudioStreamPlayer = $SpectrumData

#endregion ##################################

#region AUDIO PLAYER VARIABLES ##################################

var new_position_on_audio_stopped: bool = false

#endregion ##################################

func _ready() -> void:
	MainUtils.audio_played.connect(audio_played_on_control)
	MainUtils.audio_paused.connect(audio_paused_on_control)
	MainUtils.audio_stopped.connect(audio_stopped_on_control)
	MainUtils.audio_pos_changed.connect(seek_audio_pos)
	MainUtils.audio_file_selected.connect(set_new_stream)
	MainUtils.new_audio_master_selected.connect(reset_audio_position_on_new_master)
	
func _process(_delta: float) -> void:
	if GlobalVariables.master_audio_path != "":
		MainUtils.audio_duration = floor(master_player.stream.get_length())
	if not new_position_on_audio_stopped and GlobalVariables.master_audio_path != "":
		MainUtils.audio_position = master_player.get_playback_position()
	else:
		MainUtils.audio_position = MainUtils.new_audio_pos_from_seek
	if master_player.playing:
		MainUtils.audio_playing = true
	else:
		MainUtils.audio_playing = false
	
	master_player.set_volume_db(MainUtils.new_volume_in_db)

func audio_played_on_control() -> void:
	play_audio_nodes(MainUtils.audio_position)
	
	if MainUtils.audio_was_stopped or (not MainUtils.audio_playing and master_player.get_playback_position() == 0):
		MainUtils.audio_was_stopped = false
	
	new_position_on_audio_stopped = false

func audio_paused_on_control() -> void:
	pause_audio_nodes(true)

func audio_stopped_on_control() -> void:
	stop_audio_nodes()
	MainUtils.audio_was_stopped = true

func seek_audio_pos() -> void:
	seek_audio_nodes(MainUtils.new_audio_pos_from_seek)

func pause_audio_nodes(pause: bool) -> void:
	master_player.set_stream_paused(pause)
	master_one_stem.set_stream_paused(pause)
	stem_player_one.set_stream_paused(pause)
	stem_player_two.set_stream_paused(pause)
	stem_player_three.set_stream_paused(pause)
	stem_player_four.set_stream_paused(pause)
	spectrum_data.set_stream_paused(pause)

func play_audio_nodes(from_pos: float = 0.0) -> void:
	master_player.play(from_pos)
	master_one_stem.play(from_pos)
	stem_player_one.play(from_pos)
	stem_player_two.play(from_pos)
	stem_player_three.play(from_pos)
	stem_player_four.play(from_pos)
	if not OS.has_feature("movie"):
		spectrum_data.play(from_pos)

func play_audio_spectrum_data_node() -> void:
	spectrum_data.play()

func stop_audio_nodes() -> void:
	master_player.stop()
	master_one_stem.stop()
	stem_player_one.stop()
	stem_player_two.stop()
	stem_player_three.stop()
	stem_player_four.stop()
	spectrum_data.stop()

func seek_audio_nodes(new_pos: float) -> void:
	master_player.seek(new_pos)
	master_one_stem.seek(new_pos)
	stem_player_one.seek(new_pos)
	stem_player_two.seek(new_pos)
	stem_player_three.seek(new_pos)
	stem_player_four.seek(new_pos)
	spectrum_data.seek(new_pos)
	
	if not MainUtils.audio_playing:
		new_position_on_audio_stopped = true

func set_new_stream() -> void:
	if GlobalVariables.master_audio_path != "":
		master_player.set_stream(MainUtils.convert_to_playable(GlobalVariables.master_audio_path))
		master_one_stem.set_stream(master_player.get_stream())
		spectrum_data.set_stream(master_player.get_stream())
	if GlobalVariables.stem_1_audio_path != "":
		stem_player_one.set_stream(MainUtils.convert_to_playable(GlobalVariables.stem_1_audio_path))
	if GlobalVariables.stem_2_audio_path != "":
		stem_player_two.set_stream(MainUtils.convert_to_playable(GlobalVariables.stem_2_audio_path))
	if GlobalVariables.stem_3_audio_path != "":
		stem_player_three.set_stream(MainUtils.convert_to_playable(GlobalVariables.stem_3_audio_path))
	if GlobalVariables.stem_4_audio_path != "":
		stem_player_four.set_stream(MainUtils.convert_to_playable(GlobalVariables.stem_4_audio_path))
	
	MainUtils.logger("New audio selected.")

func reset_audio_position_on_new_master() -> void:
	if not MainUtils.audio_playing:
		MainUtils.new_audio_pos_from_seek = 0.0

#region AUDIO PLAYER BUILT-IN SIGNAL FUNCTIONS ##################################

func _on_master_player_finished() -> void:
	MainUtils.audio_finished.emit()
	if MainUtils.loop_enabled:
		play_audio_nodes()
	else:
		stop_audio_nodes()
	
	if OS.has_feature("movie"):
		MainUtils.logger("Rendering finished (audio has finished) / Session closed (render process).")
		queue_free()
		get_tree().quit()

#endregion ##################################
