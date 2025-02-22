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

# This script handles the dividers/separators that appear on screen with 2 waveforms or more (no vertical layout).

#region NODES ##################################

@onready var divider_one: ColorRect = $DividerOne
@onready var divider_two: ColorRect = $DividerTwo

#endregion ##################################

func _ready() -> void:
	MainUtils.update_visualizer.connect(update_dividers)
	update_dividers()

func update_dividers() -> void:
	divider_one.color = GlobalVariables.divider_colors[0]
	divider_two.color = GlobalVariables.divider_colors[1]
	
	if GlobalVariables.number_of_stems == 1 or GlobalVariables.vertical_layout:
		visible = false
	else:
		visible = true
	
	divider_one.position = Vector2i(0, MainUtils.window_size.y / 2 - GlobalVariables.divider_thickness / 2)
	divider_two.position = Vector2i(MainUtils.window_size.x / 2 - GlobalVariables.divider_thickness / 2, 0)
	
	var divider_one_length: Vector2i = Vector2i(MainUtils.window_size.x, GlobalVariables.divider_thickness)
	var divider_two_half_length: Vector2i = Vector2i(GlobalVariables.divider_thickness, MainUtils.window_size.y / 2)
	var divider_two_full_length: Vector2i = Vector2i(GlobalVariables.divider_thickness, MainUtils.window_size.y)
	
	if not GlobalVariables.vertical_layout:
		if GlobalVariables.number_of_stems > 1:
			divider_one.size = divider_one_length
			if GlobalVariables.number_of_stems == 3:
				divider_two.size = divider_two_half_length
			elif GlobalVariables.number_of_stems == 4:
				divider_two.size = divider_two_full_length
			else:
				divider_two.size = Vector2i.ZERO
		else:
			divider_one.size = Vector2i.ZERO
	else:
		divider_one.size = Vector2i.ZERO
		divider_two.size = Vector2i.ZERO
