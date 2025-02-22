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

extends CanvasLayer

# This script handles the background image.

#region NODES ##################################

@onready var image_rect: TextureRect = $ImageRect
@onready var blur: ColorRect = $Blur

#endregion ##################################

#region BACKGROUND IMAGE VARIABLES ##################################

var max_size_on_ui: float = 10.0
var max_opacity_on_ui: float = 100.0
var image_size: Vector2
# Extrapolation. Subtracting 0.1 since it wouldn't show the whole image otherwise.
var image_scale_lerpf: float = lerpf(1.0, 2.0, float(GlobalVariables.image_size) / max_size_on_ui - 0.1)
var image_scale: Vector2 = Vector2(MainUtils.window_size) / image_size * image_scale_lerpf

var reduce_strength: float = 0.4

#endregion ##################################

func _ready() -> void:
	MainUtils.update_visualizer.connect(update_image)
	MainUtils.image_file_selected.connect(load_image)
	update_image()

func update_image() -> void:
	image_scale_lerpf = lerpf(1.0, 2.0, float(GlobalVariables.image_size) / max_size_on_ui - 0.1)
	image_scale = Vector2(MainUtils.window_size) / image_size * image_scale_lerpf
	
	if GlobalVariables.background_type == "Image":
		visible = true
		image_rect.set_self_modulate(Color(1.0, 1.0, 1.0, float(GlobalVariables.image_opacity / max_opacity_on_ui)))
		image_rect.size = image_size
		image_rect.set_scale(image_scale)
		image_rect.pivot_offset = image_rect.size / 2.0
		
		# Difference from middle of icon image to middle of window.
		var difference: Vector2 = Vector2(
			image_rect.size.x / 2.0 - float(MainUtils.window_size.x) / 2.0,
			image_rect.size.y / 2.0 - float(MainUtils.window_size.y) / 2.0
			)
		image_rect.position = difference * -1.0
		
		if GlobalVariables.image_blur > 0:
			blur.visible = true
			blur.get_material().set_shader_parameter("blur_strength",
			lerpf(0.0, 5.0, GlobalVariables.image_blur * 0.01)
			)
		else:
			blur.visible = false
		
	else:
		visible = false

func image_reaction(mag: float, strength: float) -> void:
	image_rect.set_scale(Vector2(
		image_scale.x * (1 + mag * reduce_strength * strength),
		image_scale.y * (1 + mag * reduce_strength * strength)
		))
	
	if image_rect.scale < image_scale:
		image_rect.set_scale(image_scale)
	
	if not MainUtils.audio_playing:
		image_rect.set_scale(image_scale)

func load_image() -> void:
	if GlobalVariables.image_path == "":
		image_rect.texture = null
		return
	if not FileAccess.file_exists(GlobalVariables.image_path):
		MainUtils.logger("Background image \"" + GlobalVariables.image_path.get_file() + "\" does not exist.", true)
		return
	var image: Image = Image.load_from_file(GlobalVariables.image_path)
	if image.is_empty():
		MainUtils.logger("Loaded image for background has no data: " + GlobalVariables.image_path, true)
		return
	var texture_from_img: Texture2D = ImageTexture.create_from_image(image)
	if texture_from_img.get_image() == null:
		MainUtils.logger(
			"Could not convert background image to texture, or the image was improperly loaded internally.",
			true,
			true
			)
		return
	image_rect.set_texture(texture_from_img)
	image_size = Vector2(image.get_size())
	update_image()
	
	MainUtils.logger("New image for background selected: " + GlobalVariables.image_path)
