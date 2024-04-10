extends Node2D

@export var subtitles_theme : Theme
@export var font_size : IntVariable
@export var background_opacity : IntVariable
@export var background_color : ColorVariable
@export var font_color : ColorVariable
@export var outline_color : ColorVariable
@export var outline_size : IntVariable
@export var external_margin : IntVariable
@export var internal_margin : IntVariable
@export var corners_radius : IntVariable

@onready var options_container = %OptionsContainer
@onready var tab_container = %TabContainer


func _ready():
	InputEnhancer.load_input_scheme()

	options_container.hide()
	_setup_subtitles_settings()
	font_size.value_changed.connect(_on_font_size_value_changed)
	background_opacity.value_changed.connect(_on_background_opacity_value_changed)
	background_color.value_changed.connect(_on_background_color_value_changed)
	font_color.value_changed.connect(_on_font_color_value_changed)
	outline_color.value_changed.connect(_on_outline_color_value_changed)
	outline_size.value_changed.connect(_on_outline_size_value_changed)
	external_margin.value_changed.connect(_on_external_margin_value_changed)
	internal_margin.value_changed.connect(_on_internal_margin_value_changed)
	corners_radius.value_changed.connect(_on_corners_radius_value_changed)

func _input(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		options_container.visible = not options_container.visible
		if options_container.visible:
			tab_container.get_tab_bar().grab_focus()
		get_tree().paused = options_container.visible

func _setup_subtitles_settings() -> void:
	font_size.value = subtitles_theme.default_font_size
	background_opacity.value = subtitles_theme.get_stylebox("panel", "PanelContainer").bg_color.a * 255

	background_color.value = subtitles_theme.get_stylebox("panel", "PanelContainer").bg_color
	font_color.value = subtitles_theme.get_color("default_color", "RichTextLabel")
	outline_color.value = subtitles_theme.get_color("font_outline_color", "RichTextLabel")
	outline_size.value = subtitles_theme.get_constant("outline_size", "RichTextLabel")
	external_margin.value = subtitles_theme.get_constant("margin_bottom", "MarginContainer")
	internal_margin.value = subtitles_theme.get_constant("margin_bottom", "InternalMarginContainer")
	corners_radius.value = subtitles_theme.get_stylebox("panel", "PanelContainer").corner_radius_bottom_left

func _on_font_size_value_changed(new_value : int) -> void:
	subtitles_theme.default_font_size = new_value

func _on_background_opacity_value_changed(new_value : int) -> void:
	subtitles_theme.get_stylebox("panel", "PanelContainer").bg_color.a = new_value / 255.0

func _on_background_color_value_changed(new_value : Color) -> void:
	subtitles_theme.get_stylebox("panel", "PanelContainer").bg_color = new_value

func _on_font_color_value_changed(new_value : Color) -> void:
	subtitles_theme.set_color("default_color", "RichTextLabel", new_value)

func _on_outline_color_value_changed(new_value : Color) -> void:
	subtitles_theme.set_color("font_outline_color", "RichTextLabel", new_value)

func _on_outline_size_value_changed(new_value : int) -> void:
	subtitles_theme.set_constant("outline_size", "RichTextLabel", new_value)


func _on_external_margin_value_changed(new_value : int) -> void:
	_set_all_margins_to("MarginContainer", new_value)


func _on_internal_margin_value_changed(new_value : int) -> void:
	_set_all_margins_to("InternalMarginContainer", new_value)

func _set_all_margins_to(container_type : String, margin_value : int) -> void:
	subtitles_theme.set_constant("margin_bottom", container_type, margin_value)
	subtitles_theme.set_constant("margin_top", container_type, margin_value)
	subtitles_theme.set_constant("margin_left", container_type, margin_value)
	subtitles_theme.set_constant("margin_right", container_type, margin_value)

func _on_corners_radius_value_changed(new_value : int) -> void:
	_set_all_corners("PanelContainer", "panel", new_value)

func _set_all_corners(container_type : String, style_box_name: String, radius : int) -> void:
	var stylebox : StyleBoxFlat = subtitles_theme.get_stylebox(style_box_name, container_type)
	stylebox.corner_radius_bottom_left = radius
	stylebox.corner_radius_bottom_right = radius
	stylebox.corner_radius_top_left = radius
	stylebox.corner_radius_top_right = radius
