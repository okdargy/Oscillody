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

extends CenterContainer

# This script handles the pop-up for saving presets.

#region NODES ##################################

@onready var preset_name: LineEdit = %PresetName
@onready var ui_anim_player: AnimationPlayer = %UIAnimPlayer
@onready var save_p_label: Label = %SavePLabel
@onready var save_p_confirm: Button = %SavePConfirm
@onready var save_p_cancel: Button = %SavePCancel

#endregion ##################################

#region SAVE PRESET VARIABLES ##################################

var overwrite_mode: bool = false
var new_preset_name: String

#endregion ##################################

func save_new_preset() -> void:
	if not overwrite_mode:
		GlobalVariables.presets_in_selector.append(new_preset_name.validate_filename())
	GlobalVariables.save_preset(new_preset_name)
	GlobalVariables.preset_name = new_preset_name
	MainUtils.new_preset_saved.emit()
	ui_anim_player.play("save_out")
	if not overwrite_mode:
		MainUtils.logger("New preset saved: " + new_preset_name)
	else:
		MainUtils.logger("Preset overwritten: " + new_preset_name)
	preset_name.text = ""

#region SAVE PRESET BUILT-IN SIGNAL FUNCTIONS ##################################

func _on_save_p_confirm_pressed() -> void:
	new_preset_name = preset_name.text
	if new_preset_name == "render_preset":
		new_preset_name = new_preset_name + "_user"
	if not overwrite_mode:
		if new_preset_name.validate_filename() not in GlobalVariables.presets_in_selector:
			save_new_preset()
			MainUtils.can_pause_with_spacebar = true
		else:
			save_p_label.text = "Overwrite preset?"
			preset_name.editable = false
			save_p_confirm.text = "Yes"
			save_p_cancel.text = "No"
			overwrite_mode = true
	else:
		save_new_preset()
		save_p_label.text = "Save Preset:"
		preset_name.editable = true
		save_p_confirm.text = "Save"
		save_p_cancel.text = "Cancel"
		overwrite_mode = false
		MainUtils.can_pause_with_spacebar = true

func _on_save_p_cancel_pressed() -> void:
	if not overwrite_mode:
		ui_anim_player.play("save_out")
		preset_name.text = ""
		MainUtils.can_pause_with_spacebar = true
	else:
		ui_anim_player.play("save_out")
		save_p_label.text = "Save Preset:"
		preset_name.editable = true
		save_p_confirm.text = "Save"
		save_p_cancel.text = "Cancel"
		preset_name.text = ""
		overwrite_mode = false
		MainUtils.can_pause_with_spacebar = true

func _on_preset_name_text_submitted(_new_text: String) -> void:
	save_p_confirm.pressed.emit()

#endregion ##################################
