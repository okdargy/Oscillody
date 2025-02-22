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

extends TextureRect

# This script handles the icon that appears in the center.

#region ICON VARIABLES ##################################

var max_size_on_ui: float = 10.0
var icon_image_ratio: float
var icon_image_size: Vector2
var icon_image_scale_lerpf: float = lerpf(0.02, 0.6, float(GlobalVariables.icon_size) / max_size_on_ui)
var icon_image_scale: Vector2 = Vector2(
	Vector2(MainUtils.window_size).x / icon_image_size.x * icon_image_scale_lerpf,
	Vector2(MainUtils.window_size).x / icon_image_size.x * icon_image_scale_lerpf
	)
var window_ratio: float

var reduce_strength: float = 0.8

#endregion ##################################

func _ready() -> void:
	MainUtils.update_visualizer.connect(update_icon)
	MainUtils.icon_file_selected.connect(load_icon)
	update_icon()

func update_icon() -> void:
	icon_image_scale_lerpf = lerpf(0.02, 0.6, float(GlobalVariables.icon_size) / max_size_on_ui)
	window_ratio = MainUtils.window_size.x / MainUtils.window_size.y
	
	# Scaling to different axis depending on the aspect ratio.
	if window_ratio <= icon_image_ratio:
		icon_image_scale = Vector2(
			Vector2(MainUtils.window_size).x / icon_image_size.x * icon_image_scale_lerpf,
			Vector2(MainUtils.window_size).x / icon_image_size.x * icon_image_scale_lerpf
			)
	else:
		icon_image_scale = Vector2(
			Vector2(MainUtils.window_size).y / icon_image_size.y * icon_image_scale_lerpf,
			Vector2(MainUtils.window_size).y / icon_image_size.y * icon_image_scale_lerpf
			)
	
	visible = GlobalVariables.icon_enabled
	
	set_self_modulate(GlobalVariables.icon_color)
	
	size = icon_image_size
	
	pivot_offset = size / 2.0
	
	set_scale(icon_image_scale)
	
	# Difference from middle of icon image to middle of window.
	var difference: Vector2 = Vector2(
		size.x / 2.0 - float(MainUtils.window_size.x) / 2.0,
		size.y / 2.0 - float(MainUtils.window_size.y) / 2.0
		)
	position = difference * -1.0

func icon_reaction(mag: float, strength: float) -> void:
	set_scale(Vector2(
		icon_image_scale.x * (1 + mag * reduce_strength * strength),
		icon_image_scale.y * (1 + mag * reduce_strength * strength)
		))
	
	if scale < icon_image_scale:
		set_scale(icon_image_scale)
	
	if not MainUtils.audio_playing:
		set_scale(icon_image_scale)

func load_icon() -> void:
	if GlobalVariables.icon_path == "":
		texture = null
		return
	if not FileAccess.file_exists(GlobalVariables.icon_path):
		MainUtils.logger("Icon image \"" + GlobalVariables.icon_path.get_file() + "\" does not exist.", true)
		return
	var image: Image = Image.load_from_file(GlobalVariables.icon_path)
	if image.is_empty():
		MainUtils.logger("Loaded image for icon has no data: " + GlobalVariables.icon_path, true)
		return
	var texture_from_img: Texture2D = ImageTexture.create_from_image(image)
	if texture_from_img.get_image() == null:
		MainUtils.logger(
			"Could not convert icon image to texture, or the image was improperly loaded internally.",
			true,
			true
			)
		return
	set_texture(texture_from_img)
	icon_image_size = image.get_size()
	icon_image_ratio = icon_image_size.x / icon_image_size.y
	update_icon()
	
	MainUtils.logger("New image for icon loaded: " + GlobalVariables.icon_path)
