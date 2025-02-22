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

extends WorldEnvironment

# This script handles bloom.

#region BLOOM VARIABLES ##################################

var max_bloom_in_ui: float = 10.0
var default_intensity: float = 0.8

var mag_compensation: float = 1.75

#endregion ##################################

func _ready() -> void:
	MainUtils.update_visualizer.connect(update_bloom)
	update_bloom()

func update_bloom() -> void:
	environment.set_glow_enabled(GlobalVariables.bloom_amount)
	environment.set_glow_bloom(GlobalVariables.bloom_amount / max_bloom_in_ui * default_intensity)
	environment.set_glow_intensity(default_intensity)

func bloom_reaction(mag: float, strength: float) -> void:
	environment.set_glow_intensity(default_intensity)
	
	environment.glow_intensity += mag * mag_compensation * strength
	
	if not MainUtils.audio_playing:
		environment.set_glow_intensity(default_intensity)
