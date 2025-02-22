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

# This script handles the settings panel.

#region NODES ##################################

@onready var buffer_q_s_value: SpinBox = $VBoxContainer/BufferQueueSize/BufferQSValue
@onready var low_s_m_value: CheckButton = $VBoxContainer/LowSpecsMode/LowSMValue

#endregion ##################################

func _ready() -> void:
	buffer_q_s_value.value = MainUtils.buffer_queue_size
	low_s_m_value.button_pressed = MainUtils.low_specs_mode

#region SETTINGS BUILT-IN SIGNAL FUNCTIONS ##################################

func _on_buffer_q_s_value_value_changed(value: float) -> void:
	MainUtils.new_buffer_queue_size = int(value)

func _on_low_s_m_value_toggled(toggled_on: bool) -> void:
	MainUtils.load_low_specs_mode = toggled_on

func _on_links_and_more_meta_clicked(meta: Variant) -> void:
	var err: Error = OS.shell_open(meta)
	if err:
		MainUtils.logger("Could not open link. Error: " + error_string(err), true)

#endregion ##################################
