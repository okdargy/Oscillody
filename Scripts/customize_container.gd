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

# This script changes UI control values to whatever is loaded on global_variables, and updates their values.

#region NODES ##################################

@onready var preset_value: OptionButton = %PresetValue

@onready var no_of_stems_value: SpinBox = %NoOfStemsValue
@onready var v_layout_value: CheckButton = %VLayoutValue

@onready var title_value: LineEdit = %TitleValue
@onready var title_f_value: OptionButton = %TitleFValue
@onready var title_f_b_value: CheckButton = %TitleFBValue
@onready var title_f_i_value: CheckButton = %TitleFIValue
@onready var title_p_x_value: SpinBox = %TitlePXValue
@onready var title_p_y_value: SpinBox = %TitlePYValue
@onready var title_c_value: ColorPickerButton = %TitleCValue
@onready var title_si_value: SpinBox = %TitleSiValue
@onready var title_s_c_value: ColorPickerButton = %TitleSCValue
@onready var title_s_x_value: SpinBox = %TitleSXValue
@onready var title_s_y_value: SpinBox = %TitleSYValue
@onready var title_o_c_value: ColorPickerButton = %TitleOCValue
@onready var title_o_s_value: SpinBox = %TitleOSValue

@onready var waveform_1_colors: ColorPickerButton = %Waveform1Colors
@onready var waveform_2_colors: ColorPickerButton = %Waveform2Colors
@onready var waveform_3_colors: ColorPickerButton = %Waveform3Colors
@onready var waveform_4_colors: ColorPickerButton = %Waveform4Colors
@onready var waveform_t_value: SpinBox = %WaveformTValue
@onready var waveform_h_value: SpinBox = %WaveformHValue

@onready var bg_t_value: OptionButton = %BGTValue

@onready var bg_1_colors: ColorPickerButton = %BG1Colors
@onready var bg_2_colors: ColorPickerButton = %BG2Colors
@onready var bg_3_colors: ColorPickerButton = %BG3Colors
@onready var bg_4_colors: ColorPickerButton = %BG4Colors

@onready var bg_img_p_value: Button = %BGImgPValue
@onready var bg_img_p_file_dialog: FileDialog = %BGImgPFileDialog
@onready var bg_img_s_value: SpinBox = %BGImgSValue
@onready var bg_img_o_value: HSlider = %BGImgOValue
@onready var bg_img_o_slider_value: Label = %BGImgOSliderValue
@onready var bg_img_b_value: HSlider = %BGImgBValue
@onready var bg_img_b_slider_value: Label = %BGImgBSliderValue

@onready var bg_s_color_m_value: CheckButton = %BGSColorMValue
@onready var bg_s_color_value: ColorPickerButton = %BGSColorValue
@onready var bg_s_freq_f_value: HSlider = %BGSFreqFValue
@onready var bg_s_freq_f_slider_value: Label = %BGSFreqFSliderValue
@onready var bg_s_blur_value: HSlider = %BGSBlurValue
@onready var bg_s_blur_slider_value: Label = %BGSBlurSliderValue
@onready var bg_s_amp_value: HSlider = %BGSAmpValue
@onready var bg_s_amp_slider_value: Label = %BGSAmpSliderValue
@onready var bg_s_spe_value: HSlider = %BGSSpeValue
@onready var bg_s_spe_slider_value: Label = %BGSSpeSliderValue
@onready var bg_s_oct_value: SpinBox = %BGSOctValue
@onready var bg_s_freq_i_value: HSlider = %BGSFreqIValue
@onready var bg_s_freq_i_slider_value: Label = %BGSFreqISliderValue
@onready var bg_s_amp_d_value: HSlider = %BGSAmpDValue
@onready var bg_s_amp_d_slider_value: Label = %BGSAmpDSliderValue

@onready var divider_c_value: ColorPickerButton = %DividerCValue
@onready var divider_c_value_2: ColorPickerButton = %DividerCValue2
@onready var divider_t_value: SpinBox = %DividerTValue

@onready var icon_e_value: CheckButton = %IconEValue
@onready var icon_p_value: Button = %IconPValue
@onready var icon_p_file_dialog: FileDialog = %IconPFileDialog
@onready var icon_c_value: ColorPickerButton = %IconCValue
@onready var icon_s_value: SpinBox = %IconSValue

@onready var post_p_t_value: OptionButton = %PostPTValue
@onready var bloom_a_value: HSlider = %BloomAValue
@onready var bloom_a_slider_value: Label = %BloomASliderValue
@onready var bloom_r_value: CheckBox = %BloomRValue
@onready var chromatic_a_s_value: HSlider = %ChromaticASValue
@onready var chromatic_a_s_slider_value: Label = %ChromaticASSliderValue
@onready var chromatic_a_r_value: CheckBox = %ChromaticARValue
@onready var vignette_c_value: ColorPickerButton = %VignetteCValue
@onready var vignette_s_value: HSlider = %VignetteSValue
@onready var vignette_s_slider_value: Label = %VignetteSSliderValue
@onready var vignette_sh_value: HSlider = %VignetteShValue
@onready var vignette_sh_slider_value: Label = %VignetteShSliderValue
@onready var vignette_r_value: CheckBox = %VignetteRValue
@onready var grain_s_value: CheckBox = %GrainSValue
@onready var grain_o_value: HSlider = %GrainOValue
@onready var grain_o_slider_value: Label = %GrainOSliderValue

@onready var audio_r_e_value: CheckButton = %AudioREValue
@onready var audio_r_m_value: SpinBox = %AudioRMValue
@onready var title_a_r_value: CheckBox = %TitleARValue
@onready var background_a_r_value: CheckBox = %BackgroundARValue
@onready var icon_a_r_value: CheckBox = %IconARValue
@onready var post_p_a_r_value: CheckBox = %PostPARValue
@onready var reaction_s_value: SpinBox = %ReactionSValue
@onready var smoothing_a_value: SpinBox = %SmoothingAValue

@onready var title_font: HBoxContainer = %TitleFont
@onready var title_font_bold: HBoxContainer = %TitleFontBold
@onready var title_font_italic: HBoxContainer = %TitleFontItalic
@onready var title_pos: HBoxContainer = %TitlePos
@onready var title_color: HBoxContainer = %TitleColor
@onready var title_size: HBoxContainer = %TitleSize
@onready var title_shadow: VBoxContainer = %TitleShadow
@onready var title_outline: HBoxContainer = %TitleOutline

@onready var background_colors: VBoxContainer = %BackgroundColors
@onready var bg_img_path: HBoxContainer = %BGImgPath
@onready var bg_img_size: HBoxContainer = %BGImgSize
@onready var bg_img_opacity: HBoxContainer = %BGImgOpacity
@onready var bg_img_blur: HBoxContainer = %BGImgBlur
@onready var bg_shader_color_mixing: HBoxContainer = %BGShaderColorMixing
@onready var bg_shader_color: HBoxContainer = %BGShaderColor
@onready var bg_shader_freq_factor: HBoxContainer = %BGShaderFreqFactor
@onready var bg_shader_blur: HBoxContainer = %BGShaderBlur
@onready var bg_shader_amp: HBoxContainer = %BGShaderAmp
@onready var bg_shader_speed: HBoxContainer = %BGShaderSpeed
@onready var bg_shader_octaves: HBoxContainer = %BGShaderOctaves
@onready var bg_shader_freq_increment: HBoxContainer = %BGShaderFreqIncrement
@onready var bg_shader_amp_decrement: HBoxContainer = %BGShaderAmpDecrement

@onready var h_separator_5: HSeparator = %HSeparator5

@onready var divider_colors: HBoxContainer = %DividerColors
@onready var divider_thickness: HBoxContainer = %DividerThickness

@onready var icon_path: HBoxContainer = %IconPath
@onready var icon_color: HBoxContainer = %IconColor
@onready var icon_size: HBoxContainer = %IconSize

@onready var bloom_amount: HBoxContainer = %BloomAmount
@onready var bloom_reaction: HBoxContainer = %BloomReaction
@onready var chromatic_aberration_strength: HBoxContainer = %ChromaticAberrationStrength
@onready var chromatic_aberration_reaction: HBoxContainer = %ChromaticAberrationReaction
@onready var vignette_color: HBoxContainer = %VignetteColor
@onready var vignette_size: HBoxContainer = %VignetteSize
@onready var vignette_sharpness: HBoxContainer = %VignetteSharpness
@onready var vignette_reaction: HBoxContainer = %VignetteReaction
@onready var grain_static: HBoxContainer = %GrainStatic
@onready var grain_opacity: HBoxContainer = %GrainOpacity

@onready var audio_r_min_db: HBoxContainer = %AudioRMindB
@onready var audio_r_target: VBoxContainer = %AudioRTarget
@onready var reaction_strength: HBoxContainer = %ReactionStrength
@onready var smoothing_amount: HBoxContainer = %SmoothingAmount

@onready var save_preset_container: CenterContainer = %SavePresetContainer

@onready var ui_anim_player: AnimationPlayer = %UIAnimPlayer

#endregion ##################################

func _ready() -> void:
	MainUtils.update_visualizer.connect(update_customize)
	MainUtils.new_preset_saved.connect(refresh_preset_list)
	update_customize()
	
	var file_iterable: int = 0
	for preset: String in GlobalVariables.presets_in_selector:
		preset_value.add_item(GlobalVariables.presets_in_selector[file_iterable], file_iterable)
		file_iterable += 1
	if GlobalVariables.presets_in_selector.find("Default") != -1:
		preset_value.select(GlobalVariables.presets_in_selector.find("Default"))
	else:
		MainUtils.logger("Can't find Default preset.", true)
	
	var font_idx: int = 0
	for font in GlobalVariables.title_fonts_in_selector:
		title_f_value.add_item(font, font_idx)
		font_idx += 1
	title_f_value.select(GlobalVariables.title_fonts_in_selector.find(GlobalVariables.title_font))
	
	GlobalVariables.load_preset(GlobalVariables.preset_name)
	
	set_ui_values()
	
	bg_t_value.select(GlobalVariables.background_types_in_selector.find(GlobalVariables.background_type))
	
	if GlobalVariables.title_font not in GlobalVariables.title_fonts_in_selector:
		MainUtils.logger("Could not find font \"" + GlobalVariables.title_font + "\" in preset.", true)
		GlobalVariables.title_font = "Calibri"
	title_f_value.select(GlobalVariables.title_fonts_in_selector.find(GlobalVariables.title_font))
	
	MainUtils.update_visualizer.emit()

func update_customize() -> void:
	if GlobalVariables.title:
		title_font.visible = true
		title_font_bold.visible = true
		title_font_italic.visible = true
		title_pos.visible = true
		title_color.visible = true
		title_size.visible = true
		title_shadow.visible = true
		title_outline.visible = true
	else:
		title_font.visible = false
		title_font_bold.visible = false
		title_font_italic.visible = false
		title_pos.visible = false
		title_color.visible = false
		title_size.visible = false
		title_shadow.visible = false
		title_outline.visible = false
	
	if GlobalVariables.background_type == "Solid Colors":
		background_colors.visible = true
	else:
		background_colors.visible = false
	if GlobalVariables.background_type == "Image":
		bg_img_path.visible = true
		bg_img_size.visible = true
		bg_img_opacity.visible = true
		bg_img_blur.visible = true
	else:
		bg_img_path.visible = false
		bg_img_size.visible = false
		bg_img_opacity.visible = false
		bg_img_blur.visible = false
	if GlobalVariables.background_type == "Shader":
		bg_shader_color_mixing.visible = true
		bg_shader_color.visible = true
		bg_shader_freq_factor.visible = true
		bg_shader_blur.visible = true
		bg_shader_amp.visible = true
		bg_shader_speed.visible = true
		bg_shader_octaves.visible = true
		bg_shader_freq_increment.visible = true
		bg_shader_amp_decrement.visible = true
	else:
		bg_shader_color_mixing.visible = false
		bg_shader_color.visible = false
		bg_shader_freq_factor.visible = false
		bg_shader_blur.visible = false
		bg_shader_amp.visible = false
		bg_shader_speed.visible = false
		bg_shader_octaves.visible = false
		bg_shader_freq_increment.visible = false
		bg_shader_amp_decrement.visible = false
	
	if GlobalVariables.number_of_stems > 1 and not GlobalVariables.vertical_layout:
		h_separator_5.visible = true
		divider_colors.visible = true
		divider_thickness.visible = true
	else:
		h_separator_5.visible = false
		divider_colors.visible = false
		divider_thickness.visible = false
	if GlobalVariables.number_of_stems == 2:
		divider_c_value_2.visible = false
	else:
		divider_c_value_2.visible = true
	
	if GlobalVariables.icon_enabled:
		icon_path.visible = true
		icon_color.visible = true
		icon_size.visible = true
	else:
		icon_path.visible = false
		icon_color.visible = false
		icon_size.visible = false
	
	if GlobalVariables.post_processing_type == "Bloom":
		bloom_amount.visible = true
		bloom_reaction.visible = true
	else:
		bloom_amount.visible = false
		bloom_reaction.visible = false
	if GlobalVariables.post_processing_type == "Chromatic Aberration":
		chromatic_aberration_strength.visible = true
		chromatic_aberration_reaction.visible = true
	else:
		chromatic_aberration_strength.visible = false
		chromatic_aberration_reaction.visible = false
	if GlobalVariables.post_processing_type == "Vignette":
		vignette_color.visible = true
		vignette_size.visible = true
		vignette_sharpness.visible = true
		vignette_reaction.visible = true
	else:
		vignette_color.visible = false
		vignette_size.visible = false
		vignette_sharpness.visible = false
		vignette_reaction.visible = false
	if GlobalVariables.post_processing_type == "Grain":
		grain_static.visible = true
		grain_opacity.visible = true
	else:
		grain_static.visible = false
		grain_opacity.visible = false
	
	if GlobalVariables.audio_reaction_enabled:
		audio_r_min_db.visible = true
		audio_r_target.visible = true
		reaction_strength.visible = true
		smoothing_amount.visible = true
	else:
		audio_r_min_db.visible = false
		audio_r_target.visible = false
		reaction_strength.visible = false
		smoothing_amount.visible = false

func set_ui_values() -> void:
	no_of_stems_value.value = GlobalVariables.number_of_stems
	v_layout_value.button_pressed = GlobalVariables.vertical_layout
	
	title_value.text = GlobalVariables.title
	title_f_b_value.button_pressed = GlobalVariables.title_font_bold
	title_f_i_value.button_pressed = GlobalVariables.title_font_italic
	title_p_x_value.value = GlobalVariables.title_pos.x
	title_p_y_value.value = GlobalVariables.title_pos.y
	title_c_value.color = GlobalVariables.title_color
	title_si_value.value = GlobalVariables.title_size
	title_s_c_value.color = GlobalVariables.title_shadow_color
	title_s_x_value.value = GlobalVariables.title_shadow_pos.x
	title_s_y_value.value = GlobalVariables.title_shadow_pos.y
	title_o_c_value.color = GlobalVariables.title_outline_color
	title_o_s_value.value = GlobalVariables.title_outline_size
	
	waveform_1_colors.color = GlobalVariables.waveform_colors[0]
	waveform_2_colors.color = GlobalVariables.waveform_colors[1]
	waveform_3_colors.color = GlobalVariables.waveform_colors[2]
	waveform_4_colors.color = GlobalVariables.waveform_colors[3]
	waveform_t_value.value = GlobalVariables.waveform_thickness
	waveform_h_value.value = GlobalVariables.waveform_height
	
	if bg_t_value.item_count == 0:
		bg_t_value.add_item(GlobalVariables.background_types_in_selector[0], 0)
		bg_t_value.add_item(GlobalVariables.background_types_in_selector[1], 1)
		bg_t_value.add_item(GlobalVariables.background_types_in_selector[2], 2)
	
	bg_1_colors.color = GlobalVariables.background_colors[0]
	bg_2_colors.color = GlobalVariables.background_colors[1]
	bg_3_colors.color = GlobalVariables.background_colors[2]
	bg_4_colors.color = GlobalVariables.background_colors[3]
	
	bg_img_p_file_dialog.set_filters(PackedStringArray(["*.png, *.jpg, *.jpeg ; Supported Images"]))
	bg_img_s_value.value = GlobalVariables.image_size
	bg_img_o_value.value = GlobalVariables.image_opacity
	bg_img_o_slider_value.text = str(bg_img_o_value.value)
	bg_img_b_value.value = GlobalVariables.image_blur
	bg_img_b_slider_value.text = str(bg_img_b_value.value)
	
	bg_s_color_m_value.button_pressed = GlobalVariables.background_shader_color_mix
	bg_s_color_value.color = GlobalVariables.background_shader_color
	bg_s_freq_f_value.value = GlobalVariables.background_shader_frequency_factor
	bg_s_freq_f_slider_value.text = str(bg_s_freq_f_value.value)
	bg_s_blur_value.value = GlobalVariables.background_shader_blur
	bg_s_blur_slider_value.text = str(bg_s_blur_value.value)
	bg_s_amp_value.value = GlobalVariables.background_shader_amplitude
	bg_s_amp_slider_value.text = str(bg_s_amp_value.value)
	bg_s_spe_value.value = GlobalVariables.background_shader_speed
	bg_s_spe_slider_value.text = str(bg_s_spe_value.value)
	bg_s_oct_value.value = GlobalVariables.background_shader_octaves
	bg_s_freq_i_value.value = GlobalVariables.background_shader_frequency_increment
	bg_s_freq_i_slider_value.text = str(bg_s_freq_i_value.value)
	bg_s_amp_d_value.value = GlobalVariables.background_shader_amplitude_decrement
	bg_s_amp_d_slider_value.text = str(bg_s_amp_d_value.value)
	
	divider_c_value.color = GlobalVariables.divider_colors[0]
	divider_c_value_2.color = GlobalVariables.divider_colors[1]
	divider_t_value.value = GlobalVariables.divider_thickness
	
	icon_e_value.button_pressed = GlobalVariables.icon_enabled
	icon_p_file_dialog.set_filters(PackedStringArray(["*.png, *.jpg, *.jpeg ; Supported Images"]))
	icon_c_value.color = GlobalVariables.icon_color
	icon_s_value.value = GlobalVariables.icon_size
	
	if post_p_t_value.item_count == 0:
		post_p_t_value.add_item(GlobalVariables.post_processing_types_in_selector[0], 0)
		post_p_t_value.add_item(GlobalVariables.post_processing_types_in_selector[1], 1)
		post_p_t_value.add_item(GlobalVariables.post_processing_types_in_selector[2], 2)
		post_p_t_value.add_item(GlobalVariables.post_processing_types_in_selector[3], 3)
	bloom_a_value.value = GlobalVariables.bloom_amount
	bloom_a_slider_value.text = str(bloom_a_value.value)
	bloom_r_value.button_pressed = GlobalVariables.bloom_reaction
	chromatic_a_s_value.value = GlobalVariables.chromatic_aberration_strength
	chromatic_a_s_slider_value.text = str(chromatic_a_s_value.value)
	chromatic_a_r_value.button_pressed = GlobalVariables.chromatic_aberration_reaction
	vignette_c_value.color = GlobalVariables.vignette_color
	vignette_s_value.value = GlobalVariables.vignette_size
	vignette_s_slider_value.text = str(vignette_s_value.value)
	vignette_sh_value.value = GlobalVariables.vignette_sharpness
	vignette_sh_slider_value.text = str(vignette_sh_value.value)
	vignette_r_value.button_pressed = GlobalVariables.vignette_reaction
	grain_s_value.button_pressed = GlobalVariables.grain_static
	grain_o_value.value = GlobalVariables.grain_opacity
	grain_o_slider_value.text = str(grain_o_value.value)
	
	audio_r_e_value.button_pressed = GlobalVariables.audio_reaction_enabled
	audio_r_m_value.value = GlobalVariables.min_db_level
	title_a_r_value.button_pressed = GlobalVariables.audio_reaction_targets["Title"]
	background_a_r_value.button_pressed = GlobalVariables.audio_reaction_targets["Background"]
	icon_a_r_value.button_pressed = GlobalVariables.audio_reaction_targets["Icon"]
	post_p_a_r_value.button_pressed = GlobalVariables.audio_reaction_targets["Post-Processing"]
	reaction_s_value.value = GlobalVariables.reaction_strength
	smoothing_a_value.value = GlobalVariables.smoothing_amount
	
	MainUtils.logger("UI values set.")

func refresh_preset_list() -> void:
	preset_value.clear()
	
	var file_iterable: int = 0
	for preset: String in GlobalVariables.presets_in_selector:
		preset_value.add_item(GlobalVariables.presets_in_selector[file_iterable], file_iterable)
		file_iterable += 1
	preset_value.select(GlobalVariables.presets_in_selector.find(GlobalVariables.preset_name))
	
	MainUtils.logger("Preset list updated.")

#region CUSTOMIZE BUILT-IN SIGNAL FUNCTIONS ##################################

func _on_preset_value_item_selected(index: int) -> void:
	GlobalVariables.preset_name = GlobalVariables.presets_in_selector[index]
	GlobalVariables.load_preset(GlobalVariables.preset_name)
	
	bg_t_value.select(GlobalVariables.background_types_in_selector.find(GlobalVariables.background_type))
	
	if GlobalVariables.title_font not in GlobalVariables.title_fonts_in_selector:
		MainUtils.logger("Could not find font \"" + GlobalVariables.title_font + "\" in preset.", true)
		GlobalVariables.title_font = "Calibri"
	title_f_value.select(GlobalVariables.title_fonts_in_selector.find(GlobalVariables.title_font))
	
	set_ui_values()
	
	MainUtils.update_visualizer.emit()

func _on_save_p_value_pressed() -> void:
	if not save_preset_container.visible:
		ui_anim_player.play("save_in")
	else:
		ui_anim_player.play("save_out")

func _on_no_of_stems_value_value_changed(value: float) -> void:
	GlobalVariables.number_of_stems = int(value)
	
	# Changes visibility based on amount of waveforms visible.
	var number_of_options: Array = [true, false, false, false]
	
	for waveform: int in value:
		number_of_options[waveform] = true
	
	waveform_1_colors.visible = number_of_options[0]
	waveform_2_colors.visible = number_of_options[1]
	waveform_3_colors.visible = number_of_options[2]
	waveform_4_colors.visible = number_of_options[3]
	
	bg_1_colors.visible = number_of_options[0]
	bg_2_colors.visible = number_of_options[1]
	bg_3_colors.visible = number_of_options[2]
	bg_4_colors.visible = number_of_options[3]
	
	MainUtils.update_visualizer.emit()

func _on_v_layout_value_toggled(toggled_on: bool) -> void:
	GlobalVariables.vertical_layout = toggled_on
	
	MainUtils.update_visualizer.emit()

func _on_title_value_text_changed(new_text: String) -> void:
	GlobalVariables.title = new_text
	
	MainUtils.update_visualizer.emit()

func _on_title_f_value_item_selected(index: int) -> void:
	GlobalVariables.title_font = GlobalVariables.title_fonts_in_selector[index]
	
	MainUtils.update_visualizer.emit()

func _on_title_f_b_value_toggled(toggled_on: bool) -> void:
	GlobalVariables.title_font_bold = toggled_on
	
	MainUtils.update_visualizer.emit()

func _on_title_f_i_value_toggled(toggled_on: bool) -> void:
	GlobalVariables.title_font_italic = toggled_on
	
	MainUtils.update_visualizer.emit()

func _on_title_p_x_value_value_changed(value: float) -> void:
	GlobalVariables.title_pos.x = int(value)
	
	MainUtils.update_visualizer.emit()

func _on_title_p_y_value_value_changed(value: float) -> void:
	GlobalVariables.title_pos.y = int(value)
	
	MainUtils.update_visualizer.emit()

func _on_title_c_value_color_changed(color: Color) -> void:
	GlobalVariables.title_color = color
	
	MainUtils.update_visualizer.emit()

func _on_title_si_value_value_changed(value: float) -> void:
	GlobalVariables.title_size = int(value)
	
	MainUtils.update_visualizer.emit()

func _on_title_s_c_value_color_changed(color: Color) -> void:
	GlobalVariables.title_shadow_color = color
	
	MainUtils.update_visualizer.emit()

func _on_title_s_x_value_value_changed(value: float) -> void:
	GlobalVariables.title_shadow_pos.x = int(value)
	
	MainUtils.update_visualizer.emit()

func _on_title_s_y_value_value_changed(value: float) -> void:
	GlobalVariables.title_shadow_pos.y = int(value)
	
	MainUtils.update_visualizer.emit()

func _on_title_o_c_value_color_changed(color: Color) -> void:
	GlobalVariables.title_outline_color = color
	
	MainUtils.update_visualizer.emit()

func _on_title_o_s_value_value_changed(value: float) -> void:
	GlobalVariables.title_outline_size = int(value)
	
	MainUtils.update_visualizer.emit()

func _on_waveform_1_colors_color_changed(color: Color) -> void:
	GlobalVariables.waveform_colors[0] = color
	
	MainUtils.update_visualizer.emit()

func _on_waveform_2_colors_color_changed(color: Color) -> void:
	GlobalVariables.waveform_colors[1] = color
	
	MainUtils.update_visualizer.emit()

func _on_waveform_3_colors_color_changed(color: Color) -> void:
	GlobalVariables.waveform_colors[2] = color
	
	MainUtils.update_visualizer.emit()

func _on_waveform_4_colors_color_changed(color: Color) -> void:
	GlobalVariables.waveform_colors[3] = color
	
	MainUtils.update_visualizer.emit()

func _on_waveform_t_value_value_changed(value: float) -> void:
	GlobalVariables.waveform_thickness = int(value)
	
	MainUtils.update_visualizer.emit()

func _on_waveform_h_value_value_changed(value: float) -> void:
	GlobalVariables.waveform_height = value
	
	MainUtils.update_visualizer.emit()

func _on_bg_t_value_item_selected(index: int) -> void:
	GlobalVariables.background_type = GlobalVariables.background_types_in_selector[index]
	
	MainUtils.update_visualizer.emit()

func _on_bg_1_colors_color_changed(color: Color) -> void:
	GlobalVariables.background_colors[0] = color
	
	MainUtils.update_visualizer.emit()

func _on_bg_2_colors_color_changed(color: Color) -> void:
	GlobalVariables.background_colors[1] = color
	
	MainUtils.update_visualizer.emit()

func _on_bg_3_colors_color_changed(color: Color) -> void:
	GlobalVariables.background_colors[2] = color
	
	MainUtils.update_visualizer.emit()

func _on_bg_4_colors_color_changed(color: Color) -> void:
	GlobalVariables.background_colors[3] = color
	
	MainUtils.update_visualizer.emit()

func _on_bg_img_p_value_pressed() -> void:
	bg_img_p_file_dialog.set_current_dir(GlobalVariables.assets_path)
	bg_img_p_file_dialog.popup()

func _on_bg_img_p_file_dialog_file_selected(path: String) -> void:
	GlobalVariables.image_path = path

func _on_bg_img_s_value_value_changed(value: float) -> void:
	GlobalVariables.image_size = int(value)
	
	MainUtils.update_visualizer.emit()

func _on_bg_img_o_value_value_changed(value: float) -> void:
	GlobalVariables.image_opacity = int(value)
	bg_img_o_slider_value.text = str(int(value))
	
	MainUtils.update_visualizer.emit()

func _on_bg_img_b_value_value_changed(value: float) -> void:
	GlobalVariables.image_blur = int(value)
	bg_img_b_slider_value.text = str(int(value))
	
	MainUtils.update_visualizer.emit()

func _on_bg_s_color_m_value_toggled(toggled_on: bool) -> void:
	GlobalVariables.background_shader_color_mix = toggled_on
	
	MainUtils.update_visualizer.emit()

func _on_bg_s_color_value_color_changed(color: Color) -> void:
	GlobalVariables.background_shader_color = color
	
	MainUtils.update_visualizer.emit()

func _on_bg_s_freq_f_value_value_changed(value: float) -> void:
	GlobalVariables.background_shader_frequency_factor = value
	bg_s_freq_f_slider_value.text = str(value)
	
	MainUtils.update_visualizer.emit()

func _on_bg_s_blur_value_value_changed(value: float) -> void:
	GlobalVariables.background_shader_blur = int(value)
	bg_s_blur_slider_value.text = str(int(value))
	
	MainUtils.update_visualizer.emit()

func _on_bg_s_amp_value_value_changed(value: float) -> void:
	GlobalVariables.background_shader_amplitude = value
	bg_s_amp_slider_value.text = str(value)
	
	MainUtils.update_visualizer.emit()

func _on_bg_s_spe_value_value_changed(value: float) -> void:
	GlobalVariables.background_shader_speed = value
	bg_s_spe_slider_value.text = str(value)
	
	MainUtils.update_visualizer.emit()

func _on_bg_s_oct_value_value_changed(value: float) -> void:
	GlobalVariables.background_shader_octaves = int(value)
	
	MainUtils.update_visualizer.emit()

func _on_bg_s_freq_i_value_value_changed(value: float) -> void:
	GlobalVariables.background_shader_frequency_increment = value
	bg_s_freq_i_slider_value.text = str(value)
	
	MainUtils.update_visualizer.emit()

func _on_bg_s_amp_d_value_value_changed(value: float) -> void:
	GlobalVariables.background_shader_amplitude_decrement = value
	bg_s_amp_d_slider_value.text = str(value)
	
	MainUtils.update_visualizer.emit()

func _on_divider_c_value_color_changed(color: Color) -> void:
	GlobalVariables.divider_colors[0] = color
	
	MainUtils.update_visualizer.emit()

func _on_divider_c_value_2_color_changed(color: Color) -> void:
	GlobalVariables.divider_colors[1] = color
	
	MainUtils.update_visualizer.emit()

func _on_divider_t_value_value_changed(value: float) -> void:
	GlobalVariables.divider_thickness = int(value)
	
	MainUtils.update_visualizer.emit()

func _on_icon_e_value_toggled(toggled_on: bool) -> void:
	GlobalVariables.icon_enabled = toggled_on
	
	MainUtils.update_visualizer.emit()

func _on_icon_p_value_pressed() -> void:
	icon_p_file_dialog.set_current_dir(GlobalVariables.assets_path)
	icon_p_file_dialog.popup()

func _on_icon_p_file_dialog_file_selected(path: String) -> void:
	GlobalVariables.icon_path = path

func _on_icon_c_value_color_changed(color: Color) -> void:
	GlobalVariables.icon_color = color
	
	MainUtils.update_visualizer.emit()

func _on_icon_s_value_value_changed(value: float) -> void:
	GlobalVariables.icon_size = int(value)
	
	MainUtils.update_visualizer.emit()

func _on_post_p_t_value_item_selected(index: int) -> void:
	GlobalVariables.post_processing_type = GlobalVariables.post_processing_types_in_selector[index]
	
	MainUtils.update_visualizer.emit()

func _on_bloom_a_value_value_changed(value: float) -> void:
	GlobalVariables.bloom_amount = value
	bloom_a_slider_value.text = str(value)
	
	MainUtils.update_visualizer.emit()

func _on_bloom_r_value_toggled(toggled_on: bool) -> void:
	GlobalVariables.bloom_reaction = toggled_on
	
	MainUtils.update_visualizer.emit()

func _on_chromatic_a_s_value_value_changed(value: float) -> void:
	GlobalVariables.chromatic_aberration_strength = value
	chromatic_a_s_slider_value.text = str(value)
	
	MainUtils.update_visualizer.emit()

func _on_chromatic_a_r_value_toggled(toggled_on: bool) -> void:
	GlobalVariables.chromatic_aberration_reaction = toggled_on
	
	MainUtils.update_visualizer.emit()

func _on_vignette_c_value_color_changed(color: Color) -> void:
	GlobalVariables.vignette_color = color
	
	MainUtils.update_visualizer.emit()

func _on_vignette_s_value_value_changed(value: float) -> void:
	GlobalVariables.vignette_size = value
	vignette_s_slider_value.text = str(value)
	
	MainUtils.update_visualizer.emit()

func _on_vignette_sh_value_value_changed(value: float) -> void:
	GlobalVariables.vignette_sharpness = value
	vignette_sh_slider_value.text = str(value)
	
	MainUtils.update_visualizer.emit()

func _on_vignette_r_value_toggled(toggled_on: bool) -> void:
	GlobalVariables.vignette_reaction = toggled_on
	
	MainUtils.update_visualizer.emit()

func _on_grain_s_value_toggled(toggled_on: bool) -> void:
	GlobalVariables.grain_static = toggled_on
	
	MainUtils.update_visualizer.emit()

func _on_grain_o_value_value_changed(value: float) -> void:
	GlobalVariables.grain_opacity = int(value)
	grain_o_slider_value.text = str(value)
	
	MainUtils.update_visualizer.emit()

func _on_audio_r_e_value_toggled(toggled_on: bool) -> void:
	GlobalVariables.audio_reaction_enabled = toggled_on
	
	MainUtils.update_visualizer.emit()

func _on_audio_r_m_value_value_changed(value: float) -> void:
	GlobalVariables.min_db_level = int(value)
	
	MainUtils.update_visualizer.emit()

func _on_title_a_r_value_toggled(toggled_on: bool) -> void:
	GlobalVariables.audio_reaction_targets["Title"] = toggled_on
	
	MainUtils.update_visualizer.emit()

func _on_background_a_r_value_toggled(toggled_on: bool) -> void:
	GlobalVariables.audio_reaction_targets["Background"] = toggled_on
	
	MainUtils.update_visualizer.emit()

func _on_icon_a_r_value_toggled(toggled_on: bool) -> void:
	GlobalVariables.audio_reaction_targets["Icon"] = toggled_on
	
	MainUtils.update_visualizer.emit()

func _on_post_p_a_r_value_toggled(toggled_on: bool) -> void:
	GlobalVariables.audio_reaction_targets["Post-Processing"] = toggled_on
	
	MainUtils.update_visualizer.emit()

func _on_reaction_s_value_value_changed(value: float) -> void:
	GlobalVariables.reaction_strength = int(value)
	
	MainUtils.update_visualizer.emit()

func _on_smoothing_a_value_value_changed(value: float) -> void:
	GlobalVariables.smoothing_amount = int(value)
	
	MainUtils.update_visualizer.emit()

#endregion ##################################
