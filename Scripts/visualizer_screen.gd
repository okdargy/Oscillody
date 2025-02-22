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

extends Node2D

# This script mostly handles audio reaction.

#region NODES ##################################

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var bg_shader_canvas: CanvasLayer = $CanvasLayer/BGShaderCanvas
@onready var bg_image_canvas: CanvasLayer = $CanvasLayer/BGImageCanvas
@onready var icon: TextureRect = $CanvasLayer/Icon
@onready var title_control: Control = $CanvasLayer/TitleControl
@onready var post_processing_canvas: CanvasLayer = $CanvasLayer/PostProcessingCanvas

@onready var audio_players: Node = $CanvasLayer/AudioPlayers

#endregion ##################################

#region VISUALIZER VARIABLES ##################################

var reaction_strength_over_max: float

#endregion ##################################

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	MainUtils.close_requested.connect(on_close_requested)
	
	# Start loads preset and audio for rendering.
	if OS.has_feature("movie"):
		var user_arguments: Dictionary = {} # Dictionary that will hold user arguments
		for argument in OS.get_cmdline_user_args():
			if "=" in argument: # If = is existent
				# Sets key_value to ["--load_preset", ""render_preset""]
				var key_value: PackedStringArray = argument.split("=")
				# arguments{"load_preset": ""render_preset""}
				user_arguments[key_value[0].lstrip("--")] = key_value[1]
			else:
				user_arguments[argument.lstrip("--")] = ""
		GlobalVariables.load_preset(user_arguments["load_preset"])
		GlobalVariables.load_audio()
		MainUtils.update_visualizer.emit()
		await get_tree().create_timer(0.4).timeout # Letting waveform load
		audio_players.play_audio_spectrum_data_node() # Playing this earlier so it's synced to audio
		await get_tree().create_timer(0.1).timeout
		audio_players.play_audio_nodes()

func _process(_delta: float) -> void:
	reaction_strength_over_max = GlobalVariables.reaction_strength / 10.0
	
	if GlobalVariables.audio_reaction_enabled:
		if GlobalVariables.audio_reaction_targets["Title"]:
			title_control.title_reaction_enabled = true
			title_control.title_reaction(MainUtils.cur_mag, reaction_strength_over_max)
		else:
			title_control.title_reaction_enabled = false
		
		if GlobalVariables.audio_reaction_targets["Background"] and GlobalVariables.background_type == "Image":
			bg_image_canvas.image_reaction(MainUtils.cur_mag, reaction_strength_over_max)
		
		if GlobalVariables.audio_reaction_targets["Background"] and GlobalVariables.background_type == "Shader":
			bg_shader_canvas.shader_reaction(MainUtils.cur_mag, reaction_strength_over_max)
		
		if GlobalVariables.audio_reaction_targets["Icon"]:
			icon.icon_reaction(MainUtils.cur_mag, reaction_strength_over_max)
		
		if GlobalVariables.audio_reaction_targets["Post-Processing"] and GlobalVariables.bloom_reaction:
			world_environment.bloom_reaction(MainUtils.cur_mag, reaction_strength_over_max)
		
		if (
			GlobalVariables.audio_reaction_targets["Post-Processing"] and
			(GlobalVariables.chromatic_aberration_reaction or GlobalVariables.vignette_reaction)
			):
			post_processing_canvas.post_processing_reaction(MainUtils.cur_mag, reaction_strength_over_max)

func on_close_requested() -> void:
	if OS.has_feature("movie"):
		MainUtils.logger("Rendering canceled / Session closing (render process).")
		audio_players.stop_audio_nodes()
		audio_players.queue_free()
		get_tree().quit()
