extends Node2D

@export var subtitles_theme : Theme
@export var font_size : IntVariable
@export var background_color : ColorVariable
@export var font_color : ColorVariable
@export var outline_color : ColorVariable
@export var outline_size : IntVariable

func _ready():
	_setup_subtitles_settings()
	font_size.value_changed.connect(_on_font_size_value_changed)
	background_color.value_changed.connect(_on_background_color_value_changed)
	font_color.value_changed.connect(_on_font_color_value_changed)
	outline_color.value_changed.connect(_on_outline_color_value_changed)
	outline_size.value_changed.connect(_on_outline_size_value_changed)

func _setup_subtitles_settings() -> void:
	font_size.value = subtitles_theme.default_font_size
	background_color.value = subtitles_theme.get_stylebox("panel", "PanelContainer").bg_color
	font_color.value = subtitles_theme.get_color("default_color", "RichTextLabel")
	outline_color.value = subtitles_theme.get_color("font_outline_color", "RichTextLabel")
	outline_size.value = subtitles_theme.get_constant("outline_size", "RichTextLabel")

func _on_font_size_value_changed(new_value : int) -> void:
	subtitles_theme.default_font_size = new_value

func _on_background_color_value_changed(new_value : Color) -> void:
	subtitles_theme.get_stylebox("panel", "PanelContainer").bg_color = new_value

func _on_font_color_value_changed(new_value : Color) -> void:
	subtitles_theme.set_color("default_color", "RichTextLabel", new_value)

func _on_outline_color_value_changed(new_value : Color) -> void:
	subtitles_theme.set_color("font_outline_color", "RichTextLabel", new_value)

func _on_outline_size_value_changed(new_value : int) -> void:
	subtitles_theme.set_constant("outline_size", "RichTextLabel", new_value)
