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

# This script handles modification of audio data and waveform display, all in real-time.
# It is attached to a Node2D in a saved scene, instantiated on the scene Visualizer Screen.
# It relies on AudioEffectCapture to get audio data (see: main_utils script).

#region OSCILLOSCOPE VARIABLES ##################################

var waveform_number: int
var waveform_x_spacing: float
var waveform_y_pos: int
var waveform_color: Color
var waveform_thickness: int

var audio_frame_buffers: Array
var waveform_points: PackedVector2Array # Array which will contain data for drawing waveform lines

var waveform_height: float
var waveform_height_multiplier: float
var max_waveform_height: float

var offset: float # Offset for a waveform's initial X position

var height_quotient: float

var point_idx: int # Iterator

var array_with_frames: Array

# For X and Y positions of each line point.
var x: float
var y: float

#endregion ##################################

# Redraws canvas.
func _draw() -> void:
	for stem in GlobalVariables.number_of_stems:
		if GlobalVariables.number_of_stems > 1:
			waveform(GlobalVariables.waveform_configs[stem], MainUtils.audio_frame_buffers[stem])
		else:
			waveform(GlobalVariables.waveform_configs[stem], MainUtils.audio_frame_buffers[4])

# Runs as fast as possible (limited to 60 FPS).
func _process(_delta: float) -> void:
	queue_redraw() # Calls _draw()

# Handles audio data and waveform display.
func waveform(waveform_configs: Array, buffers: Array) -> void:
	waveform_number = waveform_configs[0]
	waveform_x_spacing = waveform_configs[1]
	waveform_y_pos = waveform_configs[2]
	waveform_color = waveform_configs[3]
	waveform_thickness = waveform_configs[4]
	
	audio_frame_buffers = buffers
	waveform_points.clear() # Array which will contain data for drawing waveform lines
	
	waveform_height_multiplier = GlobalVariables.waveform_height
	max_waveform_height = GlobalVariables.max_waveform_height
	
	if GlobalVariables.vertical_layout and GlobalVariables.number_of_stems > 1:
		waveform_height = MainUtils.window_size.x * 0.05
	elif not GlobalVariables.vertical_layout and GlobalVariables.number_of_stems > 1:
		waveform_height = MainUtils.window_size.x * 0.1
	else:
		waveform_height = MainUtils.window_size.x * 0.2
	
	# Up to next commment, gets and modifies frame buffer data to be displayed.
	if GlobalVariables.number_of_stems > 2 and not GlobalVariables.vertical_layout:
		if waveform_number == 1 or waveform_number == 3:
			offset = 0.0
		else:
			offset = float(MainUtils.window_size.x) / 2.0
	else:
		offset = 0.0
	
	height_quotient = float(waveform_height_multiplier) / float(max_waveform_height)
	
	point_idx = 0
	
	array_with_frames.clear()
	
	for buffer_idx: Array in audio_frame_buffers:
		array_with_frames.append_array(buffer_idx)
	
	for frame: float in array_with_frames:
		x = point_idx * waveform_x_spacing + int(offset)
		y = waveform_y_pos + (frame * waveform_height) * height_quotient
		waveform_points.append(Vector2(x, y))
		point_idx += 1
	
	# Displays waveform.
	if waveform_points.size() > 1:
		draw_polyline(waveform_points, waveform_color, waveform_thickness)
	
